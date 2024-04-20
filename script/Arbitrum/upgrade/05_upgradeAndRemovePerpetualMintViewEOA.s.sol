// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";

import { IDiamondWritable } from "@solidstate/contracts/proxy/diamond/writable/IDiamondWritable.sol";
import { IDiamondWritableInternal } from "@solidstate/contracts/proxy/diamond/writable/IDiamondWritableInternal.sol";
import { IPausable } from "@solidstate/contracts/security/pausable/IPausable.sol";

import { ICore } from "../../../contracts/diamonds/Core/ICore.sol";
import { IPerpetualMintView } from "../../../contracts/facets/PerpetualMint/IPerpetualMintView.sol";
import { PerpetualMintView } from "../../../contracts/facets/PerpetualMint/PerpetualMintView.sol";

/// @title UpgradeAndRemovePerpetualMintViewArbEOA
/// @dev Upgrades and removes certain functions from the PerpetualMintView facet by deploying a new PerpetualMintView facet and signing and submitting
/// a diamondCut of the upgrade & removal PerpetualMintView facets to the Core diamond using an externally owned account
contract UpgradeAndRemovePerpetualMintViewArbEOA is Script {
    /// @dev runs the script logic
    function run() external {
        // read deployer private key
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_KEY");

        // get Core PerpetualMint diamond address
        address core = vm.envAddress("CORE_ADDRESS");

        // get VRF Coordinator address
        address VRF_COORDINATOR = vm.envAddress("VRF_COORDINATOR");

        vm.startBroadcast(deployerPrivateKey);

        // deploy PerpetualMintView facet
        PerpetualMintView perpetualMintView = new PerpetualMintView(
            VRF_COORDINATOR
        );

        console.log(
            "New PerpetualMintView Facet Address: ",
            address(perpetualMintView)
        );
        console.log("Core Address: ", core);
        console.log("VRF Coordinator Address: ", VRF_COORDINATOR);

        // get new PerpetualMintView facet cuts
        ICore.FacetCut[]
            memory newPerpetualMintViewFacetCuts = getNewPerpetualMintViewFacetCuts(
                address(perpetualMintView)
            );

        // get removal PerpetualMintView facet cuts
        ICore.FacetCut[]
            memory removalPerpetualMintViewFacetCuts = getRemovalPerpetualMintViewFacetCuts(
                address(0) // removal target addresses are expected to be zero address
            );

        // get replacement PerpetualMintView facet cuts
        ICore.FacetCut[]
            memory replacementPerpetualMintViewFacetCuts = getReplacementPerpetualMintViewFacetCuts(
                address(perpetualMintView)
            );

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](4);

        facetCuts[0] = newPerpetualMintViewFacetCuts[0];
        facetCuts[1] = removalPerpetualMintViewFacetCuts[0];
        facetCuts[2] = replacementPerpetualMintViewFacetCuts[0];
        facetCuts[3] = replacementPerpetualMintViewFacetCuts[1];

        // cut PerpetualMintView into Core
        ICore(payable(core)).diamondCut(facetCuts, address(0), "");

        vm.stopBroadcast();
    }

    /// @dev provides the new facet cuts for cutting PerpetualMintView facet into Core
    /// @param viewFacetAddress address of PerpetualMintView facet
    function getNewPerpetualMintViewFacetCuts(
        address viewFacetAddress
    ) internal pure returns (ICore.FacetCut[] memory) {
        // map the PerpetualMintView related function selectors to their respective interfaces
        bytes4[] memory perpetualMintViewFunctionSelectors = new bytes4[](1);

        perpetualMintViewFunctionSelectors[0] = bytes4(
            keccak256(
                "calculateMintResult(address,uint32,uint256,uint256,uint256)"
            )
        );

        ICore.FacetCut
            memory perpetualMintViewFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: viewFacetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.ADD,
                    selectors: perpetualMintViewFunctionSelectors
                });

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](1);

        facetCuts[0] = perpetualMintViewFacetCut;

        return facetCuts;
    }

    /// @dev provides the removal facet cuts for removing PerpetualMintView facet functions from Core
    /// @param facetAddress target address to remove
    function getRemovalPerpetualMintViewFacetCuts(
        address facetAddress
    ) internal pure returns (ICore.FacetCut[] memory) {
        // map the PerpetualMintView related function selectors to their respective interfaces
        bytes4[] memory perpetualMintViewFunctionSelectors = new bytes4[](1);

        perpetualMintViewFunctionSelectors[0] = bytes4(
            keccak256("calculateMintResult(address,uint32,uint256,uint256)")
        );

        ICore.FacetCut
            memory perpetualMintViewFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.REMOVE,
                    selectors: perpetualMintViewFunctionSelectors
                });

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](1);

        facetCuts[0] = perpetualMintViewFacetCut;

        return facetCuts;
    }

    /// @dev provides the replacement facet cuts for cutting PerpetualMintView facet into Core
    /// @param viewFacetAddress address of PerpetualMintView facet
    function getReplacementPerpetualMintViewFacetCuts(
        address viewFacetAddress
    ) internal pure returns (ICore.FacetCut[] memory) {
        // map the Pausable function selectors to their respective interfaces
        bytes4[] memory pausableFunctionSelectors = new bytes4[](1);

        pausableFunctionSelectors[0] = IPausable.paused.selector;

        ICore.FacetCut memory pausableFacetCut = IDiamondWritableInternal
            .FacetCut({
                target: viewFacetAddress,
                action: IDiamondWritableInternal.FacetCutAction.REPLACE,
                selectors: pausableFunctionSelectors
            });

        // map the PerpetualMintView related function selectors to their respective interfaces
        bytes4[] memory perpetualMintViewFunctionSelectors = new bytes4[](27);

        perpetualMintViewFunctionSelectors[0] = IPerpetualMintView
            .accruedConsolationFees
            .selector;

        perpetualMintViewFunctionSelectors[1] = IPerpetualMintView
            .accruedMintEarnings
            .selector;

        perpetualMintViewFunctionSelectors[2] = IPerpetualMintView
            .accruedProtocolFees
            .selector;

        perpetualMintViewFunctionSelectors[3] = IPerpetualMintView
            .BASIS
            .selector;

        perpetualMintViewFunctionSelectors[4] = IPerpetualMintView
            .collectionConsolationFeeBP
            .selector;

        perpetualMintViewFunctionSelectors[5] = IPerpetualMintView
            .collectionMintFeeDistributionRatioBP
            .selector;

        perpetualMintViewFunctionSelectors[6] = IPerpetualMintView
            .collectionMintMultiplier
            .selector;

        perpetualMintViewFunctionSelectors[7] = IPerpetualMintView
            .collectionMintPrice
            .selector;

        perpetualMintViewFunctionSelectors[8] = IPerpetualMintView
            .collectionReferralFeeBP
            .selector;

        perpetualMintViewFunctionSelectors[9] = IPerpetualMintView
            .collectionRisk
            .selector;

        perpetualMintViewFunctionSelectors[10] = IPerpetualMintView
            .defaultCollectionMintPrice
            .selector;

        perpetualMintViewFunctionSelectors[11] = IPerpetualMintView
            .defaultCollectionReferralFeeBP
            .selector;

        perpetualMintViewFunctionSelectors[12] = IPerpetualMintView
            .defaultCollectionRisk
            .selector;

        perpetualMintViewFunctionSelectors[13] = IPerpetualMintView
            .defaultEthToMintRatio
            .selector;

        perpetualMintViewFunctionSelectors[14] = IPerpetualMintView
            .ethToMintRatio
            .selector;

        perpetualMintViewFunctionSelectors[15] = IPerpetualMintView
            .mintEarningsBufferBP
            .selector;

        perpetualMintViewFunctionSelectors[16] = IPerpetualMintView
            .mintFeeBP
            .selector;

        perpetualMintViewFunctionSelectors[17] = IPerpetualMintView
            .mintForEthConsolationFeeBP
            .selector;

        perpetualMintViewFunctionSelectors[18] = IPerpetualMintView
            .mintToken
            .selector;

        perpetualMintViewFunctionSelectors[19] = IPerpetualMintView
            .mintTokenConsolationFeeBP
            .selector;

        perpetualMintViewFunctionSelectors[20] = IPerpetualMintView
            .mintTokenTiers
            .selector;

        perpetualMintViewFunctionSelectors[21] = IPerpetualMintView
            .redemptionFeeBP
            .selector;

        perpetualMintViewFunctionSelectors[22] = IPerpetualMintView
            .redeemPaused
            .selector;

        perpetualMintViewFunctionSelectors[23] = IPerpetualMintView
            .SCALE
            .selector;

        perpetualMintViewFunctionSelectors[24] = IPerpetualMintView
            .tiers
            .selector;

        perpetualMintViewFunctionSelectors[25] = IPerpetualMintView
            .vrfConfig
            .selector;

        perpetualMintViewFunctionSelectors[26] = IPerpetualMintView
            .vrfSubscriptionBalanceThreshold
            .selector;

        ICore.FacetCut
            memory perpetualMintViewFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: viewFacetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.REPLACE,
                    selectors: perpetualMintViewFunctionSelectors
                });

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](2);

        facetCuts[0] = pausableFacetCut;
        facetCuts[1] = perpetualMintViewFacetCut;

        return facetCuts;
    }
}
