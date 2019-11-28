pragma solidity ^0.5.11;

import "./LUV.sol";
import "./SDC.sol";
import "./Ownable.sol";

contract Swap is Ownable {
    SDC public sdc;
    LUV public luv;

    uint256 public exchangeRate;
    uint16 constant divisor = 1000;

    constructor(uint256 _exchangeRate, address _sdcAddress, address _luvAddress) public {
        exchangeRate = _exchangeRate;

        sdc = SDC(_sdcAddress);
        luv = LUV(_luvAddress);
    }

    function swap(address _receiver) external returns(uint256) {
        uint256 sdcAmount = sdc.allowance(msg.sender, address(this));
        require(sdcAmount > 0, "No SDC for conversion");

        uint256 luvAmount = (sdcAmount * exchangeRate) / divisor;
        require(luvAmount > 0, "Too few SDC to convert");

        sdc.burnFrom(msg.sender, sdcAmount);
        luv.mint(_receiver, luvAmount);

        return luvAmount;
    }

    function countSDCFromLUV(uint256 luvAmount) external view returns(uint256) {
        uint256 krwAmount = luvAmount * divisor;
        uint256 sdcAmount = krwAmount / exchangeRate;
        if (krwAmount % exchangeRate != 0) sdcAmount++;
        return sdcAmount;
    }

    function updateRate(uint256 _exchangeRate) external onlyOwnerOrAdmin {
        exchangeRate = _exchangeRate;
    }
}