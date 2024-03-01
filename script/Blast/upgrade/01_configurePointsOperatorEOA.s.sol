// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";

import { IDiamondWritableInternal } from "@solidstate/contracts/proxy/diamond/writable/IDiamondWritableInternal.sol";

import { ConfigurePointsOperator } from "./ConfigurePointsOperator.sol";
import { ICore } from "../../../contracts/diamonds/Core/ICore.sol";

/// @title ConfigurePointsOperatorEOA
/// @dev Configures a Blast Points Operator for PerpetualMint by deploying a new ConfigurePointsOperator facet, sign and submitting a diamondCut
/// of the facet to the Core diamond, calling the configurePointsOperator function, and then sign & submitting a diamondCut removal using an externally owned account
contract ConfigurePointsOperatorEOA is Script {
    /// @dev runs the script logic
    function run() external {
        // read deployer private key
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_KEY");

        // get CoreBlast PerpetualMint diamond address
        address coreBlast = vm.envAddress("CORE_BLAST_ADDRESS");

        // get Blast Points Operator address
        address blastPointsOperator = vm.envAddress("POINTS_OPERATOR");

        vm.startBroadcast(deployerPrivateKey);

        // deploy new ConfigurePointsOperator facet
        ConfigurePointsOperator configurePointsOperator = new ConfigurePointsOperator(
                blastPointsOperator
            );

        console.log(
            "New ConfigurePointsOperator Facet Address: ",
            address(configurePointsOperator)
        );
        console.log("CoreBlast Address: ", coreBlast);

        // get ConfigurePointsOperator facet cuts
        ICore.FacetCut[]
            memory configurePointsOperatorFacetCuts = getConfigurePointsOperatorFacetCuts(
                address(configurePointsOperator)
            );

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](1);

        facetCuts[0] = configurePointsOperatorFacetCuts[0];

        // cut ConfigurePointsOperator into CoreBlast
        ICore(payable(coreBlast)).diamondCut(facetCuts, address(0), "");

        // configure the points operator
        ConfigurePointsOperator(payable(coreBlast)).configurePointsOperator();

        console.log(
            "Configured Points Operator Address: ",
            blastPointsOperator
        );

        // get removal ConfigurePointsOperator facet cuts
        ICore.FacetCut[]
            memory removeConfigurePointsOperatorFacetCuts = getRemoveConfigurePointsOperatorFacetCuts();

        facetCuts[0] = removeConfigurePointsOperatorFacetCuts[0];

        // cut out & remove ConfigurePointsOperator from CoreBlast
        ICore(payable(coreBlast)).diamondCut(facetCuts, address(0), "");

        vm.stopBroadcast();
    }

    /// @dev provides the facet cuts for cutting ConfigurePointsOperator facet into CoreBlast
    /// @param facetAddress address of ConfigurePointsOperator facet
    function getConfigurePointsOperatorFacetCuts(
        address facetAddress
    ) internal pure returns (ICore.FacetCut[] memory) {
        /// map the ConfigurePointsOperator function selectors to their respective interfaces
        bytes4[] memory configurePointsOperatorFunctionSelectors = new bytes4[](
            1
        );

        configurePointsOperatorFunctionSelectors[0] = ConfigurePointsOperator
            .configurePointsOperator
            .selector;

        ICore.FacetCut
            memory configurePointsOperatorFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: facetAddress,
                    action: IDiamondWritableInternal.FacetCutAction.ADD,
                    selectors: configurePointsOperatorFunctionSelectors
                });

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](1);

        facetCuts[0] = configurePointsOperatorFacetCut;

        return facetCuts;
    }

    /// @dev provides the facet cuts for removing & cutting out the ConfigurePointsOperator facet from CoreBlast
    function getRemoveConfigurePointsOperatorFacetCuts()
        internal
        pure
        returns (ICore.FacetCut[] memory)
    {
        /// map the ConfigurePointsOperator function selectors to their respective interfaces
        bytes4[] memory configurePointsOperatorFunctionSelectors = new bytes4[](
            1
        );

        configurePointsOperatorFunctionSelectors[0] = ConfigurePointsOperator
            .configurePointsOperator
            .selector;

        ICore.FacetCut
            memory configurePointsOperatorFacetCut = IDiamondWritableInternal
                .FacetCut({
                    target: address(0),
                    action: IDiamondWritableInternal.FacetCutAction.REMOVE,
                    selectors: configurePointsOperatorFunctionSelectors
                });

        ICore.FacetCut[] memory facetCuts = new ICore.FacetCut[](1);

        facetCuts[0] = configurePointsOperatorFacetCut;

        return facetCuts;
    }
}
