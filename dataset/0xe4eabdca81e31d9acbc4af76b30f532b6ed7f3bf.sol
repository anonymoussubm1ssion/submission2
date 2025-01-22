pragma solidity ^0.4.19;

contract Honey
{
    address public Owner = msg.sender;
   
    function()
    public
    payable
    {

    }
   
    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        { 
            msg.sender.transfer(this.balance);
        }   
    }
    
    function withdraw()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }
    
    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        adr.call.value(msg.value)(data);
    }
}