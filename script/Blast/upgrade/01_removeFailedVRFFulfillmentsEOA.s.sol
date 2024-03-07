// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import { IDiamondWritableInternal } from "@solidstate/contracts/proxy/diamond/writable/IDiamondWritableInternal.sol";

import { FailedCollectionRequests, RemoveFailedVRFFulfillments } from "./RemoveFailedVRFFulfillments.sol";
import { ICore } from "../../../contracts/diamonds/Core/ICore.sol";

/// @title RemoveFailedVRFFulfillmentsEOA
/// @dev Removes failed VRF fulfillments by deploying a RemoveFailedVRFFulfillments facet, sign and submitting a diamondCut
/// of the facet to the Core diamond, calling the removeFailedVRFFulfillments function, and then sign & submitting a diamondCut removal using an externally owned account
contract RemoveFailedVRFFulfillmentsEOA is Script, Test {
    /// @dev runs the script logic
    function run() external {
        // read deployer private key
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_KEY");

        // get CoreBlast PerpetualMint diamond address
        address coreBlast = vm.envAddress("CORE_BLAST_ADDRESS");

        address[11] memory failedVRFFulfillmentCollections = [
            0x0000000000000000000000000000000000000038,
            0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB,
            0x0000000000000000000000000000000000000049,
            0x0000000000000000000000000000000000000051,
            0x0000000000000000000000000000000000000001,
            0x0000000000000000000000000000000000000046,
            0x0000000000000000000000000000000000000047,
            0x0000000000000000000000000000000000000043,
            0x0000000000000000000000000000000000000042,
            0x39ee2c7b3cb80254225884ca001F57118C8f21B6,
            0x0000000000000000000000000000000000000037
        ];

        uint256[][] memory failedVRFFulfillmentRequestIds = new uint256[][](
            failedVRFFulfillmentCollections.length
        );

        failedVRFFulfillmentRequestIds[0] = new uint256[](1);
        failedVRFFulfillmentRequestIds[0][0] = 2;

        failedVRFFulfillmentRequestIds[1] = new uint256[](3);
        failedVRFFulfillmentRequestIds[1][0] = 3;
        failedVRFFulfillmentRequestIds[1][1] = 5;
        failedVRFFulfillmentRequestIds[1][2] = 7;

        // Repeat for the rest of the array initialization
        failedVRFFulfillmentRequestIds[2] = new uint256[](1);
        failedVRFFulfillmentRequestIds[2][0] = 4;

        failedVRFFulfillmentRequestIds[3] = new uint256[](2);
        failedVRFFulfillmentRequestIds[3][0] = 6;
        failedVRFFulfillmentRequestIds[3][1] = 13;

        // Initialize other elements as needed
        failedVRFFulfillmentRequestIds[4] = new uint256[](1);
        failedVRFFulfillmentRequestIds[4][0] = 8;

        failedVRFFulfillmentRequestIds[5] = new uint256[](1);
        failedVRFFulfillmentRequestIds[5][0] = 9;

        failedVRFFulfillmentRequestIds[6] = new uint256[](1);
        failedVRFFulfillmentRequestIds[6][0] = 10;

        failedVRFFulfillmentRequestIds[7] = new uint256[](1);
        failedVRFFulfillmentRequestIds[7][0] = 11;

        failedVRFFulfillmentRequestIds[8] = new uint256[](1);
        failedVRFFulfillmentRequestIds[8][0] = 12;

        failedVRFFulfillmentRequestIds[9] = new uint256[](1);
        failedVRFFulfillmentRequestIds[9][0] = 14;

        failedVRFFulfillmentRequestIds[10] = new uint256[](1);
        failedVRFFulfillmentRequestIds[10][0] = 15;

        FailedCollectionRequests[]
            memory failedRequests = new FailedCollectionRequests[](
                failedVRFFulfillmentCollections.length
            );

        for (uint256 i = 0; i < failedVRFFulfillmentCollections.length; ++i) {
            console.log(
                "Failed Collection: ",
                failedVRFFulfillmentCollections[i]
            );

            uint256[] memory requestIdsToRemove = new uint256[](
                failedVRFFulfillmentRequestIds[i].length
            );

            for (uint256 j = 0; j < requestIdsToRemove.length; ++j) {
                requestIdsToRemove[j] = failedVRFFulfillmentRequestIds[i][j];
            }

            FailedCollectionRequests
                memory failedCollectionRequest = FailedCollectionRequests({
                    collection: failedVRFFulfillmentCollections[i],
                    requestIdsToRemove: requestIdsToRemove
                });

            failedRequests[i] = failedCollectionRequest;

            emit log_named_array(
                "Failed Request Ids: ",
                failedCollectionRequest.requestIdsToRemove
            );
        }

        vm.startBroadcast(deployerPrivateKey);

        // deploy new RemoveFailedVRFFulfillments facet
        RemoveFailedVRFFulfillments removeFailedVRFFulfillments = new RemoveFailedVRFFulfillments();

        console.log(
            "New RemoveFailedVRFFulfillments Facet Address: ",
            address(removeFailedVRFFulfillments)
        );
        console.log("CoreBlast Address: ", coreBlast);

        // get RemoveFailedVRFFulfillments facet cuts
        ICore.FacetCut[]
            memory removeFailedVRFFulfillmentsFacetCuts = getRemoveFailedVRFFulfillmentFacetCuts(
                address(removeFailedVRFFulfillments)
            );

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](1);

        facetCuts[0] = removeFailedVRFFulfillmentsFacetCuts[0];

        // cut RemoveFailedVRFFulfillments into CoreBlast
        ICore(payable(coreBlast)).diamondCut(facetCuts, address(0), "");

        // remove failed VRF fulfillments
        RemoveFailedVRFFulfillments(payable(coreBlast))
            .removeFailedVRFFulfillments(failedRequests);

        // console.log("Failed VRF Fulfillments Removed: ", blastPointsOperator);

        // get removal RemoveFailedVRFFulfillments facet cuts
        ICore.FacetCut[]
            memory removeRemoveFailedVRFFulfillmentsFacetCuts = getRemoveRemoveFailedVRFFulfillmentsFacetCuts();

        facetCuts[0] = removeRemoveFailedVRFFulfillmentsFacetCuts[0];

        // cut out & remove RemoveFailedVRFFulfillments from CoreBlast
        ICore(payable(coreBlast)).diamondCut(facetCuts, address(0), "");

        vm.stopBroadcast();
    }

    /// @dev provides the facet cuts for cutting RemoveFailedVRFFulfillments facet into CoreBlast
    /// @param facetAddress address of RemoveFailedVRFFulfillments facet
    function getRemoveFailedVRFFulfillmentFacetCuts(
        address facetAddress
    ) internal pure returns (ICore.FacetCut[] memory) {
        /// map the RemoveFailedVRFFulfillments function selectors to their respective interfaces
        bytes4[]
            memory removeFailedVRFFulfillmentFunctionSelectors = new bytes4[](
                1
            );

        removeFailedVRFFulfillmentFunctionSelectors[
            0
        ] = RemoveFailedVRFFulfillments.removeFailedVRFFulfillments.selector;

        ICore.FacetCut
            memory removeFailedVRFFulfillmentsFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.ADD,
                    selectors: removeFailedVRFFulfillmentFunctionSelectors
                });

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](1);

        facetCuts[0] = removeFailedVRFFulfillmentsFacetCut;

        return facetCuts;
    }

    /// @dev provides the facet cuts for removing & cutting out the RemoveFailedVRFFulfillments facet from CoreBlast
    function getRemoveRemoveFailedVRFFulfillmentsFacetCuts()
        internal
        pure
        returns (ICore.FacetCut[] memory)
    {
        /// map the RemoveFailedVRFFulfillments function selectors to their respective interfaces
        bytes4[]
            memory removeFailedVRFFulfillmentFunctionSelectors = new bytes4[](
                1
            );

        removeFailedVRFFulfillmentFunctionSelectors[
            0
        ] = RemoveFailedVRFFulfillments.removeFailedVRFFulfillments.selector;

        ICore.FacetCut
            memory removeFailedVRFFulfillmentsFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: address(0),
                    action: IDiamondWritableInternal.FacetCutAction.REMOVE,
                    selectors: removeFailedVRFFulfillmentFunctionSelectors
                });

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](1);

        facetCuts[0] = removeFailedVRFFulfillmentsFacetCut;

        return facetCuts;
    }
}
