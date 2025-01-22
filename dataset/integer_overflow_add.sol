pragma solidity ^0.4.19;

contract testContract {
    uint public count = 1;

    function run(uint256 input) public {
        count += input;
    }
}
