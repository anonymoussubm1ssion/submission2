// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// Simplified decentralized exchange based on UniswapV1, with a price manipulation vulnerability.
/// Please note that this contract should not be used in production environments due to significant security risks.
contract WackySwap is ERC20 {
    using SafeERC20 for IERC20;

    
    // Immutable tokens used in the exchange: tokenA and tokenB
    IERC20 private immutable tokenA;
    IERC20 private immutable tokenB;

  
    constructor(
        address _tokenA,
        address _tokenB,
        string memory _liquidityTokenName,
        string memory _liquidityTokenSymbol
    ) ERC20(_liquidityTokenName, _liquidityTokenSymbol) {
        tokenA = IERC20(_tokenA);  // Token A used for liquidity and trading
        tokenB = IERC20(_tokenB);  // Token B used for liquidity and trading
    }

   
    /// @dev Adds liquidity to the exchange, and mints liquidity tokens accordingly.
    function addLiquidity(uint256 tokenAAmount, uint256 maxTokenBAmount)
        external
        returns (uint256 liquidityTokensMinted)
    {
        if (getTotalLiquidity() > 0) {
            uint256 tokenAReserve = tokenA.balanceOf(address(this));
            uint256 tokenBAmountToDeposit = getTokenBToDepositBasedOnTokenA(tokenAAmount);

            liquidityTokensMinted = (tokenAAmount * getTotalLiquidity()) / tokenAReserve;
            _mintLiquidityAndTransfer(tokenAAmount, tokenBAmountToDeposit, liquidityTokensMinted);
        } else {
            _mintLiquidityAndTransfer(tokenAAmount, maxTokenBAmount, tokenAAmount);
            liquidityTokensMinted = tokenAAmount;  // Initial liquidity contribution
        }
    }

    /// @dev Helper function for minting liquidity tokens and transferring deposited tokens
    function _mintLiquidityAndTransfer(
        uint256 tokenAAmount,
        uint256 tokenBAmount,
        uint256 liquidityTokensMinted
    ) private {
        _mint(msg.sender, liquidityTokensMinted);  // Mint liquidity tokens to the sender

        // Transfer deposited tokens to the contract
        tokenA.safeTransferFrom(msg.sender, address(this), tokenAAmount);
        tokenB.safeTransferFrom(msg.sender, address(this), tokenBAmount);
    }

    /// @dev Removes liquidity from the exchange, burning the specified liquidity tokens
    function removeLiquidity(uint256 liquidityTokensToBurn) external {
        uint256 tokenAWithdrawAmount = 
            (liquidityTokensToBurn * tokenA.balanceOf(address(this))) / getTotalLiquidity();
        uint256 tokenBWithdrawAmount = 
            (liquidityTokensToBurn * tokenB.balanceOf(address(this))) / getTotalLiquidity();

        _burn(msg.sender, liquidityTokensToBurn);  // Burn the liquidity tokens

        // Transfer the withdrawn tokens to the sender
        tokenA.safeTransfer(msg.sender, tokenAWithdrawAmount);
        tokenB.safeTransfer(msg.sender, tokenBWithdrawAmount);
    }

    /// @dev Calculates the output amount based on the input amount and reserves.
    function calculateOutputBasedOnInput(uint256 inputAmount, uint256 inputReserves, uint256 outputReserves)
        public
        pure
        returns (uint256 outputAmount)
    {
        uint256 inputAmountWithFee = inputAmount * 1000;
        uint256 numerator = inputAmountWithFee * outputReserves;
        uint256 denominator = (inputReserves * 1000) + inputAmountWithFee;
        return numerator / denominator;  // Calculated output amount after fee adjustment
    }

    /// @dev Calculates the input amount required to achieve a given output amount.
    function calculateInputBasedOnOutput(uint256 outputAmount, uint256 inputReserves, uint256 outputReserves)
        public
        pure
        returns (uint256 inputAmount)
    {
        return ((inputReserves * outputAmount) * 1000) / ((outputReserves - outputAmount) * 1000);
    }

    /// @dev Executes a swap where the input amount is specified and the output amount is calculated.
    function executeSwap(IERC20 fromToken, uint256 amount, IERC20 toToken) public {
        uint256 fromTokenReserves = fromToken.balanceOf(address(this));
        uint256 toTokenReserves = toToken.balanceOf(address(this));
        uint256 outputAmount = calculateOutputBasedOnInput(amount, fromTokenReserves, toTokenReserves);

        _executeSwap(fromToken, amount, toToken, outputAmount);  // Perform the actual swap
    }

    /// @dev Executes a swap where the output amount is specified and the input amount is calculated.
    function executeSwapExactOutput(IERC20 fromToken, IERC20 toToken, uint256 outputAmount)
        public
        returns (uint256 inputAmount)
    {
        uint256 fromTokenReserves = fromToken.balanceOf(address(this));
        uint256 toTokenReserves = toToken.balanceOf(address(this));

        inputAmount = calculateInputBasedOnOutput(outputAmount, fromTokenReserves, toTokenReserves);

        _executeSwap(fromToken, inputAmount, toToken, outputAmount);  // Perform the actual swap
    }

    /// @dev Internal swap function that transfers tokens between the sender and the contract.
    function _executeSwap(IERC20 fromToken, uint256 inputAmount, IERC20 toToken, uint256 outputAmount) private {
        fromToken.safeTransferFrom(msg.sender, address(this), inputAmount);  // Transfer input tokens
        toToken.safeTransfer(msg.sender, outputAmount);  // Transfer output tokens to sender
    }


    /// @dev Calculates how much tokenB to deposit based on the amount of tokenA.
    function getTokenBToDepositBasedOnTokenA(uint256 tokenAAmount) public view returns (uint256) {
        uint256 tokenBReserves = tokenB.balanceOf(address(this));
        uint256 tokenAReserves = tokenA.balanceOf(address(this));
        return (tokenAAmount * tokenBReserves) / tokenAReserves;
    }

    /// @dev Returns the total supply of liquidity tokens in the exchange.
    function getTotalLiquidity() public view returns (uint256) {
        return totalSupply();
    }

    /// @dev Returns the address of tokenB.
    function getTokenBAddress() external view returns (address) {
        return address(tokenB);
    }

    /// @dev Returns the address of tokenA.
    function getTokenAAddress() external view returns (address) {
        return address(tokenA);
    }

    /// @dev Returns the price of tokenA in terms of tokenB.
    function getTokenAPriceInTokenB() external view returns (uint256) {
        return calculateOutputBasedOnInput(
            1e18, tokenA.balanceOf(address(this)), tokenB.balanceOf(address(this))
        );
    }

    /// @dev Returns the price of tokenB in terms of tokenA.
    function getTokenBPriceInTokenA() external view returns (uint256) {
        return calculateOutputBasedOnInput(
            1e18, tokenB.balanceOf(address(this)), tokenA.balanceOf(address(this))
        );
    }
}
