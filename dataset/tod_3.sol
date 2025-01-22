// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableSwap {
    address public pancakeRouter;
    address public ssToken;

    constructor(address _pancakeRouter, address _ssToken) {
        pancakeRouter = _pancakeRouter;
        ssToken = _ssToken;
    }

    function swapBNBForSSToken(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = IPancakeRouter02(pancakeRouter).WETH();
        path[1] = ssToken;

        IPancakeRouter02(pancakeRouter).swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, address(this), block.timestamp);
    }
}