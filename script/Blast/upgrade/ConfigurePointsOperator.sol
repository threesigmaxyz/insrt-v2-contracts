// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import { IBlastPoints } from "../../../contracts/diamonds/Core/Blast/IBlastPoints.sol";

/// @title ConfigurePointsOperator
/// @dev ConfigurePointsOperator facet for configuring Blast Points operation
contract ConfigurePointsOperator {
    address private immutable operator;

    constructor(address _newOperator) {
        operator = _newOperator;
    }

    function configurePointsOperator() external {
        IBlastPoints(0x2fc95838c71e76ec69ff817983BFf17c710F34E0) // Blast Sepolia
            .configurePointsOperator(operator);
    }
}
