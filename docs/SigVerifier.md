# Signature verification

Usually when you need to allow some amount of tokens to some account you need to use ERC20 method `approve(address spender, uint256 value)`.

The flow is next:

1. Owner allows some sum for spender: `approve(spender, value)`
2. Spender can check sum via `allowance(owner, spender)`
3. Then spender calls `transferFrom(sender, recipient, amount)` to transfer tokens to himself

The commission for `approve` is taken from contract owner in ETH
The commission for `transferFrom` is taken from spender in ETH

## Problem

We need to free our user from paying fee for `approve`

Let's check `payment` method in Escrow contract: the user have to call `approve` and pay fee for approve. In our project user has to be free from paying fee.

## Solution

We will use unique signatures which can be created with user's private key. This signature can be easily verified with user's address and it can't be falsified.

There are three arguments needed to create signature: user address, second address (receiver, contract, etc) and user nonce. Nonce increments with every verified signature, so it can't be used twice to create same signature.

Steps to create valid signature

> _from - user address, _to - some receiver, nonce

1. Get current nonce for _from
2. Pack together next params:
    bytes20(_from) + bytes12(0)
    + bytes20(_to) + bytes12(0)
    + uint256(nonce)
3. Take SHA3 hash from packed parameters
4. Sign hash with _from's private key

### JS example

> Full example: `test/testSigSDC.js`

```javascript

// obtain user current nonce
let nonce = await sdc.getNonce.call(_from).then(parseInt)

// pack arguments for hashing
let b = web3.eth.abi.encodeParameters(
    ['bytes20', 'bytes20', 'uint256'],
    [_from, _to, nonce])

// hashing
let h = web3.utils.sha3(b)

// option 1 - sign hash via private key
let sign_result = await web3.eth.accounts.sign(h, privateKey)
let sig = sign_result.signature

// option 2 - sign hash via address. web3 should private key of _from
let sig = await web3.eth.sign(h, _from)

//---
sig = web3.utils.hexToBytes(sig)
```

When someone gets non-verified signature he can use it to make some action on behalf of tokens owner. So user can pass his signature to escrow contract and it can approve needed tokens for payment. There is method named `approveSig` in SDC contract to approve some amount of tokens with owner's signature.
