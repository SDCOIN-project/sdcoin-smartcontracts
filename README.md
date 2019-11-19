# SDCOIN контракты

## Развертывание SDC, LUV, Swap и Escrow в Rinkeby

Для развертывания в testnet используется npm модуль `@truffle/hdwallet-provide`
Развёртывание происходит на кластере `infura`. В `truffle-config.js` в секции `module.exports - networks - rinkeby - provider` требуется указать ID проекта в `infura`

```js
    rinkeby: {
      provider: () => new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/<INFURA-PROJECT-ID>`),
      network_id: 4,       // Rinkeby's id
      host: "127.0.0.1",   // Localhost (default: none)
      port: 8545,          // Standard Ethereum port (default: none)
    }
```

Для развертывания в Rinkeby требуется запустить команду:

```bash
truffle migrate --network rinkeby
```

В результате выполнения в консоль должны быть выведены данные о развернутых контрактах

### Методы контрактов

Все публичные методы описаны в `docs/` для каждого контракта в соответствующих файлах

### Escrow

Escrow контракт должен создаваться для каждого товара. На данный момент разворачивается один контракт в качестве примера.
Для работы с контрактом нужно перевести ему некоторое количество эфира

### Abi

+ Компилируем контракты

    ```bash
    truffle compile
    ```

    В проекте создаётся папка `build/`

+ Из билда вытаскиваем Abi (Пример для SDC контракта)

    ```js
    const fs = require('fs');
    const contract = JSON.parse(fs.readFileSync('./build/contracts/SDC.json', 'utf8'))
    console.log(JSON.stringify(contract.abi));
    ```

### Развернутые контракты

+ SDC: 0x271A509DA2dc7DDB46Ed25E7d109579C363EE4ac
+ LUV: 0xDa2A36bDe6b0b87C72701d94Fa4C2BC2d70D9b2c
+ Swap: 0x1E78Db4b3B50a31cc07c7505a4840C86727Bab84
+ Escrow: 0x5CB6F4c0b3AA1f4195E41A4976fC816e0F139955

+ Адрес админа контрактов: 0x1fe2407c888d6d7d41021d45e9f22781f6641629
+ Приватный ключ админа: 0x6775d0b5a98be0abd8ed97526424a0423dbdfbf4f7f227a5316d02b3c7505c8f
+ Mnemonics: `furnace tape pull comfort roof romance document more cool basket ginger evil olympic rude someone`
