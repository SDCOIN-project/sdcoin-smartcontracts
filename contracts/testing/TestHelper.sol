pragma solidity ^0.5.0;

import "../SDC.sol";
import "../LUV.sol";
import "../Swap.sol";

contract TestHelper {
    address private _sdc;
    address private _luv;
    address private _swap;

    function setAddresses(address sdc, address luv, address swap) public {
        _sdc = sdc;
        _luv = luv;
        _swap = swap;
    }

    function addAdmin(address account) public {
        SDC(_sdc).addWhitelisted(account);
        LUV(_luv).addWhitelisted(account);
        Swap(_swap).addWhitelisted(account);
    }

    function removeAdmin(address account) public {
        SDC(_sdc).removeWhitelisted(account);
        LUV(_luv).removeWhitelisted(account);
        Swap(_swap).removeWhitelisted(account);
    }

    function transferSDC(address spender, uint256 amount) public {
        SDC(_sdc).transfer(spender, amount);
    }
}