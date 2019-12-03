var SDC = artifacts.require("SDC");
var LUV = artifacts.require("LUV");
var Swap = artifacts.require("Swap");

var Escrow = artifacts.require("Escrow");

var TestHelper = artifacts.require("TestHelper");

module.exports = async function(deployer, network, accounts) {
  if (network == "test" || network == "development") {
    await deployer.deploy(SDC)
    await deployer.deploy(LUV)
    await deployer.deploy(Swap, 100000, SDC.address, LUV.address)

    let sdc = await SDC.deployed()
    let luv = await LUV.deployed()
    let swap = await Swap.deployed()

    sdc.addAdmin(Swap.address)
    luv.addAdmin(Swap.address)

    await deployer.deploy(TestHelper)
    let tester = await TestHelper.deployed()
    tester.setAddresses(SDC.address, LUV.address, Swap.address)

    sdc.addAdmin(TestHelper.address)
    luv.addAdmin(TestHelper.address)
    swap.addAdmin(TestHelper.address)

    sdc.transfer(TestHelper.address, 0xfffffffff)
  } else if (network == "rinkeby") {
    // SDC LUV Swap
    let addr0 = accounts[0]
    let exchangeRate = 10000

    await deployer.deploy(SDC, {from: addr0})
    await deployer.deploy(LUV, {from: addr0})
    await deployer.deploy(Swap, exchangeRate, SDC.address, LUV.address, {from: addr0})

    let sdc = await SDC.deployed()
    let luv = await LUV.deployed()

    sdc.addAdmin(Swap.address, {from: addr0})
    luv.addAdmin(Swap.address, {from: addr0})

    // Escrow
    let id = 0, price = 1, amount = 1000
    await deployer.deploy(Escrow, addr0, id, price, amount, SDC.address, LUV.address, Swap.address)
  }
};