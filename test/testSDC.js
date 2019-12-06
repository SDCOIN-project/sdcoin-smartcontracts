var SDC = artifacts.require('SDC')

contract('SDC', (accounts) => {
    let sdc

    before(async () => {
        sdc = await SDC.deployed()
    })

    let getSignature = async (sdcInst, addr1, addr2, amount) => {
        let nonce = await sdcInst.getNonce.call(addr1).then(parseInt)
        let b = web3.eth.abi.encodeParameters(
            ['bytes20', 'bytes20', 'uint256', 'uint256'],
            [addr1, addr2, amount, nonce])
        let h = web3.utils.sha3(b)
        return web3.eth.sign(h, addr1).then(web3.utils.hexToBytes)
    }

    it('several verifications with changing nonce (approveSig + getNonce) test', async function() {
        let addr1 = accounts[0]
        let addr2 = accounts[1]
        let value = 1337
        let amount = 12
        let nonce = await sdc.getNonce.call(addr1).then(parseInt)

        let repeats = 5
        for (let i = 0; i < repeats; i++) {
            let sig = await getSignature(sdc, addr1, addr2, amount)
            await sdc.approveSig.sendTransaction(value, addr1, addr2, amount, sig)

            let allowance = await sdc.allowance(addr1, addr2)
            assert.strictEqual(parseInt(allowance), value, "Allowance and value not equal")
            nonce += 1
        }
    })

    it('getNonce pause test', async function() {
        let sdcPause = await SDC.new({from: accounts[0]})
        await sdcPause.getNonce.call(accounts[0])
        await sdcPause.pause.sendTransaction({from: accounts[0]})
        assert.isTrue(await sdcPause.paused.call(), "contract should be on pause")

        try {
            await sdcPause.getNonce(accounts[0])
            assert.equal(false, "contract should throws because it's on pause")
        } catch (e) {}

        await sdcPause.unpause.sendTransaction({from: accounts[0]})
        await sdcPause.getNonce.call(accounts[0])
    })

    it('approveSig pause test', async function() {
        let sdcPause = await SDC.new({from: accounts[0]})
        let value = 1337
        let amount = 12
        let sig = await getSignature(sdcPause, accounts[0], accounts[1], amount)
        await sdcPause.approveSig.sendTransaction(value, accounts[0], accounts[1], amount, sig)

        sig = await getSignature(sdcPause, accounts[0], accounts[1], amount)

        await sdcPause.pause.sendTransaction({from: accounts[0]})
        assert.isTrue(await sdcPause.paused.call(), "contract should be on pause")

        try {
            await sdcPause.approveSig.sendTransaction(value, accounts[0], accounts[1], amount, sig)
            assert.equal(false, "contract should throws because it's on pause")
        } catch(e) {}

        await sdcPause.unpause.sendTransaction({from: accounts[0]})
        sig = await getSignature(sdcPause, accounts[0], accounts[1], amount)
        await sdcPause.approveSig.sendTransaction(value, accounts[0], accounts[1], amount, sig)
    })
})