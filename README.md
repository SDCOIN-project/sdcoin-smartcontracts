# SDCOIN contracts

There are four main contracts:

1. `SDC` - utility token
2. `LUV` - stable coin
3. `Swap` - conversion between `SDC` and `LUV`
4. `Escrow` - store contract

All contract and their dependencies described in `docs/` folder

## Deployment

The deployment goes via Infura cluster, so you need to create project at your Infura account and get project id

Two ways to setup deployment in testnet Rinkeby (described below)

1. using mnemonics
2. using account private key

The deployed contracts are SDC, LUV, Swap and one Escrow

### Mnemonics

Using npm module `@truffle/hdwallet-provider`.

At the beginning of `truffle-config.js` should be declared:

```js
    const HDWalletProvider = require("@truffle/hdwallet-provider")
    const mnemonic = // your mnemonics ...
```

In `module.exports.networks` should be next section (note that you should put your Infura ProjectID in provider):

```js
    rinkeby: {
      provider: () => new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/<YOUR-PROJECT-ID>`),
      network_id: 4,       // Rinkeby's id
      host: "127.0.0.1",   // Localhost (default: none)
      port: 8545,          // Standard Ethereum port (default: none)
    },
```

### Private key

Using npm module `truffle-privatekey-provider`.

At the beginning of `truffle-config.js` should be declared next lines:

```js
    const PrivateKeyProvider = require("truffle-privatekey-provider");
    const privateKey = // your private key ...
```

In `module.exports.networks` should be next section (note that you should put your Infura ProjectID in provider):

```js
    rinkeby: {
      provider: () => new PrivateKeyProvider(privateKey, `https://rinkeby.infura.io/v3/<YOUR-PROJECT-ID>`),
      network_id: 4,       // Rinkeby's id
      host: "127.0.0.1",   // Localhost (default: none)
      port: 8545,          // Standard Ethereum port (default: none)
    },
```

---

To start deployment use next command:

```bash
    truffle migrate --network rinkeby
```

In case of successfull deployment you should get contract addresses

## ABI

1. Compile contracts: `truffle compile`. It should create folder `build/` in project
2. Use build to take ABI (example for SDC contract):

    ```js
    const fs = require('fs');
    const contract = JSON.parse(fs.readFileSync('./build/contracts/SDC.json', 'utf8'))
    console.log(JSON.stringify(contract.abi));
    ```
