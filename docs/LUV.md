# LUV

## Inheritance

+ OpenZeppelin's ERC20
+ OpenZeppelin's ERC20Detailed
+ OpenZeppelin's WhitelistedRole

## Public methods

|Function|Parameters|Return|Description|
|---|---|---|---|
|constructor|-//-|-//-|Creates contract and mints all tokens on his address|
|mint|address account, uint256 amount|-//-|Creates new tokens. Can be called by whitelisted account|
|burn|address account, uint256 amount|-//-|Burns existing tokens. Can be called by whitelisted account|
