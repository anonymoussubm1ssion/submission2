pragma solidity ^0.8.0;

contract SimpleAuction {
    address public highestBidder;
    uint public highestBid;

    function bid() external payable {
        require(msg.value > highestBid, "Bid must be higher than current highest bid.");

        // Refund previous highest bidder
        if (highestBidder != address(0)) {
            (bool success,) = highestBidder.call{value: highestBid}("");
            require(success, "Refund failed.");
        }

        // Update the highest bidder and highest bid
        highestBidder = msg.sender;
        highestBid = msg.value;
    }
}