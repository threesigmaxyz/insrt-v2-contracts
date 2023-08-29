// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.21;

import "./types/DataTypes.sol";

/// @title PerpetualMintStorage
/// @dev defines storage layout for the PerpetualMint facet
library PerpetualMintStorage {
    struct Layout {
        /// @dev all variables related to Chainlink VRF configuration
        VRFConfig vrfConfig;
        /// @dev tokenId for minting consolation prize
        /// TODO: NEEDS TO BE REWORKED
        uint64 id;
        /// @dev mint fee in basis points
        uint32 mintFeeBP;
        /// @dev amount of mint earnings accrued in ETH (native token) from mint attempts
        uint256 mintEarnings;
        /// @dev amount of protocol fees accrued in ETH (native token) from mint attempts
        uint256 protocolFees;
        /// @dev mapping of collection addresses to collection-specific data
        mapping(address collection => CollectionData) collections;
        /// @dev mapping of mint attempt VRF requests which have not yet been fulfilled
        mapping(uint256 requestId => RequestData) requests;
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
