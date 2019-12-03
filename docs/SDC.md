# SDC

## Inheritance

+ ERC20
+ ERC20Detailed
+ ERC20Pausable
+ Ownable

## Public methods

|Function|Parameters|Return|Description|
|---|---|---|---|
|constructor|-//-|-//-|Creates contract and mints all tokens on his address|
|getNonce|address _account|uint256|Returns user nonce. It is needed to create unique signatures for each payment. Doesn't work when contract is on pause|
|approveSig|address _from, address _spender, uint256 _value, bytes calldata _sig|-//-|Works like default approve from ERC20, but it can be called from some account which has signature of sender. Uses signature verification (check SigVerifier.md). Doesn't work when contract is on pause|
|mint|address account, uint256 amount|-//-|Creates new tokens. Can be called by contract owner or admin. Doesn't work when contract is on pause|
|burn|address account, uint256 amount|-//-|Burns existing tokens. Can be called by contract owner or admin. Doesn't work when contract is on pause|
