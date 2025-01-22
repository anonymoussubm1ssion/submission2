pragma solidity ^0.8.0;

contract HighestBidder {

    address public currentWinner;
    uint256 public winningBid;

    function placeBid() external payable {
        require(msg.value > winningBid, "Bid must be higher than current winning bid.");

        // Refund previous winner if any
        if (currentWinner != address(0)) {
            (bool success, ) = currentWinner.call{value: winningBid}("");
            require(success, "Refund to previous winner failed.");
        }

        // Update the winning bidder and winning bid
        currentWinner = msg.sender;
        winningBid = msg.value;
    }

    // Function to claim the prize (if any)
    function claimPrize() external {
        require(msg.sender == currentWinner, "Only the current winner can claim the prize.");
        require(currentWinner != address(0), "No winner has been determined yet.");

        // Transfer the prize amount to the winner
        (bool success, ) = msg.sender.call{value: winningBid}("");
        require(success, "Prize transfer failed.");

        // Reset the contract state
        currentWinner = address(0);
        winningBid = 0;
    }
}