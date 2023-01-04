import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { ethers as vanillaEthers } from "ethers";

describe("ETHBank", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployETHExploitFixture() {

    // Contracts are deployed using the first signer/account by default
    const [owner, alice, bob] = await ethers.getSigners();

    const EthLendingPool = await ethers.getContractFactory("EthLendingPool");
    const EthLendingPoolExploit = await ethers.getContractFactory("EthLendingPoolExploit");

    const ethLendingPool = await EthLendingPool.deploy();
    const ethLendingPoolExploit = await EthLendingPoolExploit.deploy(ethLendingPool.address);

    return { owner, alice, bob, ethLendingPool, ethLendingPoolExploit };
  }

  describe("Deployment", function () {
    it("Should test for the balance", async function () {
      const { owner, alice, bob, ethLendingPool, ethLendingPoolExploit } = await loadFixture(deployETHExploitFixture);

      expect(await ethLendingPool.getBalance()).to.equal(0);
    });
  });

  describe("Exploit", function () {
    it("Should test for ETHFlashLoan exploit", async function () {
      const { owner, alice, bob, ethLendingPool, ethLendingPoolExploit } = await loadFixture(deployETHExploitFixture);

      const depositByBob = await ethLendingPool.deposit({ value: vanillaEthers.utils.parseEther('10') });

      // The below txn shall console the sequence of the flash loan exploit from the contract itself
      const depositTxn = await ethLendingPoolExploit.pwn();
    });


    // describe("Validations", function () {
    //   it("Should revert with the right error if called too soon", async function () {
    //     const { lock } = await loadFixture(deployOneYearLockFixture);

    //     await expect(lock.withdraw()).to.be.revertedWith(
    //       "You can't withdraw yet"
    //     );
    //   });

    //   it("Should revert with the right error if called from another account", async function () {
    //     const { lock, unlockTime, otherAccount } = await loadFixture(
    //       deployOneYearLockFixture
    //     );

    //     // We can increase the time in Hardhat Network
    //     await time.increaseTo(unlockTime);

    //     // We use lock.connect() to send a transaction from another account
    //     await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
    //       "You aren't the owner"
    //     );
    //   });

  });
});
