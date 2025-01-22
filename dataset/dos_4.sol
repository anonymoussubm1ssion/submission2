// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TokenDistribution {
    address[] public users;
    uint public rewardAmount;

    event RewardDistributed(address indexed recipient, uint amount);

    // Function to register users in the system
    function registerUser() external {
        users.push(msg.sender);
    }

    // Function to distribute rewards to all users
    function distributeTokens() external {
        for (uint i = 0; i < users.length; i++) {
            (bool sent, ) = users[i].call{value: rewardAmount}("");
            require(sent, "Failed to send reward");
            emit RewardDistributed(users[i], rewardAmount);
        }
    }

    // Function to set the reward amount
    function setRewardAmount(uint _amount) external {
        rewardAmount = _amount;
    }

    // Function to get the number of registered users
    function getUsersCount() external view returns (uint) {
        return users.length;
    }
}
