// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PlayBet {
    uint256 public betAmount;
    uint256 public totalBets;
    uint256 public seed;  // Hardcoded seed value

    mapping(address => uint256) public userBets;

    event BetPlaced(address indexed bettor, uint256 amount);
    event WinnerDeclared(address indexed winner, uint256 winnings);

    constructor(uint256 _betAmount,uint256 _seed) {
        betAmount = _betAmount;
        totalBets = 0;
        seed = _seed
    }

    // Function to place a bet
    function placeBet() public payable {
        require(msg.value == betAmount, "Incorrect bet amount");

        userBets[msg.sender] = msg.value;
        totalBets += msg.value;

        emit BetPlaced(msg.sender, msg.value);
    }

    // Function to generate a predictable random number using the hardcoded seed
    function generateRandomNumber() public view returns (uint256) {
        return (hardcodedSeed + totalBets) % 100;  // Random number based on hardcoded seed and total bets
    }

    // Function to declare the winner based on the predictable random number
    function declareWinner() public {
        uint256 randomNumber = generateRandomNumber();

        address winner;
        if (randomNumber % 2 == 0) {
            winner = msg.sender;  // This is just a simple example; you'd have a more complex winner determination logic
            payable(winner).transfer(address(this).balance);  // Transfer all balance to the winner
            emit WinnerDeclared(winner, address(this).balance);
        }
    }

    // Withdraw function (only callable by the contract owner)
    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}
