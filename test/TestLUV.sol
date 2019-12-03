pragma solidity ^0.5.11;

import "truffle/Assert.sol";

import "../contracts/LUV.sol";

contract TestLUV {
    function testMint() public {
        LUV luv = new LUV();

        address acc = address(0x12345);
        uint256 sum = 1000;

        Assert.equal(luv.balanceOf(acc), 0, "Should be no LUV on account");
        luv.mint(acc, sum);
        Assert.equal(luv.balanceOf(acc), sum, "LUV should be minted");
    }

    function testBurn() public {
        LUV luv = new LUV();

        address acc = address(0x12345);
        uint256 sum = 1000;
        uint256 burnSum = sum - 5;

        luv.mint(acc, sum);
        Assert.equal(luv.balanceOf(acc), sum, "LUV should be minted");
        luv.burn(acc, burnSum);
        Assert.equal(luv.balanceOf(acc), sum - burnSum, "Amount of LUV should decrease after burn");
    }
}