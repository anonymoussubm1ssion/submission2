pragma solidity ^0.8.11;

contract OrderTransaction {
    uint256 itemPrice;
    address contractOwner;
    
    event ItemPurchased(address _buyer, uint256 _price);
    event PriceUpdated(address _owner, uint256 _newPrice);
    
    modifier onlyOwner() {
        require(msg.sender == contractOwner);
        _;
    }

    function OrderTransaction() {
        // Constructor
        contractOwner = msg.sender;
        itemPrice = 100;
    }

    function purchaseItem() returns (uint256) {
        ItemPurchased(msg.sender, itemPrice);
        return itemPrice;
    }

    function updatePrice(uint256 _newPrice) onlyOwner() {
        itemPrice = _newPrice;
        PriceUpdated(contractOwner, itemPrice);
    }
}
