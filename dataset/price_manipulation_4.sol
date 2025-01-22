// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./interfaces/IERC20.sol";

contract OurAMM {
    address public USDCContract;

    constructor(address _USDC) {
        USDCContract = _USDC;
    }

    function getETHBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getUSDCBalance() public view returns (uint256) {
        return IERC20(USDCContract).balanceOf(address(this));
    }

    function getETHToUSDCPrice() external view returns (uint256) {
        return ((getETHBalance() * 1e6) / getUSDCBalance()); 
    }

    function getUSDCToETHPrice() external view returns (uint256) {
        return (getUSDCBalance() / getETHBalance()) * 1e6; 
    }

    function estimateETHForUSDC(uint256 usdcAmount)
        public
        view
        returns (uint256)
    {
        return (getETHBalance() * usdcAmount) / (getUSDCBalance() + usdcAmount);
    }

    function estimateUSDCForETH(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        return (getUSDCBalance() * ethAmount) / (getETHBalance() + ethAmount);
    }

    function executeSwap(address fromToken, uint256 amount)
        external
        payable
        returns (uint256)
    {
        uint256 ethAmount = getETHBalance();
        uint256 usdcAmount = getUSDCBalance();

        uint256 outputAmount;
        if (fromToken == USDCContract) {
            outputAmount = (ethAmount * amount) / (usdcAmount + amount);
            IERC20(USDCContract).transferFrom(msg.sender, address(this), amount);
            (bool success, ) = msg.sender.call{value: outputAmount}(new bytes(0));
            require(success, "ETH transfer failed");
        } else {
            outputAmount = (usdcAmount * amount) / (ethAmount); // ethAmount includes the sent ETH
            require(msg.value == amount, "ETH sent does not match amount");
            IERC20(USDCContract).transfer(msg.sender, outputAmount);
        }
        return outputAmount;
    }

    receive() external payable {}
}
