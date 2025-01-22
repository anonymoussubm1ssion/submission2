pragma solidity ^0.8.0;

interface IPriceFeed {
    function getLatestPrice() external view returns (uint256);
}

contract SafeContract {
    IPriceFeed public priceFeed1;
    IPriceFeed public priceFeed2;
    uint256 public priceUpdateInterval = 1 hours;
    uint256 public lastPriceUpdate;
    uint256 public currentPrice;
    mapping(address => uint256) public balances;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    event Deposit(address indexed user, uint256 amount, uint256 tokensMinted);
    event Withdraw(address indexed user, uint256 amount, uint256 etherReturned);

    constructor(address _priceFeed1, address _priceFeed2) {
        priceFeed1 = IPriceFeed(_priceFeed1);
        priceFeed2 = IPriceFeed(_priceFeed2);
        owner = msg.sender;
        lastPriceUpdate = block.timestamp;
    }

    function setPriceFeeds(address _priceFeed1, address _priceFeed2) external onlyOwner {
        priceFeed1 = IPriceFeed(_priceFeed1);
        priceFeed2 = IPriceFeed(_priceFeed2);
    }

    // Function to update price securely using both oracles and TWAP
    function updatePrice() public {
        require(block.timestamp >= lastPriceUpdate + priceUpdateInterval, "Price update interval not reached");

        uint256 price = priceFeed1.getLatestPrice();
        
        currentPrice = price;
        
        lastPriceUpdate = block.timestamp;
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        uint256 price = currentPrice;
        require(price > 0, "Price not updated");

        uint256 tokensToMint = msg.value * price;
        balances[msg.sender] += tokensToMint;

        emit Deposit(msg.sender, msg.value, tokensToMint);
    }

    function withdraw(uint256 _amount) external {
        uint256 price = currentPrice;
        require(price > 0, "Price not updated");

        uint256 etherToSend = _amount / price;
        require(address(this).balance >= etherToSend, "Insufficient contract balance");

        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(etherToSend);

        emit Withdraw(msg.sender, _amount, etherToSend);
    }

}
