pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/EscrowFactory.sol";

contract TestEscrowFactory {

    address swap = DeployedAddresses.Swap();

    uint constant len = 5;

    function testEscrowFactoryParams() public {
        EscrowFactory factory = new EscrowFactory(swap);
        Assert.equal(factory.swap(), swap, "Incorrect swap address in factory");
    }

    function testCreateEscrow() public {
        EscrowFactory factory = new EscrowFactory(swap);
        uint32 id = 1234;
        uint256 price = 2345;
        factory.create(id, price);
        address addr = factory.getEscrowByIndex(address(this), 0);
        address payable escrowAddr = address(uint160(addr));
        Escrow escrow = Escrow(escrowAddr);

        Assert.equal(uint(id), uint(escrow.id()), "Incorrect product ID in escrow");
        Assert.equal(uint(price), uint(escrow.price()), "Incorrect product price in escrow");
        Assert.equal(address(this), escrow.owner(), "Incorrect owner in escrow");
    }

    function testGetEscrowListCount() public {
        EscrowFactory factory = new EscrowFactory(swap);
        for (uint i = 0; i < len; i++) {
            factory.create(1, 2);
        }

        uint256 factoryLen = factory.getEscrowListCount(address(this));
        Assert.equal(factoryLen, len, "Incorrect factory list count");
    }
}