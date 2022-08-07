// scripts/chain-battles.js

const hre = require("hardhat");

// Returns the Ether balance of a given address.
async function getBalance(address) {
  const balanceBigInt = await hre.ethers.provider.getBalance(address);
  
  //.waffle.provider.getBalance(address);
  return hre.ethers.utils.formatEther(balanceBigInt);
}

// Logs the Ether balances for a list of addresses.
async function printBalances(addresses) {
  let idx = 0;
  for (const address of addresses) {
    console.log(`Address ${idx} balance: `, await getBalance(address));
    idx ++;
  }
}

// Logs the memos stored on-chain from coffee purchases.
async function printMints(mints) {
    //0 index is 1 
    let idx = 1;
    for (const mint of mints) {
      const Level = mint.Level;
      const Speed = mint.Speed;
      const Strength = mint.Strength;
      const Life = mint.Life;
      console.log(`Character # ${idx}, is Level ${Level}, has Speed ${Speed}, Strength ${Strength} and Lives ${Life} `);
      idx++;
    }
  }


async function main() {
  // Get the example accounts we'll be working with.
  const [owner, owner2] = await hre.ethers.getSigners();

  // We get the contract to deploy.
  const ChainBattles = await hre.ethers.getContractFactory("ChainBattles");
  const chainBattles = await ChainBattles.deploy();

  // Deploy the contract.
  await chainBattles.deployed();
  console.log("ChainBattles deployed to:", chainBattles.address);

  // Check balances before the minting.
  const addresses = [owner.address, owner2.address];
  console.log("== start ==");
  await printBalances(addresses);

  //mint 2 and upgrade one
  await chainBattles.connect(owner).mint();
  await chainBattles.connect(owner2).mint();
  


  // Check balances after the minting
  console.log("== minted Characters ==");
  await printBalances(addresses);



  // Check out the mints.
  console.log("== mints ==");
  const mints = await chainBattles.getMints();
  printMints(mints);

   // Check balances after the training + 1 new mint for baseline.

   await chainBattles.connect(owner2).train(2);
   await chainBattles.connect(owner).train(1);
   await chainBattles.connect(owner2).mint();

 
   console.log("== trained Characters ==");
   await printBalances(addresses);
 
    // Check out the mints.
    console.log("== mints ==");
    const mints2 = await chainBattles.getMints();
    printMints(mints2);

 

  //try to train a non-owned mint
  //await chainBattles.connect(owner2).train(1);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
