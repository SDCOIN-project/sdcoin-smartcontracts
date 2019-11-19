var SDC = artifacts.require('SDC')
var LUV = artifacts.require('LUV')
var Swap = artifacts.require('Swap')
var Escrow = artifacts.require('Escrow')

var TestHelper = artifacts.require('TestHelper')

var Web3 = require('web3')
var web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))

contract('Escrow', (accounts) => {
    it('payment test', async function() {
        let sdc = await SDC.deployed()
        let luv = await LUV.deployed()
        let swap = await Swap.deployed()

        let ret = web3.eth.accounts.create()
        let retAddr = ret.address
        web3.eth.accounts.wallet.add(ret)

        let gasRequired = 211000

        let escrow = await Escrow.new(retAddr, 1, 1, 2, gasRequired,
                                      sdc.address, luv.address, swap.address)

        let isPrint = false

        let buyerAddr = accounts[2]
        await web3.eth.personal.unlockAccount(buyerAddr)

        let eth_val = web3.utils.toWei('1', 'ether')
        await web3.eth.sendTransaction({
            from: accounts[0],
            to: escrow.address,
            value: eth_val
        })
        assert.equal(await web3.eth.getBalance(escrow.address), eth_val, "No ether")

        let tester = await TestHelper.deployed()
        tester.transfer(buyerAddr, 100000)

        if (isPrint) {
            console.log("Ret:", retAddr)
            console.log("Buyer:", buyerAddr)
        }

        // eth sign
        ////////////////////////////////////////////////////////////////
        let nonce = await sdc.getNonce.call(buyerAddr)
        nonce = parseInt(nonce)
        let b = web3.eth.abi.encodeParameters(
            ['bytes20', 'bytes20', 'uint256'],
            [buyerAddr, escrow.address, nonce])
        let h = web3.utils.sha3(b)

        let sig = await web3.eth.sign(h, buyerAddr)
        sig = web3.utils.hexToBytes(sig)

        let buyAmount = 1

        let ethBalance = await web3.eth.getBalance(buyerAddr)

        // to makes transaction
        let resPrint = await escrow.payment.call(buyAmount, buyerAddr, sig, {from: buyerAddr})
        if (isPrint) console.log(resPrint)

        // to get transaction as object
        let res = await escrow.payment(buyAmount, buyerAddr, sig, {from: buyerAddr})
        if (isPrint) console.log(res)
        // console.log(res.receipt.gasUsed)
        // console.log(sdc.address)

        let newEthBalance = await web3.eth.getBalance(buyerAddr)

        assert.equal(ethBalance, newEthBalance, "balances should be equal")

        // let allowance = await sdc.allowance(addr1, addr2)
        // assert.strictEqual(parseInt(allowance), value, "Allowance and value not equal")
        ////////////////////////////////////////////////////////////////
    })
})