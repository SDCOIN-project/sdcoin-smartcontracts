var SDCoin = artifacts.require('SDCoin')

var Web3 = require('web3')
var web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

contract('SDCoin', (accounts) => {
    it('ecrecover result matches address', async function() {
        var instance = await SDCoin.deployed()

        // let acc1 = web3.eth.accounts.create()
        // let addr1 = acc1.address
        let acc1 = accounts[0]
        let addr1 = accounts[0]

        let acc2 = web3.eth.accounts.create()
        let addr2 = acc2.address

        let value = 1337

        let repeats = 5
        for (let i = 0; i < repeats; i++) {
            let nonce = await instance.getNonce.call(addr1)
            nonce = parseInt(nonce)
            console.log("Nonce: ", nonce)

            let val = value * (i+1);

            let b = web3.eth.abi.encodeParameters(
                ['bytes20', 'bytes20', 'uint256', 'uint256'],
                [addr1, addr2, val, nonce])
            let h = web3.utils.sha3(b)
            let sig = await web3.eth.sign(h, acc1)
            console.log(sig)
            sig = web3.utils.hexToBytes(sig)

            await instance.approveSig(addr1, addr2, val, sig)

            let allowance = await instance.allowance(addr1, addr2)
            console.log(parseInt(allowance))
            assert.strictEqual(parseInt(allowance), val, "Allowance and value not equal")
        }
    })
})