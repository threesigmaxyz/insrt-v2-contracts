// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "../IPerpetualMint.sol";

/// @title IPerpetualMintBlast
/// @dev Extension interface of the PerpetualMintBlast facet
interface IPerpetualMintBlast is IPerpetualMint {
    /// @notice sets the risk for Blast yield
    /// @param risk risk of Blast yield
    function setBlastYieldRisk(uint32 risk) external;
}
