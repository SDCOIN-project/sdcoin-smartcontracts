pragma solidity ^0.5.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/Swap.sol";
import "../contracts/SDC.sol";
import "../contracts/LUV.sol";
import "../contracts/testing/TestHelper.sol";

contract TestSwap {

    SDC sdc = SDC(DeployedAddresses.SDC());
    LUV luv = LUV(DeployedAddresses.LUV());
    Swap swap = Swap(DeployedAddresses.Swap());

    TestHelper tester = TestHelper(DeployedAddresses.TestHelper());

    function beforeEach() public {
        sdc.transfer(address(tester), sdc.balanceOf(address(this)));
        luv.transfer(address(tester), luv.balanceOf(address(this)));
    }

    function testSwapping() public {
        uint256 expectedLUV = 3000;
        uint256 neededSDC = swap.countSDCFromLUV(expectedLUV);

        Assert.equal(sdc.balanceOf(address(this)), 0, "SDC balance should be empty");
        Assert.equal(luv.balanceOf(address(this)), 0, "LUV balance should be empty");
        Assert.equal(sdc.allowance(address(this), address(swap)), 0, "SDC allowance should be empty");

        tester.transferSDC(address(this), neededSDC);

        Assert.equal(sdc.balanceOf(address(this)), neededSDC, "SDC should be transferred");
        
        sdc.approve(address(swap), neededSDC);

        Assert.equal(sdc.allowance(address(this), address(swap)), neededSDC, "SDC not approved");

        swap.swap(address(this));

        Assert.equal(sdc.balanceOf(address(this)), 0, "All SDC should be spent");
        Assert.equal(luv.balanceOf(address(this)), expectedLUV, "Should be expected amount of SDC");
        Assert.equal(sdc.allowance(address(this), address(swap)), 0, "SDC allowance should be empty");
    }

    function testSwapping2() public {
        uint256 givenSDC = 3000;
        uint256 expectedLUV = givenSDC * swap.sdcExchangeRate() / swap.luvExchangeRate();

        Assert.equal(sdc.balanceOf(address(this)), 0, "SDC balance should be empty");
        Assert.equal(luv.balanceOf(address(this)), 0, "LUV balance should be empty");
        Assert.equal(sdc.allowance(address(this), address(swap)), 0, "SDC allowance should be empty");

        tester.transferSDC(address(this), givenSDC);

        Assert.equal(sdc.balanceOf(address(this)), givenSDC, "SDC should be transferred");
        
        sdc.approve(address(swap), givenSDC);

        Assert.equal(sdc.allowance(address(this), address(swap)), givenSDC, "SDC not approved");

        swap.swap(address(this));

        Assert.equal(sdc.balanceOf(address(this)), 0, "All SDC should be spent");
        Assert.equal(luv.balanceOf(address(this)), expectedLUV, "Should be expected amount of SDC");
        Assert.equal(sdc.allowance(address(this), address(swap)), 0, "SDC allowance should be empty");
    }
}