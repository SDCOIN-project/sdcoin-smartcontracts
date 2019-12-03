pragma solidity ^0.5.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/SDC.sol";
import "../contracts/testing/TestHelper.sol";

import "./ThrowProxy.sol";

contract TestSDC {
    function testMint() public {
        SDC sdc = new SDC();

        address acc = address(0x12345);
        uint256 sum = 1000;

        Assert.equal(sdc.balanceOf(acc), 0, "Should be no SDC on account");
        sdc.mint(acc, sum);
        Assert.equal(sdc.balanceOf(acc), sum, "SDC should be minted");
    }

    function testBurnFrom() public {
        SDC sdc = SDC(DeployedAddresses.SDC());
        TestHelper tester = TestHelper(DeployedAddresses.TestHelper());

        uint256 sum = 10000;
        uint256 burnSum = sum - 1111;

        tester.transferSDC(address(this), sum);
        Assert.equal(sdc.balanceOf(address(this)), sum, "Incorrect transferred sum");

        sdc.approve(address(tester), burnSum);
        Assert.equal(sdc.allowance(address(this), address(tester)), burnSum, "Incorrect approved sum");

        tester.sdcBurnFrom(address(this), burnSum);
        Assert.equal(sdc.balanceOf(address(this)), sum - burnSum, "Incorrect burned sum");
        Assert.equal(sdc.allowance(address(this), address(tester)), 0, "Incorrect approved remain sum");
    }
}