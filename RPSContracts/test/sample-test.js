const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RPS", function () {
  it("Allow a player to set move and bet an amount", async function () {
    const [deployer] = await ethers.getSigners();
    const Rps = await ethers.getContractFactory("RPS");
    const rps = await Rps.deploy();
    await rps.deployed();
    let move = 0
    let bet = 10
    let txn = await rps.setMove(move, bet);
    await txn.wait()
    let data = await rps.seeMove();

    expect(data[0]).to.equal(move)
    expect(data[1]).to.equal(bet)
    expect(data[2]).to.equal(deployer.address)
  });
});
