# Swap

## Inheritance

+ Ownable

## Public methods

|Function|Parameters|Return|Description|
|---|---|---|---|
|constructor|uint256 _sdcExchangeRate, address _sdcAddress, address _luvAddress|-//-|Creates swap contract, sets default SDC exchange rate and stores SDC and LUV contracts addresses|
|swap|address receiver|uint256|Swaps SDC to LUV with current SDC exchange rate|
|countSDCFromLUV|uint256 luvAmount|uint256|Counts amount of SDC needed to get given amount of LUV|
|updateRate|uint256 _exchangeRate|-//-|Update SDC exchange rate. Can be called only by admin or owner|

## Getters

|Getter|Type|Description|
|---|---|---|
|sdc|address|Returns address of SDC contract|
|luv|address|Returns address of LUV contract|

## Swap process

To use this correctly you need to approve some amount of SDC for conversion. Swap contract checks his allowance, burns SDC and removes allowance.
Resulting LUV will be transfered to _receiver.

LUV counted as:
`luv = sdc * (sdc-to-fiat) / (luv-to-fiat)`, where `sdc-to-fiat` and `luv-to-fiat` - exchange rates. SDC exchange rate can be changed via updateSDCRate. LUV exchange rate is fixed.
