pragma solidity ^0.8.0;

contract GameOfChance {
    uint256 public seed;
    uint256 public result;

    function setSeed(uint256 _seed) public {
        seed = _seed; 
    }

    function playGame() public {
     
        uint256 tempResult = seed; 
        for (uint256 i = 0; i < 10; i++) {
            tempResult = uint256(keccak256(abi.encodePacked(tempResult, i))); 
        }

        result = tempResult % 100; 
    }
}