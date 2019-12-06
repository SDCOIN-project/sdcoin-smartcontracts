var SDC = artifacts.require("SDC");
var LUV = artifacts.require("LUV");
var Swap = artifacts.require("Swap");

var EscrowFactory = artifacts.require("EscrowFactory");

var TestHelper = artifacts.require("TestHelper");

module.exports = async function(deployer, network, accounts) {
  if (network == "test" || network == "development") {
    await deployer.deploy(SDC)
    await deployer.deploy(LUV)
    await deployer.deploy(Swap, 100000, SDC.address, LUV.address)

    let sdc = await SDC.deployed()
    let luv = await LUV.deployed()
    let swap = await Swap.deployed()

    sdc.addWhitelisted(Swap.address)
    luv.addWhitelisted(Swap.address)

    await deployer.deploy(TestHelper)
    let tester = await TestHelper.deployed()
    tester.setAddresses(SDC.address, LUV.address, Swap.address)

    sdc.addWhitelisted(TestHelper.address)
    sdc.addPauser(TestHelper.address)
    luv.addWhitelisted(TestHelper.address)
    swap.addWhitelisted(TestHelper.address)

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

    sdc.addWhitelisted(Swap.address, {from: addr0})
    luv.addWhitelisted(Swap.address, {from: addr0})

    // EscrowFactory
    await deployer.deploy(EscrowFactory, Swap.address, {from: addr0})
  }
};