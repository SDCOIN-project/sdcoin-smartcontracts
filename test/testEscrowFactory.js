var Swap = artifacts.require('Swap')
var EscrowFactory = artifacts.require('EscrowFactory')
var Escrow = artifacts.require('Escrow')

contract('EscrowFactory', (accounts) => {
    let swap

    before(async () => {
        swap = await Swap.deployed()
    })

    it('test getEscrowByIndex', async () => {
        let factory = await EscrowFactory.new(swap.address)

        let repeats = 5
        for (let i = 0; i < repeats; i++) {
            let tx = await factory.create.sendTransaction(0, 1, {from: accounts[0]})
            let escrowAddr = tx.logs[0].args._escrowAddress
            let escrowIndex = tx.logs[0].args._escrowIndex.toNumber()
            assert.equal(escrowAddr,
                         await factory.getEscrowByIndex(accounts[0], escrowIndex),
                         "Incorrect address on given index")
        }
    })

    it('test getEscrowList', async () => {
        let factory = await EscrowFactory.new(swap.address)

        let repeats = 5
        let addrs = []
        for (let i = 0; i < repeats; i++) {
            let tx = await factory.create.sendTransaction(0, 1, {from: accounts[0]})
            addrs.push(tx.logs[0].args._escrowAddress)
        }

        let factoryAddrs = await factory.getEscrowList.call(accounts[0])

        for (let i = 0; i < repeats; i++) {
            assert.equal(factoryAddrs[i], addrs[i], "Incorrect address in list")
        }
    })
})