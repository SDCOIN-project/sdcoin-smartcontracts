# Escrow

## Inheritance

+ OpenZeppelin's Ownable

## Public methods

|Function|Parameters|Return|Description|
|---|---|---|---|
|constructor|address _owner, uint256 _price, uint32 _amount, address _sdcAddress, address _luvAddress, address _swapAddress|-//-|Creates instance of escrow contract and assigns _owner as owner/retailer. Stores other contract addresses to use later (check payment). Checks that price is not 0|
|updatePrice|uint256 _newPriceLUV|-//-|Sets new price for product. Checks that price is not 0. Can be called only by contract owner|
|updateAmount|uint32 _newAmount|-//-|Sets new amount of product. Can be called only by contract owner|
|getPriceSDC|uint32 _amount|-//-|uint256|Counts amount of SDC which is necessary to buy given amount of product|
|payment|uint32 _sellAmount, address _from, bytes calldata _sig|-//-|Pays SDC for given amount of product. Checks whether contract has enough amount of product and throws if it's not enough. Emits event on successful payment|
|withdraw|-//-|-//-|Withdraws all LUVs to owner (retailer). Can be called only by contract owner|
|function () payable|-//-|-//-|Fallback function to accept transferred ETH. Checks that no data passed to method|
|withdrawEth|-//-|-//-|Withdraws all ETH to owner (retailer). Can be called only by contract owner|

## Getters

|Getter|Type|Description|
|---|---|---|
|id|uint32|Product ID|
|price|uint256|Product price|
|amount|uint32|Product amount available for purchasing|

## Events

|Event|Parameters|Description|
|---|---|---|
|Payment|`address _sender` - sender of payment, `uint32 _id` - product ID, `uint256 _unitPrice` - product unit price in LUV, `uint32 _soldAmount` - sold amount of product, `uint256 _priceSDC` - payment price in SDC, `uint256 _priceLUV` - payment price in LUV|Emits on successful payment|

## payment

> payment(uint32 _sellAmount, address _from, bytes calldata _sig)
> Example can be found in `test/testEscrow.js`

The flow is next:

1. User obtains his current nonce from escrow via getNonce() method
2. User creates signature and passes it to payment method arguments
3. User sends transaction with payment method
4. Contract processes payment and returns all fee which user spent
    + if contract doesn't have enough products, it reverts
    + if user doesn't have enough SDC contract reverts
    + if contract doesn't have enough ETH to pay user fee, it reverts
    + contract uses signature to approve SDC needed for successful payment
    + then it transfers SDC and approves them to Swap contract
    + swaps SDC to LUV
    + updates remaining amount of products
    + emits event about successful payment
    + pays user ETH for gas
