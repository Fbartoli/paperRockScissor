const { expect } = require("chai");
const { ethers } = require("hardhat");


var coin
var rps
before(async () => {
  const [deployer, player1, player2] = await ethers.getSigners();
  const Coin = await ethers.getContractFactory("Standard_Token");
  coin = await Coin.deploy(1000000000000000, 'COIN', 8, "COIN");
  await coin.deployed();

  const Rps = await ethers.getContractFactory("RPS");
  rps = await Rps.deploy(coin.address);
  await rps.deployed();

  let txn = await coin.transfer(player1.address, 10)
  await txn.wait();
  txn = await coin.transfer(player2.address, 10)
  await txn.wait();
})

describe("RPS", function () {
  it("Allows a player1 to set move and bet an amount", async function () {
    const [deployer, player1, player2] = await ethers.getSigners();
    let move = 0
    let bet = 10
    console.log((await coin.balanceOf(player1.address)).toNumber())
    let txn = await coin.connect(player1).approve(rps.address, 100000000000000);
    await txn.wait()
    txn = await rps.connect(player1).setMove(move, bet);
    await txn.wait()
    console.log((await coin.balanceOf(player1.address)).toNumber())
    let data = await rps.connect(player1).seeMove();
    expect(data[0]).to.equal(move)
    expect(data[1].toNumber()).to.equal(bet)
    expect(data[2]).to.equal(player1.address)
    expect(data[3]).to.equal(true)
  });
  it("Allows two players to play (player2 should win)", async function () {
    const [deployer, player1, player2] = await ethers.getSigners();
    let move = 1
    let bet = 10
    console.log((await coin.balanceOf(player2.address)).toNumber())
    let txn = await coin.connect(player2).approve(rps.address, 100000000000000);
    await txn.wait()
    
    txn = await rps.connect(player2).setMove(move, bet);
    await txn.wait()
    console.log((await coin.balanceOf(player2.address)).toNumber())

    await rps.connect(player1).play(player2.address)
    console.log(await rps.lastWinner());
    console.log((await coin.balanceOf(player2.address)).toNumber())
    console.log((await coin.balanceOf(player1.address)).toNumber())
    expect(await rps.lastWinner()).to.equal(player2.address)
    expect((await coin.balanceOf(player2.address)).toNumber()).to.equal(bet * 2)
  });
});
