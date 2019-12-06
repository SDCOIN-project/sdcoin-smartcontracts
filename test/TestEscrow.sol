pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/Swap.sol";
import "../contracts/SDC.sol";
import "../contracts/LUV.sol";
import "../contracts/Escrow.sol";
import "../contracts/testing/TestHelper.sol";

import "./ThrowProxy.sol";

contract TestEscrow {

    uint public initialBalance = 10 ether;

    SDC sdc = SDC(DeployedAddresses.SDC());
    LUV luv = LUV(DeployedAddresses.LUV());
    Swap swap = Swap(DeployedAddresses.Swap());

    Escrow escrow;
    address eOwner = address(this);
    uint32 eId = 1234;
    uint256 ePrice = 54321;

    function beforeAll() public {
        escrow = new Escrow(eOwner, eId, ePrice, address(swap));
    }

    function testEscrowParamsAfterCreation() public {
        Escrow e = new Escrow(eOwner, eId, ePrice, address(swap));

        Assert.equal(e.owner(), eOwner, "Invalid owner for escrow");
        Assert.equal(uint(e.id()), uint(eId), "Invalid id for escrow");
        Assert.equal(e.price(), ePrice, "Invalid price for escrow");
    }

    function testUpdatePrice() public {
        uint32 newPrice = 68734;
        Assert.notEqual(escrow.price(), newPrice, "Choose another new price");

        ThrowProxy proxy = new ThrowProxy(address(escrow));
        address payable proxyPay = address(uint160(address(proxy)));
        Escrow(proxyPay).updatePrice(newPrice);
        bool r = proxy.execute.gas(100000)();
        Assert.isFalse(r, "Should throw cause account is not owner");

        escrow.updatePrice(newPrice);
        Assert.equal(escrow.price(), newPrice, "Invalid price update");
    }

    function testUpdateZeroPrice() public {
        Escrow escrowPrice = new Escrow(eOwner, eId, ePrice, address(swap));
        ThrowProxy proxy = new ThrowProxy(address(escrowPrice));
        escrowPrice.transferOwnership(address(proxy));

        address payable proxyPay = address(uint160(address(proxy)));
        Escrow(proxyPay).updatePrice(0);
        bool r = proxy.execute.gas(100000)();
        Assert.isFalse(r, "Should throw cause price can't be set to 0");
    }

    function testTransferEth() public {
        uint256 startBalance = address(escrow).balance;
        address(escrow).transfer(1 ether);
        Assert.equal(address(escrow).balance - startBalance, uint256(1 ether),
                     "Escrow ETH balance should increase by 1 ether");
    }
}
