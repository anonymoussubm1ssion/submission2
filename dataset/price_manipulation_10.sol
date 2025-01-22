// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IAssetPriceOracle {
    function lpPrice() external view returns (uint256);
}

contract TokenExchange is AccessControl,Initializable  {
    IAssetPriceOracle public priceOracle;
    
    bytes32 public constant EXCHANGE_ROLE = keccak256("EXCHANGE_ROLE");
    bytes32 public constant DEPOSIT_ROLE = keccak256("DEPOSIT_ROLE");
    
    uint256 public currentAssetPrice;
    
    mapping(address => uint256) public deposits; // User deposits
    
    event TokensDeposited(address indexed user, uint256 amount);
    event TokensWithdrawn(address indexed user, uint256 amount);
    event TokensExchanged(address indexed user, uint256 amountFrom, uint256 amountTo);
    event PriceUpdated(uint256 newPrice);

     function initialize(address priceOracle_) public initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(EXCHANGE_ROLE, msg.sender);
        _grantRole(DEPOSIT_ROLE, msg.sender);

        require(priceOracle_ != address(0), 'Zero price oracle');
        priceOracle = IAssetPriceOracle(priceOracle_);

        cacheAssetPrice();
    }

    // Function to get the current asset price
    function assetPrice() public view returns (uint256) {
        return currentAssetPrice;
    }

    // Function to cache the asset price
    function cacheAssetPrice() public onlyRole(EXCHANGE_ROLE) {
        currentAssetPrice = priceOracle.lpPrice();
        emit PriceUpdated(currentAssetPrice);
    }

    // Function to deposit tokens
    function depositTokens(address token, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        
        // Transfer the tokens from the sender to the contract
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        
        // Update the user's deposit balance
        deposits[msg.sender] += amount;
        
        emit TokensDeposited(msg.sender, amount);
    }

    // Function to withdraw tokens
    function withdrawTokens(address token, uint256 amount) public {
        require(deposits[msg.sender] >= amount, "Insufficient balance");

        // Update the user's deposit balance
        deposits[msg.sender] -= amount;
        
        // Transfer the tokens back to the user
        IERC20(token).transfer(msg.sender, amount);
        
        emit TokensWithdrawn(msg.sender, amount);
    }

    // Function to exchange tokens
    function exchangeTokens(address tokenFrom, address tokenTo, uint256 amountFrom) public onlyRole(EXCHANGE_ROLE) {
        uint256 price = assetPrice();
        uint256 amountTo = amountFrom * price / 1e18; // Example calculation

        // Ensure the user has enough balance
        require(deposits[msg.sender] >= amountFrom, "Insufficient deposit balance");

        // Deduct the exchanged amount from the user's deposit
        deposits[msg.sender] -= amountFrom;

        // Placeholder logic for transferring tokens (replace with actual logic)
        // IERC20(tokenFrom).transferFrom(msg.sender, address(this), amountFrom);
        // IERC20(tokenTo).transfer(msg.sender, amountTo);

        emit TokensExchanged(msg.sender, amountFrom, amountTo);
    }

    // Function to update the price (only callable by EXCHANGE_ROLE)
    function updatePrice() public onlyRole(EXCHANGE_ROLE) {
        cacheAssetPrice();
    }

    // Function to check deposit balance of the user
    function getDepositBalance(address user) public view returns (uint256) {
        return deposits[user];
    }
}
