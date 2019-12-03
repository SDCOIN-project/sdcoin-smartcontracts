pragma solidity ^0.5.11;

import "./LUV.sol";
import "./SDC.sol";
import "./Ownable.sol";

/// @title Swap contract for swapping SDC (utility token) to LUV (stable coin)
contract Swap is Ownable {
    /// @notice address of SDC contract
    SDC public sdc;
    /// @notice address of LUV contract
    LUV public luv;

    /// @notice Conversion rate from SDC to fiat
    /// Should be updated regularily by contract owner or admin
    uint256 public sdcExchangeRate;
    /// @notice Conversion rate from LUV to fiat
    uint16 constant public luvExchangeRate = 1000;

    /**
        @param _sdcExchangeRate - default SDC exchange rate
        @param _sdcAddress - SDC contract address
        @param _luvAddress - LUV contract address
     */
    constructor(uint256 _sdcExchangeRate, address _sdcAddress, address _luvAddress) public {
        sdcExchangeRate = _sdcExchangeRate;

        sdc = SDC(_sdcAddress);
        luv = LUV(_luvAddress);
    }

    /**
        @notice Swaps SDC to LUV
        To use this correctly you need to approve SDC amount
        for conversion. Swap contract checks his allowance,
        burns it and removes allowance.
        Resulting LUV will be transfered to _receiver.

        LUV counted as:
        luv = sdc * (sdc-to-fiat) / (luv-to-fiat)
     */
    function swap(address _receiver) external returns(uint256) {
        uint256 sdcAmount = sdc.allowance(msg.sender, address(this));
        require(sdcAmount > 0, "No SDC for conversion");

        uint256 luvAmount = (sdcAmount * sdcExchangeRate) / luvExchangeRate;
        require(luvAmount > 0, "Too few SDC to convert");

        sdc.burnFrom(msg.sender, sdcAmount);
        luv.mint(_receiver, luvAmount);

        return luvAmount;
    }

    /// @notice Counts amount of SDC needed to get given amount of LUV
    function countSDCFromLUV(uint256 luvAmount) external view returns(uint256) {
        uint256 krwAmount = luvAmount * luvExchangeRate;
        uint256 sdcAmount = krwAmount / sdcExchangeRate;
        if (krwAmount % sdcExchangeRate != 0) sdcAmount++;
        return sdcAmount;
    }

    /// @notice Update SDC-to-fiat exchange rate
    /// Can be called only by admin or owner
    function updateSDCRate(uint256 _sdcExchangeRate) external onlyOwnerOrAdmin {
        sdcExchangeRate = _sdcExchangeRate;
    }
}