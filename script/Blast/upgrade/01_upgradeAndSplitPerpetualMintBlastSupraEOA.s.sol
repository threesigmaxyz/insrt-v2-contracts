// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";

import { VRFConsumerBaseV2 } from "@chainlink/vrf/VRFConsumerBaseV2.sol";
import { IERC1155 } from "@solidstate/contracts/interfaces/IERC1155.sol";
import { IDiamondWritableInternal } from "@solidstate/contracts/proxy/diamond/writable/IDiamondWritableInternal.sol";
import { IPausable } from "@solidstate/contracts/security/pausable/IPausable.sol";
import { IERC1155Metadata } from "@solidstate/contracts/token/ERC1155/metadata/IERC1155Metadata.sol";

import { ICore } from "../../../contracts/diamonds/Core/ICore.sol";
import { IPerpetualMintBlast } from "../../../contracts/facets/PerpetualMint/Blast/IPerpetualMint.sol";
import { IPerpetualMintViewBlast } from "../../../contracts/facets/PerpetualMint/Blast/IPerpetualMintView.sol";
import { IPerpetualMintViewBlastSupra } from "../../../contracts/facets/PerpetualMint/Blast/Supra/IPerpetualMintView.sol";
import { PerpetualMintBlastSupra } from "../../../contracts/facets/PerpetualMint/Blast/Supra/PerpetualMint.sol";
import { PerpetualMintViewBlastSupra } from "../../../contracts/facets/PerpetualMint/Blast/Supra/PerpetualMintView.sol";
import { IERC1155MetadataExtension } from "../../../contracts/facets/PerpetualMint/IERC1155MetadataExtension.sol";
import { IPerpetualMint } from "../../../contracts/facets/PerpetualMint/IPerpetualMint.sol";
import { IPerpetualMintBase } from "../../../contracts/facets/PerpetualMint/IPerpetualMintBase.sol";
import { IPerpetualMintView } from "../../../contracts/facets/PerpetualMint/IPerpetualMintView.sol";
import { PerpetualMintBase } from "../../../contracts/facets/PerpetualMint/PerpetualMintBase.sol";
import { IPerpetualMintViewSupra } from "../../../contracts/facets/PerpetualMint/Supra/IPerpetualMintView.sol";

