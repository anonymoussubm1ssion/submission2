pragma solidity ^0.4.24;

contract Proxy {

  address owner;

  modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    
    function forward(address callee, bytes _data) public {
      require(callee.delegatecall(_data)); 
    }

}
