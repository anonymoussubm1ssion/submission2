pragma solidity ^0.8.13;

contract MonarchOfEther {
    address public ruler;
    uint public treasury;

    function seizeCrown() external payable {
        require(msg.value > treasury, "Need to pay more to seize the crown");

        (bool success,) = ruler.call{value:treasury}("");
        require(success, "Failed to transfer Ether");

        treasury = msg.value;
        ruler = msg.sender;
    }
}
