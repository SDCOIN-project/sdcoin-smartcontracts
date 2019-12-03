var SDC = artifacts.require('SDC')
var LUV = artifacts.require('LUV')
var Swap = artifacts.require('Swap')
var Escrow = artifacts.require('Escrow')

var TestHelper = artifacts.require('TestHelper')

contract('Escrow', (accounts) => {
    let sdc, luv, swap

    before(async () => {
        sdc = await SDC.deployed()
        luv = await LUV.deployed()
        swap = await Swap.deployed()
    })

    let payment = async (escrow, buyerAddr, fromAddr, buyAmount) => {
        let nonce = await sdc.getNonce.call(buyerAddr)
        nonce = parseInt(nonce)

        let b = web3.eth.abi.encodeParameters(
            ['bytes20', 'bytes20', 'uint256'],
            [buyerAddr, escrow.address, nonce])
        let h = web3.utils.sha3(b)

        let sig = await web3.eth.sign(h, buyerAddr)
        sig = web3.utils.hexToBytes(sig)

        let est = await escrow.payment.estimateGas(buyAmount, buyerAddr, sig, {from: fromAddr})
        let tx = await escrow.payment.sendTransaction(buyAmount, buyerAddr, sig, {from: fromAddr, gas: est})

        return {tx: tx, est: est}
    }

    it('several payments + withdraw LUV test', async function() {
        let id = 1, price = 100, amount = 15
        let escrow = await Escrow.new(accounts[0], id, price, amount,
                                      sdc.address, luv.address, swap.address)

        let buyerAddr = accounts[1]
        await web3.eth.personal.unlockAccount(buyerAddr)

        let fromAddr = accounts[2]

        let ethVal = web3.utils.toWei('1', 'ether')
        await web3.eth.sendTransaction({from: fromAddr, to: escrow.address, value: ethVal})
        assert.equal(await web3.eth.getBalance(escrow.address), ethVal, "No ether")

        let sdcStartBalance = 100000
        let tester = await TestHelper.deployed()
        await tester.transferSDC(buyerAddr, sdcStartBalance)

        let buyAmount = 3
        for (let i = 0; i < 5; i++) {
            // console.log("Iteration: ", i)

            let ethBalance = await web3.eth.getBalance(fromAddr).then(parseInt)
            let curAmount = await escrow.amount.call()

            await payment(escrow, buyerAddr, fromAddr, buyAmount)
            // let res = await payment(escrow, buyerAddr, fromAddr, buyAmount)
            // console.log("Gas est :", res.est)
            // console.log("Gas used:", res.tx.receipt.gasUsed)

            let newEthBalance = await web3.eth.getBalance(fromAddr).then(parseInt)
            let diff = (newEthBalance - ethBalance)/Escrow.defaults().gasPrice
            assert.isAbove(diff, 0, "Should be greater than 0, cause we compensate spent ETH")
            // console.log("Difference: ", Math.round(diff))

            let newAmount = await escrow.amount.call()
            assert.equal(newAmount, curAmount - buyAmount, "Amount should decrease")
        }

        let leftAmount = await escrow.amount.call().then(parseInt)
        assert.equal(leftAmount, 0, "Should be no items on contract")

        let luvEscrowBalance = await luv.balanceOf.call(escrow.address).then(parseInt)
        assert.isAbove(luvEscrowBalance, 0, "Escrow should receive LUV for payments")

        let luvOwnerBalance = await luv.balanceOf.call(accounts[0]).then(parseInt)
        assert.equal(luvOwnerBalance, 0, "Owner shouldn't have LUV")

        let transferredLuv = luvEscrowBalance

        await escrow.withdraw.sendTransaction({from: accounts[0]})

        luvEscrowBalance = await luv.balanceOf.call(escrow.address).then(parseInt)
        assert.equal(luvEscrowBalance, 0, "Escrow should send all LUV to owner")

        luvOwnerBalance = await luv.balanceOf.call(accounts[0]).then(parseInt)
        assert.equal(transferredLuv, luvOwnerBalance,
                     "Owner should receive same amount of LUV, which was on escrow")
    })

    it('withdrawEth test', async function() {
        let id = 1, price = 100, amount = 15
        let escrow = await Escrow.new(accounts[0], id, price, amount,
                                      sdc.address, luv.address, swap.address)
        
        let ethVal = web3.utils.toWei('1', 'ether')
        await web3.eth.sendTransaction({from: accounts[0], to: escrow.address, value: ethVal})

        let curBalance = await web3.eth.getBalance(accounts[0]).then(parseInt)
        let tx = await escrow.withdrawEth.sendTransaction({from: accounts[0]})
        let gasCost = tx.receipt.gasUsed * Escrow.defaults().gasPrice
        let newBalance = await web3.eth.getBalance(accounts[0]).then(parseInt)
        assert.equal(curBalance + parseInt(ethVal) - gasCost, newBalance, "withdrawEth doesn't work")
    })
})
