// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract FoMo3Dlong is modularLong {
    uint256 public airDropTracker_;
    uint256 public potSize_;
    address public lastWinner_;
    mapping(address => uint256) public playerBalances;
    event AirdropWin(address indexed player, uint256 amount, uint256 timestamp);
    event PotUpdated(uint256 newPotSize, uint256 timestamp);
    event PlayerJoined(address indexed player, uint256 amount, uint256 timestamp);

    constructor() {
        airDropTracker_ = 50; // Initial threshold for airdrop win
        potSize_ = 0; // Initial pot size
    }

    function airdrop()
        private
        view
        returns(bool)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)).add
            (block.number)
        )));
        if((seed - ((seed / 1000) * 1000)) < airDropTracker_)
            return true;
        else
            return false;
    }

    /**
     * @dev Function for a player to participate in the game
     * The amount they contribute adds to the potSize_
     */
    function joinGame() external payable {
        require(msg.value > 0, "Must send ETH to join the game");
        playerBalances[msg.sender] += msg.value;
        potSize_ += msg.value;
        emit PlayerJoined(msg.sender, msg.value, block.timestamp);
        emit PotUpdated(potSize_, block.timestamp);

        if (airdrop()) {
            uint256 winAmount = potSize_ / 10; // Example airdrop prize: 10% of potSize_
            lastWinner_ = msg.sender;
            playerBalances[msg.sender] += winAmount;
            potSize_ -= winAmount;
            emit AirdropWin(msg.sender, winAmount, block.timestamp);
        }
    }

    /**
     * @dev Allows players to withdraw their balance
     */
    function withdraw() external {
        uint256 balance = playerBalances[msg.sender];
        require(balance > 0, "No balance to withdraw");
        playerBalances[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
    }

    /**
     * @dev View function to check the current pot size
     */
    function getPotSize() external view returns (uint256) {
        return potSize_;
    }

    /**
     * @dev View function to check the balance of a player
     * @param player Address of the player
     * @return Balance of the player
     */
    function getPlayerBalance(address player) external view returns (uint256) {
        return playerBalances[player];
    }
}
