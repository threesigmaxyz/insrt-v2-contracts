// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import { CoreTest } from "../Core.t.sol";
import { MockYield } from "../../../mocks/MockYield.sol";
import { CoreBlast } from "../../../../contracts/diamonds/Core/Blast/Core.sol";

/// @title CoreBlastTest
/// @dev Test helper contract for setting up and testing the CoreBlast diamond and its facets.
/// Inherits from Test contract in forge-std library.
abstract contract CoreBlastTest is CoreTest {
    CoreBlast public coreBlastDiamond;

    /// @notice Address of the Gas predeploy (precompile). Specific to the Blast network.
    address internal constant GAS = 0x4300000000000000000000000000000000000001;

    /// @notice Address of the Yield predeploy (precompile). Specific to the Blast network.
    address internal constant YIELD = address(0x100);

    /// @notice Setup function to initialize contract state before tests.
    /// @dev Creates a new instance of CoreBlast (diamond contract) and assigns it to coreBlastDiamond.
    /// Function is virtual, so it can be overridden in derived contracts.
    function setUp() public virtual override {
        // Deploy a mock Yield contract since the Yield precompile currently only exists at the client level at the time of writing.
        MockYield mockYield = new MockYield();

        vm.etch(YIELD, address(mockYield).code);

        coreBlastDiamond = new CoreBlast(
            MINT_TOKEN,
            "Perpetual Mint IOU", // receiptName
            "IOU" // receiptSymbol
        );
    }
}
