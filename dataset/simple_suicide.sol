pragma solidity ^0.8.0;


contract ExtendedContract {
    // Mapping to store balances of addresses
    mapping(address => uint) public balances;

    // Event to emit when a deposit is made
    event Deposit(address indexed sender, uint amount);

    // Function to allow deposits to the contract
    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Function to withdraw funds from the contract
    function withdraw(uint amount) public payable {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    // Function to check the contract's balance
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function kill() public payable {
    selfdestruct(payable(msg.sender));
}

}