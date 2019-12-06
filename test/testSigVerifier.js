var SDC = artifacts.require('SDC')

contract('SDC', (accounts) => {
    let sdc

    before(async () => {
        sdc = await SDC.deployed()
    })

    it('ecrecover: web3.eth.sign + accounts', async function() {
        let addr1 = accounts[0]
        let addr2 = accounts[1]

        let value = 1337

        let nonce = await sdc.getNonce.call(addr1).then(parseInt)
        let b = web3.eth.abi.encodeParameters(
            ['bytes20', 'bytes20', 'uint256'],
            [addr1, addr2, nonce])
        let h = web3.utils.sha3(b)
        let sig = await web3.eth.sign(h, addr1).then(web3.utils.hexToBytes)

        await sdc.approveSig.sendTransaction(value, addr1, addr2, sig)
        
        let newNonce = await sdc.getNonce.call(addr1).then(parseInt)
        assert.strictEqual(newNonce, nonce + 1,
                           "Nonce should increment after successful verification")

    })

    it('ecrecover: web3.eth.sign + wallet', async function() {
        let acc1 = web3.eth.accounts.create()
        let addr1 = acc1.address
        web3.eth.accounts.wallet.add(acc1)

        let acc2 = web3.eth.accounts.create()
        let addr2 = acc2.address

        let value = 1337

        let nonce = await sdc.getNonce.call(addr1).then(parseInt)
        let b = web3.eth.abi.encodeParameters(
            ['bytes20', 'bytes20', 'uint256'],
            [addr1, addr2, nonce])
        let h = web3.utils.sha3(b)
        let sig = await web3.eth.sign(h, addr1).then(web3.utils.hexToBytes)

        await sdc.approveSig.sendTransaction(value, addr1, addr2, sig)

        let newNonce = await sdc.getNonce.call(addr1).then(parseInt)
        assert.strictEqual(newNonce, nonce + 1,
                           "Nonce should increment after successful verification")
    })

    it('ecrecover: web3.eth.accounts.sign + wallet', async function() {
        let acc1 = web3.eth.accounts.create()
        let addr1 = acc1.address
        let priv1 = acc1.privateKey
        web3.eth.accounts.wallet.add(acc1)

        let acc2 = web3.eth.accounts.create()
        let addr2 = acc2.address

        let value = 1337

        let nonce = await sdc.getNonce.call(addr1).then(parseInt)
        let b = web3.eth.abi.encodeParameters(
            ['bytes20', 'bytes20', 'uint256'],
            [addr1, addr2, nonce])
        let h = web3.utils.sha3(b)

        let signResult = await web3.eth.accounts.sign(h, priv1)
        let sig = web3.utils.hexToBytes(signResult.signature)

        await sdc.approveSig.sendTransaction(value, addr1, addr2, sig)

        let newNonce = await sdc.getNonce.call(addr1).then(parseInt)
        assert.strictEqual(newNonce, nonce + 1,
                           "Nonce should increment after successful verification")
    })
})