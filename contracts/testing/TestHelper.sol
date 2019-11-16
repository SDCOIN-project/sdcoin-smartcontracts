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

    function checkAlive() public pure returns(bool) {
        return true;
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

    function transfer(address spender, uint256 amount) public {
        SDC(_sdc).transfer(spender, amount);
    }
}