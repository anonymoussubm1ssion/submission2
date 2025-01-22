// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract StablecoinLending {
    IERC20 public collateralToken; // e.g., ETH
    IERC20 public stablecoin; // e.g., USDC

    uint256 public minCollateralizationRatio = 150; // 150%
    uint256 public liquidationThreshold = 130; // 130%

    struct Loan {
        uint256 loanAmount;
        uint256 collateralAmount;
    }

    mapping(address => Loan) public loans;

    event LoanTaken(address indexed borrower, uint256 loanAmount, uint256 collateralAmount);
    event CollateralDeposited(address indexed borrower, uint256 amount);
    event CollateralWithdrawn(address indexed borrower, uint256 amount);
    event LoanRepaid(address indexed borrower, uint256 amount);
    event Liquidation(address indexed liquidator, address indexed borrower);

    modifier onlyBorrower(address _borrower) {
        require(msg.sender == _borrower, "Not the borrower");
        _;
    }

    constructor(IERC20 _collateralToken, IERC20 _stablecoin) {
        collateralToken = _collateralToken;
        stablecoin = _stablecoin;
    }

    function depositCollateral(uint256 _collateralAmount) external {
        require(_collateralAmount > 0, "Collateral amount must be greater than zero");
        collateralToken.transferFrom(msg.sender, address(this), _collateralAmount);
        loans[msg.sender].collateralAmount += _collateralAmount;

        emit CollateralDeposited(msg.sender, _collateralAmount);
    }

    function borrow(uint256 _borrowAmount) external {
        uint256 requiredCollateral = (_borrowAmount * minCollateralizationRatio) / 100;
        require(loans[msg.sender].collateralAmount >= requiredCollateral, "Insufficient collateral");

        loans[msg.sender].loanAmount += _borrowAmount;
        stablecoin.transfer(msg.sender, _borrowAmount);

        emit LoanTaken(msg.sender, _borrowAmount, loans[msg.sender].collateralAmount);
    }

    function repayLoan(uint256 _repayAmount) external onlyBorrower(msg.sender) {
        require(_repayAmount > 0, "Repay amount must be greater than zero");
        require(_repayAmount <= loans[msg.sender].loanAmount, "Repay amount exceeds loan amount");

        stablecoin.transferFrom(msg.sender, address(this), _repayAmount);
        loans[msg.sender].loanAmount -= _repayAmount;

        emit LoanRepaid(msg.sender, _repayAmount);
    }

    function withdrawCollateral(uint256 _collateralAmount) external onlyBorrower(msg.sender) {
        uint256 availableCollateral = loans[msg.sender].collateralAmount;
        uint256 minCollateralRequired = (loans[msg.sender].loanAmount * minCollateralizationRatio) / 100;
        require(availableCollateral >= minCollateralRequired + _collateralAmount, "Collateral below minimum requirement");

        loans[msg.sender].collateralAmount -= _collateralAmount;
        collateralToken.transfer(msg.sender, _collateralAmount);

        emit CollateralWithdrawn(msg.sender, _collateralAmount);
    }

    function liquidate(address _borrower) external {
        uint256 currentCollateralValue = getCollateralTokenPrice() * loans[_borrower].collateralAmount;
        uint256 requiredCollateral = (loans[_borrower].loanAmount * liquidationThreshold) / 100;
        
        require(currentCollateralValue < requiredCollateral, "Borrower is not undercollateralized");

        // Transfer the collateral to the liquidator
        collateralToken.transfer(msg.sender, loans[_borrower].collateralAmount);

        // Clear the loan
        delete loans[_borrower];

        emit Liquidation(msg.sender, _borrower);
    }

    function getCollateralTokenPrice() public view returns (uint256) {
        // Simplified for this example; in practice, use a secure, decentralized oracle
        return 1000; // Example: 1 ETH = 1000 USD
    }
}
