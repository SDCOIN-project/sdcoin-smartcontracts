var SDC = artifacts.require('SDC')
var LUV = artifacts.require('LUV')
var Swap = artifacts.require('Swap')
var Escrow = artifacts.require('Escrow')

var TestHelper = artifacts.require('TestHelper')

const BigNumber = require('bignumber.js')

contract('Escrow', (accounts) => {
    let sdc, luv, swap

    before(async () => {
        sdc = await SDC.deployed()
        luv = await LUV.deployed()
        swap = await Swap.deployed()
    })

    let getSignature = async (sdcInst, addr1, addr2) => {
        let nonce = await sdcInst.getNonce.call(addr1).then(parseInt)
        let b = web3.eth.abi.encodeParameters(
            ['bytes20', 'bytes20', 'uint256'],
            [addr1, addr2, nonce])
        let h = web3.utils.sha3(b)
        return web3.eth.sign(h, addr1).then(web3.utils.hexToBytes)
    }

    let payment = async (escrow, buyerAddr, fromAddr) => {
        let sig = await getSignature(sdc, buyerAddr, escrow.address)
        let est = await escrow.payment.estimateGas(buyerAddr, sig, {from: fromAddr})
        let tx = await escrow.payment.sendTransaction(buyerAddr, sig, {from: fromAddr, gas: est})
        return {tx: tx, est: est}
    }

    it('payable constructor test', async function() {
        let id = 1, price = 100
        let ethVal = web3.utils.toWei('1', 'ether')
        let escrow = await Escrow.new(accounts[0], id, price, swap.address,
                                      {from: accounts[0], value: ethVal})
        let escrowBalance = await web3.eth.getBalance(escrow.address).then(parseInt)
        assert.equal(parseInt(ethVal), escrowBalance, "Escrow ETH balance incorrect")
    })

    it('several payments + withdraw LUV test', async function() {
        let id = 1, price = 100
        let escrow = await Escrow.new(accounts[0], id, price, swap.address)

        let buyerAddr = accounts[1]
        await web3.eth.personal.unlockAccount(buyerAddr)

        let fromAddr = accounts[2]

        let ethVal = web3.utils.toWei('1', 'ether')
        await web3.eth.sendTransaction({from: fromAddr, to: escrow.address, value: ethVal})
        assert.equal(await web3.eth.getBalance(escrow.address), ethVal, "No ether")

        let sdcStartBalance = 100000
        let tester = await TestHelper.deployed()
        await tester.transferSDC(buyerAddr, sdcStartBalance)

        for (let i = 0; i < 5; i++) {
            let ethBalance = await web3.eth.getBalance(fromAddr).then(parseInt)

            await payment(escrow, buyerAddr, fromAddr)

            let newEthBalance = await web3.eth.getBalance(fromAddr).then(parseInt)
            let diff = (newEthBalance - ethBalance)/Escrow.defaults().gasPrice
            assert.isAbove(diff, 0, "Should be greater than 0, cause we compensate spent ETH")
        }

        let luvEscrowBalance = await luv.balanceOf.call(escrow.address).then(parseInt)
        assert.isAbove(luvEscrowBalance, 0, "Escrow should receive LUV for payments")

        let luvOwnerBalance = await luv.balanceOf.call(accounts[0]).then(parseInt)
        assert.equal(luvOwnerBalance, 0, "Owner shouldn't have LUV")

        let transferredLuv = luvEscrowBalance

        try {
          await escrow.withdraw.sendTransaction({from: accounts[1]})
          assert(false, "Should throw cause account is not owner of escrow")
        } catch (e) { }

        await escrow.withdraw.sendTransaction({from: accounts[0]})

        luvEscrowBalance = await luv.balanceOf.call(escrow.address).then(parseInt)
        assert.equal(luvEscrowBalance, 0, "Escrow should send all LUV to owner")

        luvOwnerBalance = await luv.balanceOf.call(accounts[0]).then(parseInt)
        assert.equal(transferredLuv, luvOwnerBalance,
                     "Owner should receive same amount of LUV, which was on escrow")
    })

    it('withdrawEth test', async function() {
        let id = 1, price = 100
        let escrow = await Escrow.new(accounts[0], id, price, swap.address)
        
        let ethVal = web3.utils.toWei('1', 'ether')
        await web3.eth.sendTransaction({from: accounts[0], to: escrow.address, value: ethVal})

        let prevBalance = await web3.eth.getBalance(accounts[0]).then(parseInt)

        try {
          await escrow.withdrawEth.sendTransaction({from: accounts[1]})
          assert(false, "Should throw cause account is not owner of escrow")
        } catch (e) { }

        assert.equal(await web3.eth.getBalance(accounts[0]).then(parseInt), prevBalance, "Balance shouldn't change")
        assert.equal(await web3.eth.getBalance(escrow.address).then(parseInt), ethVal, "Incorrect ETH balance for escrow")

        await escrow.withdrawEth.sendTransaction({from: accounts[0]})
        assert.equal(await web3.eth.getBalance(escrow.address).then(parseInt), 0, "Incorrect ETH balance for escrow. Should be 0 after withdraw")
    })

    it('escrow transfer test', async function() {
        let id = 0, priceLUV = String(100e18), priceSDC = 10e18
        let ethVal = web3.utils.toWei('1', 'ether')
        let escrow = await Escrow.new(accounts[0], id, priceLUV, swap.address,
                                      {from: accounts[0], value: ethVal})
        
        let sdcRate = await swap.sdcExchangeRate().then(parseInt)
        let luvRate = await swap.luvExchangeRate().then(parseInt)
        let expectedLUV = BigNumber(priceSDC).multipliedBy(sdcRate).dividedBy(luvRate)

        let tester = await TestHelper.deployed()
        await tester.transferSDC(accounts[3], String(priceSDC))
        assert.equal(await sdc.balanceOf.call(accounts[3]).then(parseInt), priceSDC, "More SDC then needed for test")

        await payment(escrow, accounts[3], accounts[4])
        
        assert.equal(await sdc.balanceOf.call(accounts[3]).then(parseInt), 0, "All SDC should be spents")
        assert.equal(await luv.balanceOf.call(escrow.address).then(parseInt), expectedLUV,
                     "Incorrect LUV balance on escrow")
    })
})
