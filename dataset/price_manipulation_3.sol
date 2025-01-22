pragma solidity ^0.8.0;

interface IPriceFeed {
    function getCurrentPrice() external view returns (uint256);
}

contract VulnerableVault {
    IPriceFeed public priceOracle;
    address public contractOwner;
    mapping(address => uint256) public userBalances;

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "You are not the contract owner");
        _;
    }

    event TokensDeposited(address indexed user, uint256 depositAmount, uint256 mintedTokens);
    event TokensWithdrawn(address indexed user, uint256 withdrawalAmount, uint256 returnedEther);

    constructor(address _priceOracle) {
        priceOracle = IPriceFeed(_priceOracle);
        contractOwner = msg.sender;
    }

    function updatePriceOracle(address _newPriceOracle) external onlyContractOwner {
        priceOracle = IPriceFeed(_newPriceOracle);
    }

    function userDeposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");

        uint256 price = priceOracle.getCurrentPrice();
        require(price > 0, "Received invalid price data from oracle");

        uint256 tokensToMint = msg.value * price * 1000;
        userBalances[msg.sender] += tokensToMint;

        emit TokensDeposited(msg.sender, msg.value, tokensToMint);
    }

    function userWithdraw(uint256 _tokensAmount) external {
        require(userBalances[msg.sender] >= _tokensAmount, "Insufficient balance to withdraw");

        uint256 price = priceOracle.getCurrentPrice();
        require(price > 0, "Received invalid price data from oracle");

        uint256 etherToReturn = _tokensAmount / (price * 1000);
        require(address(this).balance >= etherToReturn, "Contract does not have enough Ether to process withdrawal");

        userBalances[msg.sender] -= _tokensAmount;
        payable(msg.sender).transfer(etherToReturn);

        emit TokensWithdrawn(msg.sender, _tokensAmount, etherToReturn);
    }


   
}
