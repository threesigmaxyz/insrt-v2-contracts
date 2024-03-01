// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import { IPerpetualMintView } from "../IPerpetualMintView.sol";

/// @title IPerpetualMintViewBlast
/// @dev Extension interface of the PerpetualMintViewBlast facet
interface IPerpetualMintViewBlast is IPerpetualMintView {
    /// @notice returns the current blast yield risk
    /// @return risk current blast yield risk
    function blastYieldRisk() external view returns (uint32 risk);
}
