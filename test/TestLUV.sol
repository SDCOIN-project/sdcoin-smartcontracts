pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/LUV.sol";
import "./ThrowProxy.sol";

contract TestLUV {
    function testParams() public {
        LUV luv = LUV(DeployedAddresses.LUV());
        Assert.equal(luv.name(), "LUV", "Incorrect name");
        Assert.equal(luv.symbol(), "LUV", "Incorrect symbol");
        Assert.equal(uint(luv.decimals()), uint(18), "Incorrect decimals");
    }

    function testSupply() public {
        LUV luv = new LUV();
        Assert.equal(luv.totalSupply(), 0, "Incorrect total supply");
    }

    function testAccess() public {
        LUV luv = new LUV();

        Assert.isTrue(luv.isWhitelistAdmin(address(this)),
                      "Creator of contract should be whitelist admin");
        Assert.isTrue(luv.isWhitelisted(address(this)),
                      "Creator of contract should be whitelisted");
    }

    function testMint() public {
        LUV luv = new LUV();

        address acc = address(0x12345);
        uint256 sum = 1000;

        Assert.equal(luv.balanceOf(acc), 0, "Should be no LUV on account");

        ThrowProxy proxy = new ThrowProxy(address(luv));
        LUV(address(proxy)).mint(acc, sum);
        bool r = proxy.execute.gas(100000)();
        Assert.isFalse(r, "Should throw cause sender is not whitelisted");

        luv.addWhitelisted(address(proxy));

        LUV(address(proxy)).mint(acc, sum);
        r = proxy.execute.gas(100000)();
        Assert.isTrue(r, "Shouldn't throw cause sender is whitelisted");

        Assert.equal(luv.balanceOf(acc), sum, "LUV should be minted");
    }

    function testBurn() public {
        LUV luv = new LUV();

        address acc = address(0x12345);
        uint256 sum = 1000;
        uint256 burnSum = sum - 5;

        luv.mint(acc, sum);
        Assert.equal(luv.balanceOf(acc), sum, "LUV should be minted");

        ThrowProxy proxy = new ThrowProxy(address(luv));
        LUV(address(proxy)).burn(acc, burnSum);
        bool r = proxy.execute.gas(100000)();
        Assert.isFalse(r, "Should throw cause sender is not whitelisted");

        luv.addWhitelisted(address(proxy));

        LUV(address(proxy)).burn(acc, burnSum);
        r = proxy.execute.gas(100000)();
        Assert.isTrue(r, "Shouldn't throw cause sender is whitelisted");

        Assert.equal(luv.balanceOf(acc), sum - burnSum, "Amount of LUV should decrease after burn");
    }
}