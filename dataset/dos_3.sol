// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Auction {
    address public currentLeader;
    uint public highestBid;
    uint public auctionEndTime;
    address public owner;

    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this");
        _;
    }

    modifier auctionActive() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    modifier auctionEnded() {
        require(block.timestamp >= auctionEndTime, "Auction is still active");
        _;
    }

    constructor(uint _auctionDuration) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
    }

    // Function to place a bid
    function bid() external payable auctionActive {
        require(msg.value > highestBid, "Bid must be higher than current highest bid");

        // Refund the old leader if their bid is surpassed
        if (currentLeader != address(0)) {
            (bool sent, ) = currentLeader.call{value: highestBid}("");
            require(sent, "Refund to the previous leader failed");
        }

        currentLeader = msg.sender;
        highestBid = msg.value;

        emit NewBid(msg.sender, msg.value);
    }

    // Function to end the auction
    function endAuction() external auctionEnded onlyOwner {
        emit AuctionEnded(currentLeader, highestBid);
        
        // Transfer the highest bid to the owner
        (bool success, ) = owner.call{value: highestBid}("");
        require(success, "Failed to transfer funds to owner");

        // Reset auction state
        currentLeader = address(0);
        highestBid = 0;
        auctionEndTime = 0; // Optional: Reset auction time to indicate it's over
    }

    // Function to check the current highest bid
    function getHighestBid() external view returns (uint) {
        return highestBid;
    }

    // Function to check the current leader
    function getCurrentLeader() external view returns (address) {
        return currentLeader;
    }

    // Function to check auction status
    function isAuctionActive() external view returns (bool) {
        return block.timestamp < auctionEndTime;
    }
}
