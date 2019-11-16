pragma solidity ^0.5.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/Swap.sol";
import "../contracts/SDC.sol";
import "../contracts/LUV.sol";

contract TestAdmins {
    // Swap contract should be added as admin on deploy
    function testTokensAdmins() public {
        // Swap swap = Swap(DeployedAddresses.Swap());
        SDC sdc = SDC(DeployedAddresses.SDC());
        LUV luv = LUV(DeployedAddresses.LUV());

        Assert.isTrue(sdc.isAdmin(DeployedAddresses.Swap()),
                      "Swap contract should be admin of SDC");
        Assert.isTrue(luv.isAdmin(DeployedAddresses.Swap()),
                      "Swap contract should be admin of LUV");
    }
}