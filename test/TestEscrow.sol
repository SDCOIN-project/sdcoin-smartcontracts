pragma solidity ^0.5.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/Swap.sol";
import "../contracts/SDC.sol";
import "../contracts/LUV.sol";
import "../contracts/Escrow.sol";
import "../contracts/testing/TestHelper.sol";

contract TestEscrow {

    uint public initialBalance = 10 ether;

    SDC sdc = SDC(DeployedAddresses.SDC());
    LUV luv = LUV(DeployedAddresses.LUV());
    Swap swap = Swap(DeployedAddresses.Swap());

    Escrow escrow;
    address eOwner = address(this);
    uint32 eId = 1234;
    uint256 ePrice = 54321;
    uint32 eAmount = 10000;

    function beforeAll() public {
        escrow = new Escrow(eOwner, eId, ePrice, eAmount,
                            address(sdc), address(luv), address(swap));
    }

    function testEscrowParamsAfterCreation() public {
        Escrow e = new Escrow(eOwner, eId, ePrice, eAmount,
                            address(sdc), address(luv), address(swap));

        Assert.equal(e.owner(), eOwner, "Invalid owner for escrow");
        Assert.equal(uint(e.id()), uint(eId), "Invalid id for escrow");
        Assert.equal(e.price(), ePrice, "Invalid price for escrow");
        Assert.equal(uint(e.amount()), uint(eAmount), "Invalid amount for escrow");
    }

    function testUpdatePrice() public {
        uint32 newPrice = 68734;
        Assert.notEqual(escrow.price(), newPrice, "Choose another new price");
        escrow.updatePrice(newPrice);
        Assert.equal(escrow.price(), newPrice, "Invalid price update");
    }

    function testUpdateAmount() public {
        uint32 newAmount = 7000;
        Assert.notEqual(uint(escrow.amount()), uint(newAmount), "Choose another new amount");
        escrow.updateAmount(newAmount);
        Assert.equal(uint(escrow.amount()), uint(newAmount), "Invalid amount update");
    }

    function testTransferEth() public {
        uint256 startBalance = address(escrow).balance;
        address(escrow).transfer(1 ether);
        Assert.equal(address(escrow).balance - startBalance, uint256(1 ether),
                     "Escrow ETH balance should increase by 1 ether");
    }
}