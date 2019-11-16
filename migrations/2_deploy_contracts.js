var SDC = artifacts.require("SDC");
var LUV = artifacts.require("LUV");
var Swap = artifacts.require("Swap");

var TestHelper = artifacts.require("TestHelper");

module.exports = async function(deployer, network, accounts) {
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
};