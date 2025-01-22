// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract RewardDistribution {
    address[] public participants;
    mapping(address => uint) public rewards;

    constructor(address[] memory _participants) {
        require(_participants.length >= 5, "Need at least 5 participants");
        participants = _participants;
    }

    function randomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % 10;
    }

    function distributeRewards() public {
        require(participants.length >= 5, "Insufficient participants");

        for (uint i = 0; i < 5; i++) {
            uint randomIndex = randomNumber() % participants.length;
            address winner = participants[randomIndex];
            rewards[winner] += 1 ether;  // Awarding 1 ether as a reward, adjust as necessary
        }
    }

    // Function to view the reward of a specific participant
    function viewReward(address _participant) public view returns (uint) {
        return rewards[_participant];
    }

    // Function to withdraw the reward
    function withdrawReward() public {
        uint reward = rewards[msg.sender];
        require(reward > 0, "No reward to withdraw");

        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(reward);
    }

    // Fallback function to accept ETH to the contract
    receive() external payable {}
}
