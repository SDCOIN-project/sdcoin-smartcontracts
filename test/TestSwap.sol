pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/Swap.sol";
import "../contracts/SDC.sol";
import "../contracts/LUV.sol";
import "../contracts/testing/TestHelper.sol";

import "./ThrowProxy.sol";

contract TestSwap {

    SDC sdc = SDC(DeployedAddresses.SDC());
    LUV luv = LUV(DeployedAddresses.LUV());
    Swap swap = Swap(DeployedAddresses.Swap());

    TestHelper tester = TestHelper(DeployedAddresses.TestHelper());

    function beforeEach() public {
        sdc.transfer(address(tester), sdc.balanceOf(address(this)));
        luv.transfer(address(tester), luv.balanceOf(address(this)));
    }

    function testAccess() public {
        Swap swapAccess = new Swap(1, address(0x1), address(0x2));

        Assert.isTrue(swapAccess.isWhitelistAdmin(address(this)),
                      "Creator of contract should be whitelist admin");
        Assert.isTrue(swapAccess.isWhitelisted(address(this)),
                      "Creator of contract should be whitelisted");
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

    function testUpdateSDCRate() public {
        uint256 oldRate = 1234;
        uint256 newRate = oldRate + 1000;
        Swap swapRate = new Swap(oldRate, DeployedAddresses.SDC(), DeployedAddresses.LUV());
        Assert.equal(swapRate.sdcExchangeRate(), oldRate, "Incorrect rate");

        ThrowProxy proxy = new ThrowProxy(address(swapRate));
        Swap(address(proxy)).updateSDCRate(newRate);
        bool r = proxy.execute.gas(100000)();
        Assert.isFalse(r, "Should throw cause sender is not whitelisted");

        swapRate.addWhitelisted(address(proxy));

        Swap(address(proxy)).updateSDCRate(newRate);
        r = proxy.execute.gas(100000)();
        Assert.isTrue(r, "Shouldn't throw cause sender is whitelisted");

        Assert.equal(swapRate.sdcExchangeRate(), newRate, "Incorrect rate");
    }
}