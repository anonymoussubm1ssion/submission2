// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RandomBettingGame  {
    uint256 public totalPlayers;
    address[] public players;
    bool public gameActive;
    bytes32 public sealedSeed;
    bool public seedSet = false;
    uint public storedBlockNumber;
    address public trustedParty;

    event PlayerJoined(address indexed player);
    event GameEnded(address indexed winner, uint256 prize);

    constructor(address _trustedParty)  {
        
        trustedParty = _trustedParty;
        gameActive = true;
    }

    

    // Modifier to restrict access to trusted party
    modifier onlyTrustedParty() {
        require(msg.sender == trustedParty, "Not authorized");
        _;
    }

    // Function for the trusted party to set a sealed seed
    function setSealedSeed(bytes32 _sealedSeed) external onlyTrustedParty {
        require(!seedSet, "Seed already set");
        sealedSeed = _sealedSeed;
        storedBlockNumber = block.number + 1;
        seedSet = true;
    }

    // Function to allow players to join the game
    function play() public payable {
        require(gameActive, "Game is not active");
        require(msg.value >= 1 ether, "Minimum bet is 1 ether");

        players.push(msg.sender);  // Add the player to the players array
        totalPlayers++;

        emit PlayerJoined(msg.sender);
    }

    // Function to end the game and determine the winner
    function endGame(bytes32 _seed) external onlyTrustedParty {
        require(seedSet, "Seed not set");
        require(block.number > storedBlockNumber, "Cannot reveal yet");
        require(players.length > 0, "No players to pick from");

        // Generate a random number based on the sealed seed and blockhash
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(sealedSeed, blockhash(storedBlockNumber)))) % players.length;
        address winner = players[randomNumber];
        uint256 prize = address(this).balance;

        // Transfer the prize to the winner
        payable(winner).transfer(prize);
        
        emit GameEnded(winner, prize);

        // Reset game for the next round
        gameActive = false;
        seedSet = false;
        delete players;
        totalPlayers = 0;
    }

    // Function for the trusted party to reveal the seed
    function revealSeed(bytes32 _seed) external onlyTrustedParty {
        require(seedSet, "Seed not set");
        require(block.number > storedBlockNumber, "Reveal too soon");
        require(keccak256(abi.encodePacked(msg.sender, _seed)) == sealedSeed, "Invalid seed reveal");

        seedSet = false;  // Reset seed after reveal
    }

    // Function to restart the game for a new round
    function restartGame() external onlyTrustedParty {
        gameActive = true;
        delete players;
        totalPlayers = 0;
    }

    // Fallback function to accept Ether
    receive() external payable {}

    // Helper function to check the number of players
    function getPlayers() public view returns (address[] memory) {
        return players;
    }
}
