// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.21;

import { Ownable } from "@solidstate/contracts/access/ownable/Ownable.sol";
import { Pausable } from "@solidstate/contracts/security/pausable/Pausable.sol";

import { IPerpetualMint } from "./IPerpetualMint.sol";
import { PerpetualMintInternal } from "./PerpetualMintInternal.sol";
import { CollectionData, PerpetualMintStorage as Storage, VRFConfig } from "./Storage.sol";

/// @title PerpetualMint facet contract
/// @dev contains all externally called functions
contract PerpetualMint is
    IPerpetualMint,
    Ownable,
    Pausable,
    PerpetualMintInternal
{
    constructor(address vrf) PerpetualMintInternal(vrf) {}

    /// @inheritdoc IPerpetualMint
    function accruedMintEarnings()
        external
        view
        returns (uint256 accruedEarnings)
    {
        accruedEarnings = _accruedMintEarnings();
    }

    /// @inheritdoc IPerpetualMint
    function accruedProtocolFees() external view returns (uint256 accruedFees) {
        accruedFees = _accruedProtocolFees();
    }

    /// @inheritdoc IPerpetualMint
    function attemptBatchMintWithEth(
        address collection,
        uint32 numberOfMints
    ) external payable whenNotPaused {
        _attemptBatchMintWithEth(msg.sender, collection, numberOfMints);
    }

    /// @inheritdoc IPerpetualMint
    function attemptBatchMintWithMint(
        address collection,
        uint32 numberOfMints
    ) external whenNotPaused {
        _attemptBatchMintWithEth(msg.sender, collection, numberOfMints);
    }

    /// @inheritdoc IPerpetualMint
    function claimMintEarnings() external onlyOwner {
        _claimMintEarnings(msg.sender);
    }

    /// @inheritdoc IPerpetualMint
    function claimProtocolFees() external onlyOwner {
        _claimProtocolFees(msg.sender);
    }

    /// @inheritdoc IPerpetualMint
    function getCollectionMintPrice(
        address collection
    ) external view returns (uint256 mintPrice) {
        CollectionData storage collectionData = Storage.layout().collections[
            collection
        ];

        mintPrice = _getCollectionMintPrice(collectionData);
    }

    /// @inheritdoc IPerpetualMint
    function getCollectionRisk(
        address collection
    ) external view returns (uint32 risk) {
        CollectionData storage collectionData = Storage.layout().collections[
            collection
        ];

        risk = _getCollectionRisk(collectionData);
    }

    /// @inheritdoc IPerpetualMint
    function pause() external onlyOwner {
        _pause();
    }

    /// @inheritdoc IPerpetualMint
    function setCollectionMintPrice(
        address collection,
        uint256 price
    ) external onlyOwner {
        _setCollectionMintPrice(collection, price);
    }

    /// @inheritdoc IPerpetualMint
    function setCollectionRisk(
        address collection,
        uint32 risk
    ) external onlyOwner {
        _setCollectionRisk(collection, risk);
    }

    /// @inheritdoc IPerpetualMint
    function setEthToMintRatio(uint256 ratio) external onlyOwner {
        _setEthToMintRatio(ratio);
    }

    /// @inheritdoc IPerpetualMint
    function setMintFeeBP(uint32 mintFeeBP) external onlyOwner {
        _setMintFeeBP(mintFeeBP);
    }

    /// @inheritdoc IPerpetualMint
    function setVRFConfig(VRFConfig calldata config) external onlyOwner {
        _setVRFConfig(config);
    }

    /// @inheritdoc IPerpetualMint
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Chainlink VRF Coordinator callback
    /// @param requestId id of request for random values
    /// @param randomWords random values returned from Chainlink VRF coordination
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        _fulfillRandomWords(requestId, randomWords);
    }
}
