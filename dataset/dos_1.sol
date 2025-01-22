// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserRegistry {
    // Struct to store user details
    struct User {
        uint id;
        string name;
        address wallet;
    }

    // Mapping to store registered users by their ID
    mapping(uint => User) public users;
    uint public userCount;

    // Event to log user registration
    event UserRegistered(uint id, string name, address wallet);

    // Function to register a new user
    function registerUser(string memory _name) public {
        userCount++;
        users[userCount] = User(userCount, _name, msg.sender);
        emit UserRegistered(userCount, _name, msg.sender);
    }

    function deregisterAllUsers() public {
        for (uint i = 1; i <= userCount; i++) {
            delete users[i];
        }
        userCount = 0; // Reset the user count
    }

    // Function to get user details by ID
    function getUser(uint _id) public view returns (string memory, address) {
        User memory user = users[_id];
        return (user.name, user.wallet);
    }
}
