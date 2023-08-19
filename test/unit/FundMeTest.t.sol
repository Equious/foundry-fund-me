// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 100 ether);
    }

    function testMinimumDollarValue() external {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithNotEnoughEth() public {
        vm.expectRevert();
        //assert this transaction fails
        fundMe.fund();
    }

    function testFundSucceedsWithEnoughEth() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        uint256 amountFunded = fundMe.addressToAmountFunded(USER);
        assertEq(amountFunded, 10e18);
    }

    function testFundersListUpdatedOnFund() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        address funder = fundMe.funders(0);
        assertEq(funder, USER);
    }
}
