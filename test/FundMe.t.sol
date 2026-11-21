// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {FundMe, NotOwner} from "../src/FundMe.sol";
import {PriceConverter} from "../src/PriceConverter.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address owner = address(this);
    address funder = address(0xBEEF);

    // 2000 USD per ETH, 8 decimals, as returned by the real Chainlink feed.
    int256 constant ETH_USD_PRICE = 2000e8;

    function setUp() public {
        vm.mockCall(
            PriceConverter.ETH_USD_PRICE_FEED,
            abi.encodeWithSignature("latestRoundData()"),
            abi.encode(uint80(0), ETH_USD_PRICE, uint256(0), uint256(0), uint80(0))
        );

        fundMe = new FundMe();
        vm.deal(funder, 10 ether);
    }

    function test_FundRevertsBelowMinimumUsd() public {
        vm.prank(funder);
        vm.expectRevert("didn't send enough ETH");
        fundMe.fund{value: 0.001 ether}();
    }

    function test_FundRecordsFunderAndAmount() public {
        vm.prank(funder);
        fundMe.fund{value: 1 ether}();

        assertEq(fundMe.funders(0), funder);
        assertEq(fundMe.addressToAmountFunded(funder), 1 ether);
        assertEq(fundMe.balanceContract(), 1 ether);
    }

    function test_WithdrawRevertsForNonOwner() public {
        vm.prank(funder);
        fundMe.fund{value: 1 ether}();

        vm.prank(funder);
        vm.expectRevert(NotOwner.selector);
        fundMe.withdraw();
    }

    function test_WithdrawTransfersBalanceAndResetsFunders() public {
        vm.prank(funder);
        fundMe.fund{value: 1 ether}();

        uint256 ownerBalanceBefore = owner.balance;

        fundMe.withdraw();

        assertEq(fundMe.balanceContract(), 0);
        assertEq(owner.balance, ownerBalanceBefore + 1 ether);
        assertEq(fundMe.addressToAmountFunded(funder), 0);
    }

    function test_ReceiveFallsBackToFund() public {
        vm.prank(funder);
        (bool success, ) = address(fundMe).call{value: 1 ether}("");

        assertTrue(success);
        assertEq(fundMe.addressToAmountFunded(funder), 1 ether);
    }

    receive() external payable {}
}
