// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.21;

import { IPausable } from "@solidstate/contracts/security/pausable/IPausable.sol";

import { PerpetualMintStorage as Storage, VRFConfig } from "./Storage.sol";

/// @title IPerpetualMint
/// @dev Interface of the PerpetualMint facet
interface IPerpetualMint is IPausable {
    /// @notice returns the current accrued mint earnings across all collections
    /// @return accruedEarnings the current amount of accrued mint earnings across all collections
    function accruedMintEarnings()
        external
        view
        returns (uint256 accruedEarnings);

    /// @notice returns the current accrued protocol fees
    /// @return accruedFees the current amount of accrued protocol fees
    function accruedProtocolFees() external view returns (uint256 accruedFees);

    /// @notice attempts a batch mint for the msg.sender for a single collection
    /// @param collection address of collection for mint attempts
    /// @param numberOfMints number of mints to attempt
    function attemptBatchMint(
        address collection,
        uint32 numberOfMints
    ) external payable;

    /// @notice claims all accrued mint earnings across collections
    function claimMintEarnings() external;

    /// @notice claims all accrued protocol fees
    function claimProtocolFees() external;

    /// @notice Returns the current collection-wide risk of a collection
    /// @param collection address of collection
    /// @return risk value of collection-wide risk
    function getCollectionRisk(
        address collection
    ) external view returns (uint32 risk);

    /// @notice Triggers paused state, when contract is unpaused.
    function pause() external;

    /// @notice set the mint price for a given collection
    /// @param collection address of collection
    /// @param price mint price of the collection
    function setCollectionMintPrice(address collection, uint256 price) external;

    /// @notice sets the risk of a given collection
    /// @param collection address of collection
    /// @param risk new risk value for collection
    function setCollectionRisk(address collection, uint32 risk) external;

    /// @notice sets the mint fee in basis points
    /// @param mintFeeBP mint fee in basis points
    function setMintFeeBP(uint32 mintFeeBP) external;

    /// @notice sets the Chainlink VRF config
    /// @param config VRFConfig struct holding all related data to ChainlinkVRF setup
    function setVRFConfig(VRFConfig calldata config) external;

    ///  @notice Triggers unpaused state, when contract is paused.
    function unpause() external;
}
