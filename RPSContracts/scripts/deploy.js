async function main() {
  const [deployer] = await ethers.getSigners();
  const Rps = await ethers.getContractFactory("RPS");
  const rps = await Rps.deploy();
  await rps.deployed();
  console.log(rps.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
