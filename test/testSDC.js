var SDC = artifacts.require('SDC')

var Web3 = require('web3')
var web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))

contract('SDC', (accounts) => {
    it('ecrecover with web3.eth.sign and accounts', async function() {
        let sdc = await SDC.deployed()

        let isPrint = false

        let acc1 = accounts[0]
        let addr1 = accounts[0]

        let acc2 = web3.eth.accounts.create()
        let addr2 = acc2.address

        let value = 1337

        if (isPrint) {
            console.log("From:", addr1)
            console.log("To:", addr2)
        }

        let repeats = 5
        for (let i = 0; i < repeats; i++) {
            let nonce = await sdc.getNonce.call(addr1)
            nonce = parseInt(nonce)
            if (isPrint) console.log("Nonce: ", nonce)

            let val = value * (i+1);

            let b = web3.eth.abi.encodeParameters(
                ['bytes20', 'bytes20', 'uint256', 'uint256'],
                [addr1, addr2, val, nonce])
            if (isPrint) console.log("Packed:", b)
            let h = web3.utils.sha3(b)
            let sig = await web3.eth.sign(h, acc1)
            if (isPrint) console.log("Signature: ", sig)
            sig = web3.utils.hexToBytes(sig)

            if (isPrint) {
                let res = await sdc.approveSig.call(addr1, addr2, val, sig)
                console.log("Result:", res)
            }
            await sdc.approveSig(addr1, addr2, val, sig)

            let allowance = await sdc.allowance(addr1, addr2)
            if (isPrint) console.log("Allowance: ", parseInt(allowance))
            assert.strictEqual(parseInt(allowance), val, "Allowance and value not equal")
        }
    })

    it('ecrecover with web3.eth.sign/web3.eth.accounts.sign and wallet', async function() {
        let sdc = await SDC.deployed()

        let isPrint = false

        let acc1 = web3.eth.accounts.create()
        let addr1 = acc1.address
        let priv1 = acc1.privateKey
        web3.eth.accounts.wallet.add(acc1)

        let acc2 = web3.eth.accounts.create()
        let addr2 = acc2.address

        let value = 1337

        if (isPrint) {
            console.log("From:", addr1)
            console.log("To:", addr2)
        }

        // eth sign
        ////////////////////////////////////////////////////////////////
        let nonce = await sdc.getNonce.call(addr1)
        nonce = parseInt(nonce)
        let b = web3.eth.abi.encodeParameters(
            ['bytes20', 'bytes20', 'uint256', 'uint256'],
            [addr1, addr2, value, nonce])
        let h = web3.utils.sha3(b)

        let sig = await web3.eth.sign(h, addr1)
        sig = web3.utils.hexToBytes(sig)

        if (isPrint) {
            let res1c = await sdc.approveSig.call(addr1, addr2, value, sig)
            console.log("Result:", res1c)
        }
        await sdc.approveSig(addr1, addr2, value, sig)

        let allowance = await sdc.allowance(addr1, addr2)
        assert.strictEqual(parseInt(allowance), value, "Allowance and value not equal")
        ////////////////////////////////////////////////////////////////

        // accounts sign
        ////////////////////////////////////////////////////////////////
        nonce = await sdc.getNonce.call(addr1)
        nonce = parseInt(nonce)
        b = web3.eth.abi.encodeParameters(
            ['bytes20', 'bytes20', 'uint256', 'uint256'],
            [addr1, addr2, value, nonce])
        h = web3.utils.sha3(b)

        let sigres = await web3.eth.accounts.sign(h, priv1)
        if (isPrint) console.log("Sig v:", sigres.v)
        sig = sigres.signature
        sig = web3.utils.hexToBytes(sig)

        if (isPrint) {
            let res2c = await sdc.approveSig.call(addr1, addr2, value, sig)
            console.log("Result:", res2c)
        }
        await sdc.approveSig(addr1, addr2, value, sig)

        allowance = await sdc.allowance(addr1, addr2)
        assert.strictEqual(parseInt(allowance), value, "Allowance and value not equal")
        ////////////////////////////////////////////////////////////////
    })
})