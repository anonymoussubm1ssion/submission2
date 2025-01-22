// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../router.sol";

contract EGD_Finance {
    IPancakeRouter02 public router;
    IERC20 public U;
    IERC20 public EGD;
    address public pair;
    uint[] public rate;
    address wallet;
    uint stakeId;
    mapping(address => uint) public userTotalAmount;
    mapping(address => mapping(uint => uint)) public userStake;

    function initialize(address EGD_, address U_, address router_, address wallet_) public {
        EGD = IERC20(EGD_);
        U = IERC20(U_);
        router = IPancakeRouter02(router_);
        wallet = wallet_;
        pair = IPancakeFactory(router.factory()).getPair(address(EGD), address(U));
        rate = [200, 180, 160, 140];  // Simple rate system
    }

    function getEGDPrice() public view returns (uint) {
        uint balance1 = EGD.balanceOf(pair);
        uint balance2 = U.balanceOf(pair);
        return (balance2 * 1e18 / balance1);  
    }

    function _processReBuy(uint amount) internal {
        U.approve(address(router), amount);
        address;
        path[0] = address(U);
        path[1] = address(EGD);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, address(this), block.timestamp + 720000);
    }

    function stake(uint amount) external {
        require(amount >= 100 ether, "minimum stake");
        U.transferFrom(msg.sender, address(this), amount);
        _processReBuy(amount * 70 / 100);
        U.transfer(wallet, amount / 10);

        uint index = (block.timestamp - 1 weeks) / 365 days;
        uint tempRate = rate[index > 3 ? 3 : index];
        
        userStake[msg.sender][stakeId] = amount;
        userTotalAmount[msg.sender] += amount;
        stakeId++;
    }

    function claimReward(uint stakeId) external {
        uint amount = userStake[msg.sender][stakeId];
        require(amount > 0, "no stake");
        
        uint reward = (block.timestamp - 1 weeks) * amount * rate[0] / 100 / 86400;  //  reward calculation
        EGD.transfer(msg.sender, reward);
        
        userTotalAmount[msg.sender] -= amount;
        delete userStake[msg.sender][stakeId];
    }
}
