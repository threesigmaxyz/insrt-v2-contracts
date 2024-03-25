// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import { IOwnableInternal } from "@solidstate/contracts/access/ownable/IOwnableInternal.sol";

import { PerpetualMintTest } from "../PerpetualMint.t.sol";
import { ArbForkTest } from "../../../ArbForkTest.t.sol";

/// @dev PerpetualMint_claimMintEarnings
/// @dev PerpetualMint test contract for testing expected behavior of the claimMintEarnings function
contract PerpetualMint_claimMintEarnings is ArbForkTest, PerpetualMintTest {
    uint32 internal constant unsuccessfulMintAttempts = 10;

    /// @dev collection to test
    address internal constant COLLECTION = BORED_APE_YACHT_CLUB;

    /// @dev test amount of mint earnings to claim
    uint256 internal constant TEST_AMOUNT_TO_CLAIM = 0.01 ether;

    /// @dev sets up the context for the test cases
    function setUp() public override {
        super.setUp();

        // ensure contract has enough ETH to send to claimer
        vm.deal(address(perpetualMint), 50 ether);

        perpetualMint.setConsolationFees(50 ether);
    }

    /// @dev Tests claimMintEarnings functionality when specifying an amount for mints for collections paid in ETH.
    function test_claimMintEarningsWithAmountForMintsForCollectionsPaidInEth()
        external
    {
        // mocks unsuccessful mint for collection attempts as a method to increase fees & earnings
        mock_unsuccessfulMintForCollectionWithEthAttempts(
            COLLECTION,
            unsuccessfulMintAttempts
        );

        uint256 preClaimedMintEarnings = perpetualMint.accruedMintEarnings();

        uint256 preClaimedOwnerEthBalance = address(this).balance;

        perpetualMint.claimMintEarnings(TEST_AMOUNT_TO_CLAIM);

        uint256 postClaimedMintEarnings = perpetualMint.accruedMintEarnings();

        assert(
            postClaimedMintEarnings ==
                preClaimedMintEarnings - TEST_AMOUNT_TO_CLAIM
        );

        uint256 postClaimedOwnerEthBalance = address(this).balance;

        // owner's ETH balance should increase by the amount of claimed mintEarnings
        assert(
            postClaimedOwnerEthBalance ==
                preClaimedOwnerEthBalance + TEST_AMOUNT_TO_CLAIM
        );
    }

    /// @dev Tests claimMintEarnings functionality with mints for collections paid in ETH.
    function test_claimMintEarningsWithMintsForCollectionsPaidInEth() external {
        // mocks unsuccessful mint for collection attempts as a method to increase fees & earnings
        mock_unsuccessfulMintForCollectionWithEthAttempts(
            COLLECTION,
            unsuccessfulMintAttempts
        );

        uint256 preClaimedMintEarnings = perpetualMint.accruedMintEarnings();

        uint256 preClaimedOwnerEthBalance = address(this).balance;

        perpetualMint.claimMintEarnings();

        uint256 postClaimedMintEarnings = perpetualMint.accruedMintEarnings();

        // mintEarnings should be zero after claiming
        assert(postClaimedMintEarnings == 0);

        uint256 postClaimedOwnerEthBalance = address(this).balance;

        // owner's ETH balance should increase by the amount of claimed mintEarnings
        assert(
            postClaimedOwnerEthBalance ==
                preClaimedOwnerEthBalance + preClaimedMintEarnings
        );
    }

    /// @dev Tests claimMintEarnings functionality when specifying an amount for mints for collections paid in $MINT.
    function test_claimMintEarningsWithAmountForMintsForCollectionsPaidInMint()
        external
    {
        // mocks unsuccessful mint for collection attempts as a method to increase fees & earnings
        mock_unsuccessfulMintForCollectionWithMintAttempts(
            COLLECTION,
            unsuccessfulMintAttempts
        );

        uint256 preClaimedMintEarnings = perpetualMint.accruedMintEarnings();

        uint256 preClaimedOwnerEthBalance = address(this).balance;

        perpetualMint.claimMintEarnings(TEST_AMOUNT_TO_CLAIM);

        uint256 postClaimedMintEarnings = perpetualMint.accruedMintEarnings();

        assert(
            postClaimedMintEarnings ==
                preClaimedMintEarnings - TEST_AMOUNT_TO_CLAIM
        );

        uint256 postClaimedOwnerEthBalance = address(this).balance;

        // owner's ETH balance should increase by the amount of claimed mintEarnings
        assert(
            postClaimedOwnerEthBalance ==
                preClaimedOwnerEthBalance + TEST_AMOUNT_TO_CLAIM
        );
    }

    /// @dev Tests claimMintEarnings functionality with mints for collections paid in $MINT.
    function test_claimMintEarningsWithMintsForCollectionsPaidInMINT()
        external
    {
        // mocks unsuccessful mint for collection attempts as a method to increase fees & earnings
        mock_unsuccessfulMintForCollectionWithMintAttempts(
            COLLECTION,
            unsuccessfulMintAttempts
        );

        uint256 preClaimedMintEarnings = perpetualMint.accruedMintEarnings();

        uint256 preClaimedOwnerEthBalance = address(this).balance;

        perpetualMint.claimMintEarnings();

        uint256 postClaimedMintEarnings = perpetualMint.accruedMintEarnings();

        // mintEarnings should be zero after claiming
        assert(postClaimedMintEarnings == 0);

        uint256 postClaimedOwnerEthBalance = address(this).balance;

        // owner's ETH balance should increase by the amount of claimed mintEarnings
        assert(
            postClaimedOwnerEthBalance ==
                preClaimedOwnerEthBalance + preClaimedMintEarnings
        );
    }

    /// @dev tests that claimMintEarnings will revert if called by non-owner
    function test_claimMintEarningsRevertsWhen_CalledByNonOwner() external {
        vm.expectRevert(IOwnableInternal.Ownable__NotOwner.selector);

        vm.prank(PERPETUAL_MINT_NON_OWNER);
        perpetualMint.claimMintEarnings();
    }

    /// @dev tests that claimMintEarnings with amount will revert if called by non-owner
    function test_claimMintEarningsWithAmountRevertsWhen_CalledByNonOwner()
        external
    {
        vm.expectRevert(IOwnableInternal.Ownable__NotOwner.selector);

        vm.prank(PERPETUAL_MINT_NON_OWNER);
        perpetualMint.claimMintEarnings(TEST_AMOUNT_TO_CLAIM);
    }
}
