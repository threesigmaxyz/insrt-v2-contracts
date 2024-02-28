// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import { Core } from "../Core.sol";
import { GasMode, IBlast, YieldMode } from "./IBlast.sol";
import { IBlastPoints } from "./IBlastPoints.sol";

/// @title CoreBlast
/// @dev The Blast-specific Core Diamond.
contract CoreBlast is Core {
    constructor(
        address mintToken,
        string memory receiptName,
        string memory receiptSymbol
    ) Core(mintToken, receiptName, receiptSymbol) {
        // Configure the yield & claimable gas settings for the Blast Core diamond
        IBlast(0x4300000000000000000000000000000000000002).configure(
            YieldMode.CLAIMABLE,
            GasMode.CLAIMABLE,
            address(this)
        );

        // Configure the points operator for the Blast Core diamond on Blast mainnet
        IBlastPoints(0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800)
            .configurePointsOperator(
                0x4E85280e5C025A99bCB815759a4b03Fd3f48E936
            );
    }
}
