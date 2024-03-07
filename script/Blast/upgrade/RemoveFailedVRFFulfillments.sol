// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import { EnumerableSet } from "@solidstate/contracts/data/EnumerableSet.sol";
import { CollectionData, PerpetualMintStorage as Storage } from "../../../contracts/facets/PerpetualMint/Storage.sol";

struct FailedCollectionRequests {
    address collection;
    uint256[] requestIdsToRemove;
}

/// @title RemoveFailedVRFFulfillments
/// @dev RemoveFailedVRFFulfillments facet for removing failed VRF fulfillments
contract RemoveFailedVRFFulfillments {
    using EnumerableSet for EnumerableSet.UintSet;

    address private immutable operator = msg.sender;

    function removeFailedVRFFulfillments(
        FailedCollectionRequests[] calldata failedCollectionRequestsToRemove
    ) external {
        require(msg.sender == operator);

        Storage.Layout storage l = Storage.layout();

        for (uint256 i = 0; i < failedCollectionRequestsToRemove.length; ++i) {
            FailedCollectionRequests
                memory failedCollectionRequestToRemove = failedCollectionRequestsToRemove[
                    i
                ];

            for (
                uint256 j = 0;
                j < failedCollectionRequestToRemove.requestIdsToRemove.length;
                ++j
            ) {
                CollectionData storage collectionData = l.collections[
                    failedCollectionRequestToRemove.collection
                ];

                collectionData.pendingRequests.remove(
                    failedCollectionRequestToRemove.requestIdsToRemove[j]
                );
            }
        }
    }
}
