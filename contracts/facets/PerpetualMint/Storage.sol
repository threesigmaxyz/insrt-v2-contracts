// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "./types/DataTypes.sol";

/// @title PerpetualMintStorage
/// @dev defines storage layout for the PerpetualMint facet
library PerpetualMintStorage {
    struct Layout {
        /// @dev $MINT mint for collection consolation tiers data
        TiersData tiers;
        /// @dev all variables related to Chainlink VRF configuration
        VRFConfig vrfConfig;
        /// @dev mint for collection consolation fee in basis points
        uint32 collectionConsolationFeeBP;
        /// @dev mint fee in basis points
        uint32 mintFeeBP;
        /// @dev redemption fee in basis points
        uint32 redemptionFeeBP;
        /// @dev The minimum threshold for the VRF subscription balance in LINK tokens.
        uint96 vrfSubscriptionBalanceThreshold;
        /// @dev amount of consolation fees accrued in ETH (native token) from mint attempts
        uint256 consolationFees;
        /// @dev amount of mint earnings accrued in ETH (native token) from mint attempts
        uint256 mintEarnings;
        /// @dev amount of protocol fees accrued in ETH (native token) from mint attempts
        uint256 protocolFees;
        /// @dev ratio of ETH (native token) to $MINT for mint attempts using $MINT as payment
        uint256 ethToMintRatio;
        /// @dev mapping of collection addresses to collection-specific data
        mapping(address collection => CollectionData) collections;
        /// @dev mapping of mint attempt VRF requests which have not yet been fulfilled
        mapping(uint256 requestId => RequestData) requests;
        /// @dev address of the current $MINT token
        address mintToken;
        /// @dev status of whether redeem is paused
        bool redeemPaused;
        /// @dev mint for $MINT consolation fee in basis points
        uint32 mintTokenConsolationFeeBP;
        /// @dev $MINT mint for $MINT consolation tiers data
        MintTokenTiersData mintTokenTiers;
        /// @dev default mint referral fee for a collection in basis points
        uint32 defaultCollectionReferralFeeBP;
        /// @dev the risk or probability of winning yield from a mint attempt, applicable only to Blast as of writing
        uint32 yieldRisk;
        /// @dev mint for ETH consolation fee in basis points
        uint32 mintForEthConsolationFeeBP;
        /// @dev mint for ETH mint earnings pool buffer in basis points
        uint32 mintEarningsBufferBP;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("insrt.contracts.storage.PerpetualMint");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
