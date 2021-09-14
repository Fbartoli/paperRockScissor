const abi =  require('../artifacts/contracts/RPS.sol/RPS.json')
async function main() {
  const [deployer, player1] = await ethers.getSigners();
  const rps = new ethers.Contract('0x623a458CE1a636901A3c8E323D703fFD7F1Cf700', abi.abi,deployer)
  // const Rps = await ethers.getContractFactory("RPS");
  // const rps = await Rps.deploy();
  // await rps.deployed();

  rps.on("TheWinnerIs", data => {
    console.log("the event", data)
  })

  rps.on("MoveSet", data => {
    console.log("the event", data)
  })

  let txn = await rps.setMove(0, 10);
  await txn.wait()
  let data = await rps.seeMove()
  console.log(data[0], data[1].toNumber(), data[2])

  console.log(player1.address)
  let txn2 = await rps.connect(player1).setMove(0, 10);
  await txn2.wait()
  let data2 = await rps.connect(player1).seeMove()
  console.log(data2[0], data2[1].toNumber(), data2[2])

  let txn3 = await rps.play(player1.address)
  console.log(await rps.lastWinner());

}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
