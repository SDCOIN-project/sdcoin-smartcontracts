pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/SDC.sol";
import "../contracts/testing/TestHelper.sol";

import "./ThrowProxy.sol";

contract TestSDC {
    function testParams() public {
        SDC sdc = SDC(DeployedAddresses.SDC());
        Assert.equal(sdc.name(), "SDCOIN", "Incorrect name");
        Assert.equal(sdc.symbol(), "SDC", "Incorrect symbol");
        Assert.equal(uint(sdc.decimals()), uint(18), "Incorrect decimals");
    }

    function testSupply() public {
        SDC sdc = new SDC();
        uint256 initSupply = 3500000000;
        uint8 decimals = 18;
        uint256 supply = initSupply * (10 ** uint(decimals));
        Assert.equal(sdc.totalSupply(), supply, "Incorrect total supply");
        Assert.equal(sdc.balanceOf(address(this)), supply, "Incorrect owner balance");
    }

    function testAccess() public {
        SDC sdc = new SDC();

        Assert.isTrue(sdc.isWhitelistAdmin(address(this)),
                      "Creator of contract should be whitelist admin");
        Assert.isTrue(sdc.isWhitelisted(address(this)),
                      "Creator of contract should be whitelisted");
    }

    function testMint() public {
        SDC sdc = new SDC();

        address acc = address(0x12345);
        uint256 sum = 1000;

        Assert.equal(sdc.balanceOf(acc), 0, "Should be no SDC on account");

        ThrowProxy proxy = new ThrowProxy(address(sdc));
        SDC(address(proxy)).mint(acc, sum);
        bool r = proxy.execute.gas(100000)();
        Assert.isFalse(r, "Should throw cause sender is not whitelisted");

        sdc.addWhitelisted(address(proxy));

        SDC(address(proxy)).mint(acc, sum);
        r = proxy.execute.gas(100000)();
        Assert.isTrue(r, "Shouldn't throw cause sender is whitelisted");

        Assert.equal(sdc.balanceOf(acc), sum, "SDC should be minted");
    }

    function testBurnFrom() public {
        SDC sdc = new SDC();

        uint256 burnSum = 1111;

        ThrowProxy proxy = new ThrowProxy(address(sdc));

        sdc.approve(address(proxy), burnSum);
        Assert.equal(sdc.allowance(address(this), address(proxy)), burnSum, "Incorrect approved sum");

        SDC(address(proxy)).burnFrom(address(this), burnSum);
        bool r = proxy.execute.gas(100000)();
        Assert.isFalse(r, "Should throw cause sender is not whitelisted");

        uint256 prevBalance = sdc.balanceOf(address(this));
        sdc.addWhitelisted(address(proxy));

        SDC(address(proxy)).burnFrom(address(this), burnSum);
        r = proxy.execute.gas(100000)();
        Assert.isTrue(r, "Shouldn't throw cause sender is whitelisted");

        Assert.equal(prevBalance - sdc.balanceOf(address(this)), burnSum, "Incorrect burned sum");
        Assert.equal(sdc.allowance(address(this), address(proxy)), 0, "Incorrect approved remain sum");
    }

    function testMintPause() public {
        SDC sdc = new SDC();
        ThrowProxy proxy = new ThrowProxy(address(sdc));
        sdc.addPauser(address(proxy));
        sdc.addWhitelisted(address(proxy));

        // no pause
        SDC(address(proxy)).mint(address(this), 1);
        bool r = proxy.execute.gas(100000)();
        Assert.isTrue(r, "Shouldn't throw");

        sdc.pause();
        Assert.isTrue(sdc.paused(), "Contract should be on pause");

        // pause
        SDC(address(proxy)).mint(address(this), 1);
        r = proxy.execute.gas(100000)();
        Assert.isFalse(r, "Should throw cause contract on pause");

        sdc.unpause();
        Assert.isFalse(sdc.paused(), "Contract should be on pause");

        // no pause
        SDC(address(proxy)).mint(address(this), 1);
        r = proxy.execute.gas(100000)();
        Assert.isTrue(r, "Shouldn't throw");
    }

    function testBurnPause() public {
        SDC sdc = new SDC();
        ThrowProxy proxy = new ThrowProxy(address(sdc));
        sdc.addPauser(address(proxy));
        sdc.addWhitelisted(address(proxy));

        sdc.approve(address(proxy), 2);

        // no pause
        SDC(address(proxy)).burnFrom(address(this), 1);
        bool r = proxy.execute.gas(100000)();
        Assert.isTrue(r, "Shouldn't throw");

        sdc.pause();
        Assert.isTrue(sdc.paused(), "Contract should be on pause");

        // pause
        SDC(address(proxy)).burnFrom(address(this), 1);
        r = proxy.execute.gas(100000)();
        Assert.isFalse(r, "Should throw cause contract on pause");

        sdc.unpause();
        Assert.isFalse(sdc.paused(), "Contract should be on pause");

        // no pause
        SDC(address(proxy)).burnFrom(address(this), 1);
        r = proxy.execute.gas(100000)();
        Assert.isTrue(r, "Shouldn't throw");
    }
}