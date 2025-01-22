// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenGiveaway {
    mapping(address => uint256) public balances;
    uint256 public totalTokens = 10000;
    uint256 public giveawayThreshold = 1000;

    constructor() {
        balances[msg.sender] = totalTokens;
    }

    function participateInGiveaway() external {
        require(balances[msg.sender] == 0, "Already participated");
        uint random = uint(keccak256(abi.encodePacked(msg.sender, totalTokens))) % giveawayThreshold;

        if (random == 0) {
            balances[msg.sender] += 100;
            balances[address(this)] -= 100;
        }
    }
}