/// @title UpgradeAndSplitPerpetualMintBlastSupraEOA
/// @dev Upgrades and splits the PerpetualMintBlastSupra facet by deploying a new PerpetualMintBlastSupra facet, deploying a new PerpetualMintBase facet,
/// & deploying a new PerpetualMintView and sign and submitting a diamondCut of both facets to the Core diamond using an externally owned account
contract UpgradeAndSplitPerpetualMintBlastSupraEOA is Script {
    /// @dev runs the script logic
    function run() external {
        // read deployer private key
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_KEY");

        // get CoreBlast PerpetualMint diamond address
        address coreBlast = vm.envAddress("CORE_BLAST_ADDRESS");

        // get VRF Router address
        address VRF_ROUTER = vm.envAddress("VRF_ROUTER");

        vm.startBroadcast(deployerPrivateKey);

        // deploy new PerpetualMintBlastSupra facet
        PerpetualMintBlastSupra perpetualMintBlastSupra = new PerpetualMintBlastSupra(
                VRF_ROUTER
            );

        // deploy new PerpetualMintBase facet
        PerpetualMintBase perpetualMintBase = new PerpetualMintBase(VRF_ROUTER);

        // deploy new PerpetualMintViewBlastSupra facet
        PerpetualMintViewBlastSupra perpetualMintViewBlastSupra = new PerpetualMintViewBlastSupra(
                VRF_ROUTER
            );

        console.log(
            "New PerpetualMintBlastSupra Facet Address: ",
            address(perpetualMintBlastSupra)
        );
        console.log(
            "New PerpetualMintBase Facet Address: ",
            address(perpetualMintBase)
        );
        console.log(
            "New PerpetualMintViewBlastSupra Facet Address: ",
            address(perpetualMintViewBlastSupra)
        );
        console.log("CoreBlast Address: ", coreBlast);
        console.log("VRF Router Address: ", VRF_ROUTER);

        // get replacement PerpetualMintBase facet cuts
        ICore.FacetCut[]
            memory replacementPerpetualMintBaseFacetCuts = getReplacementPerpetualMintBaseFacetCuts(
                address(perpetualMintBase)
            );

        // get replacement get PerpetualMint + PerpetualMintBlastSupra facet cuts
        ICore.FacetCut[]
            memory replacementPerpetualMintFacetCuts = getReplacementPerpetualMintFacetCuts(
                address(perpetualMintBlastSupra)
            );

        // get replacement get PerpetualMintView + PerpetualMintViewBlastSupra facet cuts
        ICore.FacetCut[]
            memory replacementPerpetualMintViewFacetCuts = getReplacementPerpetualMintViewFacetCuts(
                address(perpetualMintViewBlastSupra)
            );

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](11);

        facetCuts[0] = replacementPerpetualMintBaseFacetCuts[0];
        facetCuts[1] = replacementPerpetualMintBaseFacetCuts[1];
        facetCuts[2] = replacementPerpetualMintBaseFacetCuts[2];
        facetCuts[3] = replacementPerpetualMintBaseFacetCuts[3];
        facetCuts[4] = replacementPerpetualMintFacetCuts[0];
        facetCuts[5] = replacementPerpetualMintFacetCuts[1];
        facetCuts[6] = replacementPerpetualMintFacetCuts[2];
        facetCuts[7] = replacementPerpetualMintViewFacetCuts[0];
        facetCuts[8] = replacementPerpetualMintViewFacetCuts[1];
        facetCuts[9] = replacementPerpetualMintViewFacetCuts[2];
        facetCuts[10] = replacementPerpetualMintViewFacetCuts[3];

        // cut PerpetualMint, PerpetualMintBase, & PerpetualMintView into CoreBlast
        ICore(payable(coreBlast)).diamondCut(facetCuts, address(0), "");

        vm.stopBroadcast();
    }

    /// @dev provides the replacement facet cuts for cutting PerpetualMintBase facet into CoreBlast
    /// @param facetAddress address of PerpetualMintBase facet
    function getReplacementPerpetualMintBaseFacetCuts(
        address facetAddress
    ) internal pure returns (ICore.FacetCut[] memory) {
        /// map the ERC1155 function selectors to their respective interfaces
        bytes4[] memory erc1155FunctionSelectors = new bytes4[](6);

        erc1155FunctionSelectors[0] = IERC1155.balanceOf.selector;
        erc1155FunctionSelectors[1] = IERC1155.balanceOfBatch.selector;
        erc1155FunctionSelectors[2] = IERC1155.isApprovedForAll.selector;
        erc1155FunctionSelectors[3] = IERC1155.safeBatchTransferFrom.selector;
        erc1155FunctionSelectors[4] = IERC1155.safeTransferFrom.selector;
        erc1155FunctionSelectors[5] = IERC1155.setApprovalForAll.selector;

        ICore.FacetCut memory erc1155FacetCut = IDiamondWritableInternal
            .FacetCut({
                target: facetAddress,
                action: IDiamondWritableInternal.FacetCutAction.REPLACE,
                selectors: erc1155FunctionSelectors
            });

        // map the ERC1155Metadata function selectors to their respective interfaces
        bytes4[] memory erc1155MetadataFunctionSelectors = new bytes4[](1);

        erc1155MetadataFunctionSelectors[0] = IERC1155Metadata.uri.selector;

        ICore.FacetCut memory erc1155MetadataFacetCut = IDiamondWritableInternal
            .FacetCut({
                target: facetAddress,
                action: IDiamondWritableInternal.FacetCutAction.REPLACE,
                selectors: erc1155MetadataFunctionSelectors
            });

        // map the ERC1155Metadata function selectors to their respective interfaces
        bytes4[]
            memory erc1155MetadataExtensionFunctionSelectors = new bytes4[](2);

        erc1155MetadataExtensionFunctionSelectors[0] = IERC1155MetadataExtension
            .name
            .selector;
        erc1155MetadataExtensionFunctionSelectors[1] = IERC1155MetadataExtension
            .symbol
            .selector;

        ICore.FacetCut
            memory erc1155MetadataExtensionFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.REPLACE,
                    selectors: erc1155MetadataExtensionFunctionSelectors
                });

        // map the PerpetualMintBase related function selectors to their respective interfaces
        bytes4[] memory perpetualMintBaseFunctionSelectors = new bytes4[](1);

        perpetualMintBaseFunctionSelectors[0] = IPerpetualMintBase
            .onERC1155Received
            .selector;

        ICore.FacetCut
            memory perpetualMintBaseFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.REPLACE,
                    selectors: perpetualMintBaseFunctionSelectors
                });

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](4);

        // omit ERC165 since SolidStateDiamond includes those
        facetCuts[0] = erc1155FacetCut;
        facetCuts[1] = erc1155MetadataFacetCut;
        facetCuts[2] = erc1155MetadataExtensionFacetCut;
        facetCuts[3] = perpetualMintBaseFacetCut;

        return facetCuts;
    }

    /// @dev provides the replacement facet cuts for cutting PerpetualMint & PerpetualMintBlastSupra facet into CoreBlast
    /// @param facetAddress address of PerpetualMint facet
    function getReplacementPerpetualMintFacetCuts(
        address facetAddress
    ) internal pure returns (ICore.FacetCut[] memory) {
        // map the PerpetualMint related function selectors to their respective interfaces
        bytes4[] memory perpetualMintFunctionSelectors = new bytes4[](33);

        perpetualMintFunctionSelectors[0] = IPerpetualMint
            .attemptBatchMintForMintWithEth
            .selector;

        perpetualMintFunctionSelectors[1] = IPerpetualMint
            .attemptBatchMintForMintWithMint
            .selector;

        perpetualMintFunctionSelectors[2] = IPerpetualMint
            .attemptBatchMintWithEth
            .selector;

        perpetualMintFunctionSelectors[3] = IPerpetualMint
            .attemptBatchMintWithMint
            .selector;

        perpetualMintFunctionSelectors[4] = IPerpetualMint.burnReceipt.selector;

        perpetualMintFunctionSelectors[5] = IPerpetualMint.cancelClaim.selector;

        perpetualMintFunctionSelectors[6] = IPerpetualMint
            .claimMintEarnings
            .selector;

        perpetualMintFunctionSelectors[7] = IPerpetualMint.claimPrize.selector;

        perpetualMintFunctionSelectors[8] = IPerpetualMint
            .claimProtocolFees
            .selector;

        perpetualMintFunctionSelectors[9] = IPerpetualMint
            .fundConsolationFees
            .selector;

        perpetualMintFunctionSelectors[10] = IPerpetualMint
            .mintAirdrop
            .selector;

        perpetualMintFunctionSelectors[11] = IPerpetualMint.pause.selector;

        perpetualMintFunctionSelectors[12] = IPerpetualMint.redeem.selector;

        perpetualMintFunctionSelectors[13] = IPerpetualMint
            .setCollectionConsolationFeeBP
            .selector;

        perpetualMintFunctionSelectors[14] = IPerpetualMint
            .setCollectionMintFeeDistributionRatioBP
            .selector;

        perpetualMintFunctionSelectors[15] = IPerpetualMint
            .setCollectionMintMultiplier
            .selector;

        perpetualMintFunctionSelectors[16] = IPerpetualMint
            .setCollectionMintPrice
            .selector;

        perpetualMintFunctionSelectors[17] = IPerpetualMint
            .setCollectionReferralFeeBP
            .selector;

        perpetualMintFunctionSelectors[18] = IPerpetualMint
            .setCollectionRisk
            .selector;

        perpetualMintFunctionSelectors[19] = IPerpetualMint
            .setDefaultCollectionReferralFeeBP
            .selector;

        perpetualMintFunctionSelectors[20] = IPerpetualMint
            .setEthToMintRatio
            .selector;

        perpetualMintFunctionSelectors[21] = IPerpetualMint
            .setMintFeeBP
            .selector;

        perpetualMintFunctionSelectors[22] = IPerpetualMint
            .setMintToken
            .selector;

        perpetualMintFunctionSelectors[23] = IPerpetualMint
            .setMintTokenConsolationFeeBP
            .selector;

        perpetualMintFunctionSelectors[24] = IPerpetualMint
            .setMintTokenTiers
            .selector;

        perpetualMintFunctionSelectors[25] = IPerpetualMint
            .setReceiptBaseURI
            .selector;

        perpetualMintFunctionSelectors[26] = IPerpetualMint
            .setReceiptTokenURI
            .selector;

        perpetualMintFunctionSelectors[27] = IPerpetualMint
            .setRedemptionFeeBP
            .selector;

        perpetualMintFunctionSelectors[28] = IPerpetualMint
            .setRedeemPaused
            .selector;

        perpetualMintFunctionSelectors[29] = IPerpetualMint.setTiers.selector;

        perpetualMintFunctionSelectors[30] = IPerpetualMint
            .setVRFConfig
            .selector;

        perpetualMintFunctionSelectors[31] = IPerpetualMint
            .setVRFSubscriptionBalanceThreshold
            .selector;

        perpetualMintFunctionSelectors[32] = IPerpetualMint.unpause.selector;

        ICore.FacetCut memory perpetualMintFacetCut = IDiamondWritableInternal
            .FacetCut({
                target: facetAddress,
                action: IDiamondWritableInternal.FacetCutAction.REPLACE,
                selectors: perpetualMintFunctionSelectors
            });

        // map the PerpetualMintBlastSupra related function selectors to their respective interfaces
        bytes4[] memory perpetualMintBlastSupraFunctionSelectors = new bytes4[](
            1
        );

        perpetualMintBlastSupraFunctionSelectors = new bytes4[](1);

        perpetualMintBlastSupraFunctionSelectors[0] = IPerpetualMintBlast
            .setBlastYieldRisk
            .selector;

        ICore.FacetCut
            memory perpetualMintBlastSupraFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.ADD,
                    selectors: perpetualMintBlastSupraFunctionSelectors
                });

        // map the VRFConsumerBaseV2 function selectors to their respective interfaces
        bytes4[] memory vrfConsumerBaseV2FunctionSelectors = new bytes4[](1);

        vrfConsumerBaseV2FunctionSelectors[0] = VRFConsumerBaseV2
            .rawFulfillRandomWords
            .selector;

        ICore.FacetCut
            memory vrfConsumerBaseV2FacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.REPLACE,
                    selectors: vrfConsumerBaseV2FunctionSelectors
                });

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](3);

        // omit Ownable since SolidStateDiamond includes those
        facetCuts[0] = perpetualMintBlastSupraFacetCut;
        facetCuts[1] = perpetualMintFacetCut;
        facetCuts[2] = vrfConsumerBaseV2FacetCut;

        return facetCuts;
    }

    /// @dev provides the replacement facet cuts for cutting PerpetualMintView & PerpetualMintViewBlastSupra facet into CoreBlast
    /// @param facetAddress address of PerpetualMint facet
    function getReplacementPerpetualMintViewFacetCuts(
        address facetAddress
    ) internal pure returns (ICore.FacetCut[] memory) {
        // map the Pausable function selectors to their respective interfaces
        bytes4[] memory pausableFunctionSelectors = new bytes4[](1);

        pausableFunctionSelectors[0] = IPausable.paused.selector;

        ICore.FacetCut memory pausableFacetCut = IDiamondWritableInternal
            .FacetCut({
                target: facetAddress,
                action: IDiamondWritableInternal.FacetCutAction.REPLACE,
                selectors: pausableFunctionSelectors
            });

        // map the PerpetualMintView related function selectors to their respective interfaces
        bytes4[] memory perpetualMintViewFunctionSelectors = new bytes4[](25);

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
            .mintFeeBP
            .selector;

        perpetualMintViewFunctionSelectors[16] = IPerpetualMintView
            .mintToken
            .selector;

        perpetualMintViewFunctionSelectors[17] = IPerpetualMintView
            .mintTokenConsolationFeeBP
            .selector;

        perpetualMintViewFunctionSelectors[18] = IPerpetualMintView
            .mintTokenTiers
            .selector;

        perpetualMintViewFunctionSelectors[19] = IPerpetualMintView
            .redemptionFeeBP
            .selector;

        perpetualMintViewFunctionSelectors[20] = IPerpetualMintView
            .redeemPaused
            .selector;

        perpetualMintViewFunctionSelectors[21] = IPerpetualMintView
            .SCALE
            .selector;

        perpetualMintViewFunctionSelectors[22] = IPerpetualMintView
            .tiers
            .selector;

        perpetualMintViewFunctionSelectors[23] = IPerpetualMintView
            .vrfConfig
            .selector;

        perpetualMintViewFunctionSelectors[24] = IPerpetualMintView
            .vrfSubscriptionBalanceThreshold
            .selector;

        ICore.FacetCut
            memory perpetualMintViewFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.REPLACE,
                    selectors: perpetualMintViewFunctionSelectors
                });

        // map the PerpetualMintViewBlast related function selectors to their respective interfaces
        bytes4[] memory perpetualMintViewBlastFunctionSelectors = new bytes4[](
            1
        );

        perpetualMintViewBlastFunctionSelectors[0] = IPerpetualMintViewBlast
            .blastYieldRisk
            .selector;

        ICore.FacetCut
            memory perpetualMintViewBlastFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.ADD,
                    selectors: perpetualMintViewBlastFunctionSelectors
                });

        // map the PerpetualMintViewBlastSupra related function selectors to their respective interfaces
        bytes4[]
            memory perpetualMintViewBlastSupraFunctionSelectors = new bytes4[](
                1
            );

        perpetualMintViewBlastSupraFunctionSelectors[
            1
        ] = IPerpetualMintViewBlastSupra.calculateMintResultBlastSupra.selector;

        ICore.FacetCut
            memory perpetualMintViewBlastSupraFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.ADD,
                    selectors: perpetualMintViewBlastSupraFunctionSelectors
                });

        // map the PerpetualMintViewSupra related function selectors to their respective interfaces
        bytes4[] memory perpetualMintViewSupraFunctionSelectors = new bytes4[](
            1
        );

        perpetualMintViewSupraFunctionSelectors[0] = IPerpetualMintViewSupra
            .calculateMintResultSupra
            .selector;

        ICore.FacetCut
            memory perpetualMintViewSupraFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: address(0),
                    action: IDiamondWritableInternal.FacetCutAction.REMOVE,
                    selectors: perpetualMintViewSupraFunctionSelectors
                });

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](5);

        facetCuts[0] = pausableFacetCut;
        facetCuts[1] = perpetualMintViewFacetCut;
        facetCuts[2] = perpetualMintViewBlastFacetCut;
        facetCuts[3] = perpetualMintViewBlastSupraFacetCut;
        facetCuts[4] = perpetualMintViewSupraFacetCut;

        return facetCuts;
    }
}
