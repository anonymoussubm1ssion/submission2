pragma solidity ^0.4.19;

contract Integer_Mul {
    uint public count = 2;

    function run(uint256 input) public {
        count *= input;
    }
}
