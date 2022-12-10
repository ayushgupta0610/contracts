import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("ETHBank", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployETHBankFixture() {

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();
    const ownerAddress = await owner.getAddress();

    const ETHBank = await ethers.getContractFactory("ETHBank");
    const ethBank = await ETHBank.deploy(ownerAddress);

    return { ethBank, owner, otherAccount, ownerAddress };
  }

  async function deployReentrancyExploitFixture(ethBankContractAddress: string) {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();
    const ownerAddress = await owner.getAddress();

    const ReentrancyExploit = await ethers.getContractFactory("ReentrancyExploit");
    const reentrancyExploit = await ReentrancyExploit.deploy(ethBankContractAddress);

    return { reentrancyExploit, owner, otherAccount, ownerAddress };
  }

  async function deployBankAndExploitFixture() {
    // Contracts are deployed using the first signer/account by default
    // Contracts are deployed using the first signer/account by default
    const [owner, alice, bob] = await ethers.getSigners();
    const ownerAddress = await owner.getAddress();

    const ETHBank = await ethers.getContractFactory("ETHBank");
    const ReentrancyExploit = await ethers.getContractFactory("ReentrancyExploit");


    const ethBank = await ETHBank.deploy(ownerAddress);
    const reentrancyExploit = await ReentrancyExploit.deploy(ethBank.address);

    return { ethBank, reentrancyExploit, owner, ownerAddress };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { ethBank, ownerAddress } = await loadFixture(deployETHBankFixture);

      expect(await ethBank.owner()).to.equal(ownerAddress);
    });
  });

  describe("Exploit", function () {
    it("Should test for ETHBank exploit", async function () {
      const { ethBank, reentrancyExploit, owner, ownerAddress } = await loadFixture(deployBankAndExploitFixture);
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

    //   it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
    //     const { lock, unlockTime } = await loadFixture(
    //       deployOneYearLockFixture
    //     );

    //     // Transactions are sent using the first signer by default
    //     await time.increaseTo(unlockTime);

    //     await expect(lock.withdraw()).not.to.be.reverted;
    //   });
    // });

    // describe("Events", function () {
    //   it("Should emit an event on withdrawals", async function () {
    //     const { lock, unlockTime, lockedAmount } = await loadFixture(
    //       deployOneYearLockFixture
    //     );

    //     await time.increaseTo(unlockTime);

    //     await expect(lock.withdraw())
    //       .to.emit(lock, "Withdrawal")
    //       .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
    //   });
    // });

    // describe("Transfers", function () {
    //   it("Should transfer the funds to the owner", async function () {
    //     const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
    //       deployOneYearLockFixture
    //     );

    //     await time.increaseTo(unlockTime);

    //     await expect(lock.withdraw()).to.changeEtherBalances(
    //       [owner, lock],
    //       [lockedAmount, -lockedAmount]
    //     );
    //   });
    // });
  });
});
