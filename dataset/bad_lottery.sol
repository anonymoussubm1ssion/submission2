pragma solidity ^0.8.0;

contract Lottery {
    address public owner;
    address[] public players;
    uint256 public lotteryId;

    constructor() {
        owner = msg.sender;
        lotteryId = 1; 
    }

    function enterLottery() public payable {
        require(msg.value > 0, "Must send some Ether");
        players.push(msg.sender);
    }

    function pickWinner() public onlyOwner {
        require(players.length > 0, "No players in the lottery");

        // Calculate a "random" number based on the last player's address
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(players[players.length - 1]))) % players.length; 

        // Payout to the winner
        payable(players[randomIndex]).transfer(address(this).balance);

        // Reset for the next lottery
        lotteryId++;
        delete players;
    }
}