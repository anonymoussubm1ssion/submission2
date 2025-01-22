// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlackLottery {
    address public owner;
    address public currentLeader;
    uint256 public highestBid;
    uint256 public endTimestamp;

    event NewLeader(address indexed leader, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event WithdrawalFailed(address to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyBeforeEnd() {
        require(block.timestamp < endTimestamp, "Auction has ended");
        _;
    }

    modifier onlyAfterEnd() {
        require(block.timestamp >= endTimestamp, "Auction is still ongoing");
        _;
    }

    constructor(uint256 durationMinutes) {
        owner = msg.sender;
        endTimestamp = block.timestamp + (durationMinutes * 1 minutes);
    }

    function bid() public payable onlyBeforeEnd {
        require(msg.value > highestBid, "There already is a higher bid");

        if (currentLeader != address(0)) {
            (bool success, ) = currentLeader.call{value: highestBid}("");
            if (!success) {
                emit WithdrawalFailed(currentLeader, highestBid);
            }
        }

        currentLeader = msg.sender;
        highestBid = msg.value;

        emit NewLeader(msg.sender, msg.value);
    }

    function finalizeAuction() public onlyOwner onlyAfterEnd {
        emit AuctionEnded(currentLeader, highestBid);

        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer to owner failed");
    }

    function withdraw() public onlyAfterEnd {
        require(msg.sender == currentLeader, "Only the winner can withdraw");

        uint256 amount = address(this).balance;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");
    }
    
    function getTimeRemaining() public view returns (uint256) {
        if (block.timestamp >= endTimestamp) {
            return 0;
        }
        return endTimestamp - block.timestamp;
    }

    receive() external payable {
        bid();
    }

    fallback() external payable {
        bid();
    }
}
