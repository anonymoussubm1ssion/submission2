// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HashGuessingGame {
    address public owner;
    bytes32 private correctHash;
    uint256 public totalDeposits;

    event Guess(address indexed player, bool success, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Constructor to set the owner and the correct hash
    constructor(bytes32 _correctHash) {
        owner = msg.sender;
        correctHash = _correctHash;
    }

    // Function to guess the hash, players must pay to play
    function guessHash(bytes32 _guess) public payable {
        require(msg.value > 0, "You must send ether to play");
        totalDeposits += msg.value;

        // Check if the guess is correct
        if (_guess == correctHash) {
            // Transfer all deposits to the player
            payable(msg.sender).transfer(totalDeposits);
            emit Guess(msg.sender, true, totalDeposits);
            totalDeposits = 0; // Reset the total deposits after a win
        } else {
            emit Guess(msg.sender, false, msg.value);
        }
    }

    // Function to reset the game by changing the correct hash (only callable by the owner)
    function resetGame(bytes32 _newHash) external onlyOwner {
        correctHash = _newHash;
        totalDeposits = 0; // Reset the total deposits when the game is reset
    }

    // Function to withdraw contract balance (only callable by the owner)
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }
}
