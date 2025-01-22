// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LetsBet {
    address public contractOwner;
    uint256 public betAmount;
    uint256 public totalBets;

    mapping(address => uint256) public userBets;
    mapping(address => bool) public hasClaimedWinnings;

    event BetPlaced(address indexed bettor, uint256 betAmount, bool betOnEven);
    event BetClaimed(address indexed bettor, uint256 winnings);

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only contract owner can call this function");
        _;
    }

    constructor(uint256 _betAmount) {
        contractOwner = msg.sender;
        betAmount = _betAmount;
        totalBets = 0;
    }

    // Function to place a bet on whether the random number is even or odd
    function placeBet(bool _betOnEven) public payable {
        require(msg.value == betAmount, "Incorrect bet amount");
        require(!hasClaimedWinnings[msg.sender], "You have already claimed your winnings");

        userBets[msg.sender] = msg.value;
        totalBets += msg.value;

        emit BetPlaced(msg.sender, msg.value, _betOnEven);

        
        if (_betOnEven) {
            uint256 randomNumber = uint256(blockhash(block.number - 1));  // Front-running vulnerability (blockhash can be predicted)
            bool isEven = randomNumber % 2 == 0;

            if (isEven) {
                uint256 winnings = totalBets;
                payable(msg.sender).transfer(winnings);
                emit BetClaimed(msg.sender, winnings);
                totalBets = 0; // Reset total bets after claim
            }
        }
    }

    // Withdraw function (only callable by the contract owner)
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(contractOwner).transfer(balance);
    }
}
