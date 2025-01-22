// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface PriceInterface {
    function getPrice(address token) external view returns (uint);
}

contract VulnerablePriceManipulation {
    IERC20 public U;
    IERC20 public EGD;
    address public wallet;
    PriceInterface public getPriceFeed; 

    uint public stakeId;
    mapping(address => uint) public userTotalAmount;
    mapping(address => mapping(uint => uint)) public userStake;

    // Constructor to initialize contract with token addresses and price feed
    function initialize(address EGD_, address U_, address wallet_, address priceFeed_) public {
        EGD = IERC20(EGD_);
        U = IERC20(U_);
        wallet = wallet_;
        getPriceFeed = PriceInterface(priceFeed_);
    }

    // Function to fetch EGD price 
    function getEGDPrice() public view returns (uint) {
        return getPriceFeed.getPrice(address(EGD));
    }

    // Function to stake U tokens
    function stake(uint amount) external {
        require(amount >= 100 ether, "minimum stake");
        U.transferFrom(msg.sender, address(this), amount);

        uint price = getEGDPrice();
        uint amountToBuy = amount * 70 / 100 / price; // Manipulated by price feed

        U.transfer(wallet, amount / 10);

        // Store the stake and increase user's total amount
        userStake[msg.sender][stakeId] = amount;
        userTotalAmount[msg.sender] += amount;
        stakeId++;
    }

    // Function to claim rewards based on stake
    function claimReward(uint stakeId) external {
        uint amount = userStake[msg.sender][stakeId];
        require(amount > 0, "no stake");

        // Calculate rewards 
        uint reward = (block.timestamp - 1 weeks) * amount / 86400;
        EGD.transfer(msg.sender, reward);

        // Clean up after claiming rewards
        userTotalAmount[msg.sender] -= amount;
        delete userStake[msg.sender][stakeId];
    }
}
