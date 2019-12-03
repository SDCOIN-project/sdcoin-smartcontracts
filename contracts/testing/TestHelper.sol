pragma solidity ^0.5.11;

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
        SDC(_sdc).addAdmin(account);
        LUV(_luv).addAdmin(account);
        Swap(_swap).addAdmin(account);
    }

    function removeAdmin(address account) public {
        SDC(_sdc).removeAdmin(account);
        LUV(_luv).removeAdmin(account);
        Swap(_swap).removeAdmin(account);
    }

    function transferSDC(address spender, uint256 amount) public {
        SDC(_sdc).transfer(spender, amount);
    }

    function sdcAddAdmin(address account) public {
        SDC(_sdc).addAdmin(account);
    }

    function sdcBurnFrom(address account, uint256 sum) public {
        SDC(_sdc).burnFrom(account, sum);
    }
}