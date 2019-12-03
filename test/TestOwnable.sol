pragma solidity ^0.5.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/Swap.sol";
import "../contracts/SDC.sol";
import "../contracts/LUV.sol";
import "../contracts/testing/TestHelper.sol";

import "./ThrowProxy.sol";

contract TestOwnable {
    SDC sdc = SDC(DeployedAddresses.SDC());
    LUV luv = LUV(DeployedAddresses.LUV());

    TestHelper tester = TestHelper(DeployedAddresses.TestHelper());

    function beforeAll() public {
        tester.addAdmin(address(this));
    }

    // Swap contract should be added as admin on deploy
    function testTokensAdmins() public {
        Assert.isTrue(sdc.isAdmin(DeployedAddresses.Swap()), "Swap contract should be admin of SDC");
        Assert.isTrue(luv.isAdmin(DeployedAddresses.Swap()), "Swap contract should be admin of LUV");
    }

    function testTokensAddRemoveAdmin() public {
        address adminAddr = address(0x12345);

        Assert.isFalse(sdc.isAdmin(adminAddr), "Test address shouldn't be admin of SDC");
        
        sdc.addAdmin(adminAddr);

        Assert.isTrue(sdc.isAdmin(adminAddr), "Test address should be admin of SDC");

        sdc.removeAdmin(adminAddr);

        Assert.isFalse(sdc.isAdmin(adminAddr), "Test address shouldn't be admin of SDC");
    }

    function testModifiers() public {
        ThrowProxy proxy = new ThrowProxy(address(sdc));

        SDC(address(proxy)).mint(address(proxy), 1);
        bool r = proxy.execute.gas(200000)();
        Assert.isFalse(r, "Should throw, because proxy isn't admin or owner");

        tester.addAdmin(address(proxy));

        SDC(address(proxy)).mint(address(proxy), 1);
        r = proxy.execute.gas(200000)();
        Assert.isTrue(r, "Shouldn't throw, because proxy is admin");
    }
}