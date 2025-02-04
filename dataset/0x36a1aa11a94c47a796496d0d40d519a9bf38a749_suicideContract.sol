// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;

library SafeMath {
    // SafeMath library implementation (same as before)
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Wallet {

    using SafeMath for uint256;

    address payable internal _owner;
    uint256 internal _totalBalance;
    mapping(address => uint256) internal _wallets;
    
    bool internal paused;
    
    event PausedEvent(address by);
    event UnpausedEvent(address by);
    event DepositEvent(address to, uint256 value);
    event DepositForEvent(address from, address to, uint256 value);
    event WithdrawEvent(address from, uint256 value);
    event WithdrawForEvent(address from, address to, uint256 value);

    modifier onlyOwner {
        require(msg.sender == _owner, "Only the owner of this wallet can perform this action");
        _;
    }
    
    modifier onlyUnpaused {
        require(paused == false, "The contract is currently paused.");
        _;
    }
    
    modifier onlyPaused {
        require(paused == true, "The contract is not currently paused.");
        _;
    }
    
    constructor() public {
        _owner = msg.sender;
        paused = false;
    }
    
    receive() external payable {
        revert("Use the deposit() function instead!");
    }
    
    function pause() external onlyOwner onlyUnpaused {
        paused = true;
        emit PausedEvent(msg.sender);
    }
    
    function unPause() external onlyOwner onlyPaused {
        paused = false;
        emit UnpausedEvent(msg.sender);
    }
    
    function balanceOf(address wallet) public view returns(uint256) {
        return _wallets[wallet];
    }
    
    function totalBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function owner() external view returns (address) {
        return _owner;
    }

    // Vulnerable function to allow anyone to set themselves as the owner
    function setOwner(address newOwner) external {
        _owner = newOwner;
    }
    
    function deposit() external payable {
        require(msg.value > 0, "No ether sent.");
        _wallets[msg.sender] = _wallets[msg.sender].add(msg.value);
        emit DepositEvent(msg.sender, msg.value);
    }
    
    function depositFor(address wallet) external payable {
         require(msg.value > 0, "No ether sent.");
         emit DepositForEvent(msg.sender, wallet, msg.value);
        _wallets[wallet] = _wallets[wallet].add(msg.value);
    }

    function withdraw() external onlyUnpaused {
        require(_wallets[msg.sender] > 0, "You have nothing to withdraw");
        payable(msg.sender).transfer(_wallets[msg.sender]);
        emit WithdrawEvent(msg.sender, _wallets[msg.sender]);
        _wallets[msg.sender] = 0;
    }
    
    function withdrawFor(address wallet) external onlyUnpaused {
        require(_wallets[msg.sender] > 0, "You have nothing to withdraw");
        payable(wallet).transfer(_wallets[msg.sender]);
        emit WithdrawForEvent(msg.sender, wallet,  _wallets[msg.sender]);
        _wallets[msg.sender] = 0;
    }
    
    function close() public onlyUnpaused onlyOwner { 
        selfdestruct(_owner); 	
    }

}
