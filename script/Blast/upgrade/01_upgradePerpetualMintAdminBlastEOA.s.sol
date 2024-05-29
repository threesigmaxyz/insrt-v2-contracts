// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";

import { VRFConsumerBaseV2 } from "@chainlink/vrf/VRFConsumerBaseV2.sol";
import { IDiamondWritableInternal } from "@solidstate/contracts/proxy/diamond/writable/IDiamondWritableInternal.sol";

import { ICore } from "../../../contracts/diamonds/Core/ICore.sol";
import { IPerpetualMintAdminBlast } from "../../../contracts/facets/PerpetualMint/Blast/IPerpetualMintAdmin.sol";
import { PerpetualMintAdminBlast } from "../../../contracts/facets/PerpetualMint/Blast/PerpetualMintAdmin.sol";
import { PerpetualMintSupraBlast } from "../../../contracts/facets/PerpetualMint/Blast/Supra/PerpetualMint.sol";
import { IPerpetualMint } from "../../../contracts/facets/PerpetualMint/IPerpetualMint.sol";
import { IPerpetualMintAdmin } from "../../../contracts/facets/PerpetualMint/IPerpetualMintAdmin.sol";

/// @title UpgradePerpetualMintAdminBlastEOA
/// @dev Deploys a new PerpetualMintAdminBlast facet and signs and submits a diamondCut of the PerpetualMintAdminBlast facet to the Core diamond
/// using an externally owned account
contract UpgradePerpetualMintAdminBlastEOA is Script {
    /// @dev runs the script logic
    function run() external {
        // read deployer private key
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_KEY");

        // get CoreBlast PerpetualMint diamond address
        address coreBlast = vm.envAddress("CORE_BLAST_ADDRESS");

        // get VRF Router address
        address VRF_ROUTER = vm.envAddress("VRF_ROUTER");

        vm.startBroadcast(deployerPrivateKey);

        // deploy new PerpetualMintAdminBlast facet
        PerpetualMintAdminBlast perpetualMintAdminBlast = new PerpetualMintAdminBlast(
                VRF_ROUTER
            );

        console.log(
            "New PerpetualMintAdminBlast Facet Address: ",
            address(perpetualMintAdminBlast)
        );
        console.log("CoreBlast Address: ", coreBlast);
        console.log("VRF Router Address: ", VRF_ROUTER);

        // get new PerpetualMintAdmin + PerpetualAdminBlast facet cuts
        ICore.FacetCut[]
            memory newPerpetualMintAdminFacetCuts = getNewPerpetualMintAdminFacetCuts(
                address(perpetualMintAdminBlast)
            );

        // get replacement PerpetualMintAdmin + PerpetualMintAdminBlast facet cuts
        ICore.FacetCut[]
            memory replacementPerpetualMintAdminFacetCuts = getReplacementPerpetualMintAdminFacetCuts(
                address(perpetualMintAdminBlast)
            );

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](3);

        facetCuts[0] = newPerpetualMintAdminFacetCuts[0];
        facetCuts[1] = replacementPerpetualMintAdminFacetCuts[0];
        facetCuts[2] = replacementPerpetualMintAdminFacetCuts[1];

        // cut PerpetualMint & PerpetualMintAdmin into CoreBlast
        ICore(payable(coreBlast)).diamondCut(facetCuts, address(0), "");

        vm.stopBroadcast();
    }

    /// @dev provides the new facet cuts for cutting PerpetualMintAdmin & PerpetualAdminBlast facet into Core
    /// @param facetAddress address of PerpetualMintAdmin facet
    function getNewPerpetualMintAdminFacetCuts(
        address facetAddress
    ) internal pure returns (ICore.FacetCut[] memory facetCuts) {
        // map the PerpetualMintAdmin related function selectors to their respective interfaces
        bytes4[] memory perpetualMintAdminFunctionSelectors = new bytes4[](2);

        perpetualMintAdminFunctionSelectors[0] = IPerpetualMintAdmin
            .setMintEarningsBufferBP
            .selector;

        perpetualMintAdminFunctionSelectors[1] = IPerpetualMintAdmin
            .setMintForEthConsolationFeeBP
            .selector;

        ICore.FacetCut
            memory perpetualMintAdminFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.ADD,
                    selectors: perpetualMintAdminFunctionSelectors
                });

        facetCuts = new ICore.FacetCut[](1);

        facetCuts[0] = perpetualMintAdminFacetCut;
    }

    /// @dev provides the replacement facet cuts for cutting PerpetualMintAdmin & PerpetualMintAdminBlast facet into CoreBlast
    /// @param facetAddress address of PerpetualMintAdmin facet
    function getReplacementPerpetualMintAdminFacetCuts(
        address facetAddress
    ) internal pure returns (ICore.FacetCut[] memory facetCuts) {
        // map the PerpetualMintAdmin related function selectors to their respective interfaces
        bytes4[] memory perpetualMintAdminFunctionSelectors = new bytes4[](29);

        perpetualMintAdminFunctionSelectors[0] = IPerpetualMintAdmin
            .burnReceipt
            .selector;

        perpetualMintAdminFunctionSelectors[1] = IPerpetualMintAdmin
            .cancelClaim
            .selector;

        perpetualMintAdminFunctionSelectors[2] = bytes4(
            keccak256("claimMintEarnings()")
        );

        perpetualMintAdminFunctionSelectors[3] = bytes4(
            keccak256("claimMintEarnings(uint256)")
        );

        perpetualMintAdminFunctionSelectors[4] = IPerpetualMintAdmin
            .claimProtocolFees
            .selector;

        perpetualMintAdminFunctionSelectors[5] = IPerpetualMintAdmin
            .mintAirdrop
            .selector;

        perpetualMintAdminFunctionSelectors[6] = IPerpetualMintAdmin
            .pause
            .selector;

        perpetualMintAdminFunctionSelectors[7] = IPerpetualMintAdmin
            .setCollectionConsolationFeeBP
            .selector;

        perpetualMintAdminFunctionSelectors[8] = IPerpetualMintAdmin
            .setCollectionMintFeeDistributionRatioBP
            .selector;

        perpetualMintAdminFunctionSelectors[9] = IPerpetualMintAdmin
            .setCollectionMintMultiplier
            .selector;

        perpetualMintAdminFunctionSelectors[10] = IPerpetualMintAdmin
            .setCollectionMintPrice
            .selector;

        perpetualMintAdminFunctionSelectors[11] = IPerpetualMintAdmin
            .setCollectionReferralFeeBP
            .selector;

        perpetualMintAdminFunctionSelectors[12] = IPerpetualMintAdmin
            .setCollectionRisk
            .selector;

        perpetualMintAdminFunctionSelectors[13] = IPerpetualMintAdmin
            .setDefaultCollectionReferralFeeBP
            .selector;

        perpetualMintAdminFunctionSelectors[14] = IPerpetualMintAdmin
            .setEthToMintRatio
            .selector;

        perpetualMintAdminFunctionSelectors[15] = IPerpetualMintAdmin
            .setMintEarningsBufferBP
            .selector;

        perpetualMintAdminFunctionSelectors[16] = IPerpetualMintAdmin
            .setMintFeeBP
            .selector;

        perpetualMintAdminFunctionSelectors[17] = IPerpetualMintAdmin
            .setMintForEthConsolationFeeBP
            .selector;

        perpetualMintAdminFunctionSelectors[18] = IPerpetualMintAdmin
            .setMintToken
            .selector;

        perpetualMintAdminFunctionSelectors[19] = IPerpetualMintAdmin
            .setMintTokenConsolationFeeBP
            .selector;

        perpetualMintAdminFunctionSelectors[20] = IPerpetualMintAdmin
            .setMintTokenTiers
            .selector;

        perpetualMintAdminFunctionSelectors[21] = IPerpetualMintAdmin
            .setReceiptBaseURI
            .selector;

        perpetualMintAdminFunctionSelectors[22] = IPerpetualMintAdmin
            .setReceiptTokenURI
            .selector;

        perpetualMintAdminFunctionSelectors[23] = IPerpetualMintAdmin
            .setRedemptionFeeBP
            .selector;

        perpetualMintAdminFunctionSelectors[24] = IPerpetualMintAdmin
            .setRedeemPaused
            .selector;

        perpetualMintAdminFunctionSelectors[25] = IPerpetualMintAdmin
            .setTiers
            .selector;

        perpetualMintAdminFunctionSelectors[26] = IPerpetualMintAdmin
            .setVRFConfig
            .selector;

        perpetualMintAdminFunctionSelectors[27] = IPerpetualMintAdmin
            .setVRFSubscriptionBalanceThreshold
            .selector;

        perpetualMintAdminFunctionSelectors[28] = IPerpetualMintAdmin
            .unpause
            .selector;

        ICore.FacetCut
            memory perpetualMintAdminFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.REPLACE,
                    selectors: perpetualMintAdminFunctionSelectors
                });

        // map the PerpetualMintAdminBlast related function selectors to their respective interfaces
        bytes4[] memory perpetualMintAdminBlastFunctionSelectors = new bytes4[](
            1
        );

        perpetualMintAdminBlastFunctionSelectors[0] = IPerpetualMintAdminBlast
            .setBlastYieldRisk
            .selector;

        ICore.FacetCut
            memory perpetualMintAdminBlastFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.REPLACE,
                    selectors: perpetualMintAdminBlastFunctionSelectors
                });

        facetCuts = new ICore.FacetCut[](2);

        // omit Ownable since SolidStateDiamond includes those
        facetCuts[0] = perpetualMintAdminFacetCut;
        facetCuts[1] = perpetualMintAdminBlastFacetCut;
    }
}
