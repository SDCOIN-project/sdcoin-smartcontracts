pragma solidity ^0.5.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/Swap.sol";
import "../contracts/SDC.sol";
import "../contracts/LUV.sol";
import "../contracts/Escrow.sol";

import "./ThrowProxy.sol";
import "../contracts/testing/TestHelper.sol";

contract TestEscrow {
    address private retailer = address(0x123456789);
    Escrow private escrow;

    address private sdc;
    address private luv;
    address private swap;

    SDC private _sdc;
    LUV private _luv;
    Swap private _swap;

    event PrintAddr(address addr);
    event PrintMsg(string msg);
    event PrintSum(uint256 sum, string coin);

    function beforeAll() public {
        sdc = DeployedAddresses.SDC();
        luv = DeployedAddresses.LUV();
        swap = DeployedAddresses.Swap();

        escrow = new Escrow(retailer, 100, 1000, sdc, luv, swap);

        _sdc = SDC(sdc);
        _luv = LUV(luv);
        _swap = Swap(swap);
    }

    function testRetailerAccess() public {
        Assert.isTrue(escrow.owner() == retailer,
                      "Retailer should be the owner of escrow contract");
    }

    function testOnlyOwner() public {
        ThrowProxy proxy = new ThrowProxy(address(escrow));

        Escrow(address(proxy)).updatePrice(123);
        bool r = proxy.execute.gas(200000)();
        Assert.isFalse(r, "Should throw, cause proxy isn't owner");

        Escrow(address(proxy)).updateAmount(123);
        r = proxy.execute.gas(200000)();
        Assert.isFalse(r, "Should throw, cause proxy isn't owner");

        Escrow(address(proxy)).withdraw();
        r = proxy.execute.gas(200000)();
        Assert.isFalse(r, "Should throw, cause proxy isn't owner");
    }

    function testZeroPrice() public {
        // can't test correctly if constructor throws
        // to see, if it throws, you should uncomment line below
        // Escrow e = new Escrow(address(this), 0, 100, sdc, luv, swap);

        Escrow e = new Escrow(address(this), 100, 100, sdc, luv, swap);
        ThrowProxy proxy = new ThrowProxy(address(e));

        Escrow(address(proxy)).updatePrice(0);
        bool r = proxy.execute.gas(200000)();
        Assert.isFalse(r, "Should throw, cause price is 0");
    }

    function testNotEnoughItems() public {
        Escrow e = new Escrow(address(this), 100, 100, sdc, luv, swap);
        ThrowProxy proxy = new ThrowProxy(address(e));

        Escrow(address(proxy)).payment(101);
        bool r = proxy.execute.gas(200000)();
        Assert.isFalse(r, "Should throw, cause not enough items in contract");
    }

    function testCreate() public {
        uint32 price = 12345;
        uint32 amount = 54321;
        Escrow e = new Escrow(retailer, price, amount, sdc, luv, swap);
        Assert.isTrue(e.owner() == retailer, "Should be equal");
        Assert.isTrue(price == e.price(), "Should be equal");
        Assert.isTrue(amount == e.amount(), "Should be equal");
    }

    function testUpdate() public {
        uint32 newPrice = 12345;
        uint32 newAmount = 54321;
        Escrow e = new Escrow(address(this), 1, 1, sdc, luv, swap);

        e.updatePrice(newPrice);
        Assert.isTrue(newPrice == e.price(), "Should be equal");

        e.updateAmount(newAmount);
        Assert.isTrue(newAmount == e.amount(), "Should be equal");
    }

    function testPayment() public {
        Escrow e = new Escrow(address(this), 100, 30, sdc, luv, swap);

        uint32 amount = 7;
        uint256 priceSDC = e.getPriceSDC(amount);
        uint256 priceLUV = e.price() * amount;

        TestHelper tester = TestHelper(DeployedAddresses.TestHelper());
        Assert.isTrue(tester.checkAlive(), "Tester doesn't work");
        tester.addAdmin(address(this));
        tester.transfer(address(this), priceSDC);

        // emit PrintSum(address(this).balance, "eth");
        // emit PrintSum(_sdc.balanceOf(address(this)), "sdc balance");
        // emit PrintSum(priceSDC, "sdc price");

        _sdc.approve(address(e), priceSDC);

        uint32 startAmount = e.amount();

        Assert.isTrue(_sdc.allowance(address(this), address(e)) == priceSDC, "Allowance should be equal to price");
        Assert.isTrue(_luv.balanceOf(address(e)) == 0, "Escrow shouldn't have LUV"); 
        Assert.isTrue(_luv.balanceOf(address(this)) == 0, "Sending contract shouldn't have LUV"); 

        e.payment(amount);

        Assert.isTrue(_sdc.allowance(address(this), address(e)) == 0, "All approved SDC should be spended");
        Assert.isTrue(_luv.balanceOf(address(e)) == priceLUV, "Escrow should receive LUV"); 
        Assert.isTrue(_luv.balanceOf(address(this)) == 0, "Sending contract shouldn't have LUV"); 
        Assert.isTrue(e.amount() == startAmount - amount, "Amount should decrease");

        e.withdraw();

        Assert.isTrue(_luv.balanceOf(address(e)) == 0, "Escrow should send all LUVs"); 
        Assert.isTrue(_luv.balanceOf(address(this)) == priceLUV, "Sending contract should receive LUV"); 

        tester.removeAdmin(address(this));
    }
}