pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract SimpleDEX {
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public reserveA;
    uint256 public reserveB;

    constructor(IERC20 _tokenA, IERC20 _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function addLiquidity(uint256 _amountA, uint256 _amountB) public {
        require(_amountA > 0 && _amountB > 0, "Insufficient liquidity");
        tokenA.transferFrom(msg.sender, address(this), _amountA);
        tokenB.transferFrom(msg.sender, address(this), _amountB);
        reserveA += _amountA;
        reserveB += _amountB;
    }

    function swap(uint256 _amountA) public returns (uint256 amountB) {
        amountB = (_amountA * reserveB) / reserveA; 
        require(amountB > 0, "Insufficient output amount");
        tokenA.transferFrom(msg.sender, address(this), _amountA);
        tokenB.transfer(msg.sender, amountB);
        reserveA += _amountA;
        reserveB -= amountB;
        return amountB;
    }
}