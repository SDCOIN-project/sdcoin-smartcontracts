pragma solidity ^0.5.11;

import "./LC.sol";
import "./SDC.sol";

contract Swap is Ownable {

    address private SDCAddress;
    address private LCAddress;

    uint256 public KRW_in_SDC;
    uint16 constant divisor = 1000;

    constructor(address _SDCAddress, uint256 _KRW_in_SDC) public {
        SDCAddress = _SDCAddress;
        KRW_in_SDC = _KRW_in_SDC;

        LC lc = new LC();
        LCAddress = address(lc);
    }

    function swap(address receiver) external {
        SDCoin sdc = SDCoin(SDCAddress);
        LC lc = LC(LCAddress);

        uint256 sdcAmount = sdc.allowance(msg.sender, address(this));
        require(sdcAmount > 0, "No SDC for conversion");

        uint256 krw = sdcAmount * KRW_in_SDC;
        uint256 lcAmount = krw / divisor;

        require(lcAmount > 0, "Too few sdc to convert");

        sdc.transferFrom(msg.sender, address(this), sdcAmount);
        lc.mint(receiver, lcAmount);
        sdc.burn(sdcAmount);
    }

    function updateRate(uint256 _KRW_in_SDC) external onlyOwner {
        KRW_in_SDC = _KRW_in_SDC;
    }
}