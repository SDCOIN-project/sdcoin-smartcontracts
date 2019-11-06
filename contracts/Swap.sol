pragma solidity ^0.5.11;

import "./LUV.sol";
import "./SDC.sol";
import "./access/roles/WhitelistAdminRole.sol";

contract Swap is WhitelistAdminRole {

    SDCoin private _sdc;
    LUV private _luv;

    uint256 public exchangeRate;
    uint16 constant divisor = 1000;

    constructor(uint256 _exchangeRate, address[] memory _admins) public {
        _sdc = SDCoin(msg.sender);
        _luv = new LUV(_admins);
        exchangeRate = _exchangeRate;

        for (uint8 i = 0; i < _admins.length; i++) {
            addWhitelistAdmin(_admins[i]);
        }
    }

    function swap(address receiver) external {
        uint256 sdcAmount = _sdc.allowance(msg.sender, address(this));
        require(sdcAmount > 0, "No SDC for conversion");

        uint256 krw = sdcAmount * exchangeRate;
        uint256 luvAmount = krw / divisor;

        require(luvAmount > 0, "Too few sdc to convert");

        _sdc.transferFrom(msg.sender, address(this), sdcAmount);
        _luv.mint(receiver, luvAmount);
        _sdc.burn(address(this), sdcAmount);
    }

    function updateRate(uint256 _exchangeRate) external onlyWhitelistAdmin {
        exchangeRate = _exchangeRate;
    }
}