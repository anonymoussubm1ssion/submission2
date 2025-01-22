pragma solidity ^0.8.0;

interface IPriceFeed {
    function getLatestPrice() external view returns (uint256);
}

contract SecureContract {
    IPriceFeed public priceFeed;
    address public owner;
    mapping(address => uint256) public balances;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    event Deposit(address indexed user, uint256 amount, uint256 tokensMinted);
    event Withdraw(address indexed user, uint256 amount, uint256 etherReturned);

    constructor(address _priceFeed) {
        priceFeed = IPriceFeed(_priceFeed);
        owner = msg.sender;
    }

    function setPriceFeed(address _priceFeed) external onlyOwner {
        priceFeed = IPriceFeed(_priceFeed);
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        uint256 price = priceFeed.getLatestPrice();
        require(price > 0, "Invalid price from oracle");

        uint256 tokensToMint = msg.value * price;
        balances[msg.sender] += tokensToMint;

        emit Deposit(msg.sender, msg.value, tokensToMint);
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        uint256 price = priceFeed.getLatestPrice();
        require(price > 0, "Invalid price from oracle");

        uint256 etherToSend = _amount / price;
        require(address(this).balance >= etherToSend, "Contract has insufficient balance");

        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(etherToSend);

        emit Withdraw(msg.sender, _amount, etherToSend);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No Ether to withdraw");

        payable(owner).transfer(contractBalance);
    }

}
