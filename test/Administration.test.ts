import { ethers } from "hardhat";
import { Signer } from "ethers";
import { expect } from "chai";
import { Administration, Betting } from "../typechain"; 

describe("Administration", function () {
  let adminContract: Administration;
  let bettingContract: Betting;
  let admin: Signer;
let user: Signer;


  beforeEach(async function () {
    [admin, user] = await ethers.getSigners();

    const BettingFactory = await ethers.getContractFactory("Betting");
    bettingContract = (await BettingFactory.deploy(admin.address, ethers.utils.parseEther("0.1"))) as Betting;
    await bettingContract.deployed();

    const AdministrationFactory = await ethers.getContractFactory("Administration");
    adminContract = (await AdministrationFactory.deploy(bettingContract.address)) as Administration;
    await adminContract.deployed();
  });

  it("Should allow the admin to add a match", async function () {
    await adminContract.addMatch(1, 2, 3);
    const match = await bettingContract.matches(1);
    expect(match.matchId).to.equal(1);
    expect(match.scoreTeamA).to.equal(2);
    expect(match.scoreTeamB).to.equal(3);
    expect(match.isFinished).to.be.false;
  });

  it("Should prevent non-admins from adding a match", async function () {
    await expect(adminContract.connect(user).addMatch(1, 2, 3)).to.be.revertedWith("Only the admin can call this function.");
  });

  it("Should allow the admin to update a match", async function () {
    await bettingContract.addMatch(1, 2, 3);
    await adminContract.updateMatch(1, 4, 5, true);
    const match = await bettingContract.matches(1);
    expect(match.scoreTeamA).to.equal(4);
    expect(match.scoreTeamB).to.equal(5);
    expect(match.isFinished).to.be.true;
  });

  it("Should prevent non-admins from updating a match", async function () {
    await bettingContract.addMatch(1, 2, 3);
    await expect(adminContract.connect(user).updateMatch(1, 4, 5, true)).to.be.revertedWith("Only the admin can call this function.");
  });

  it("Should allow the admin to delete a match", async function () {
    await bettingContract.addMatch(1, 2, 3);
    await adminContract.deleteMatch(1);
    const match = await bettingContract.matches(1);
    expect(match.matchId).to.equal(0); 
  });

  it("Should prevent non-admins from deleting a match", async function () {
    await bettingContract.addMatch(1, 2, 3);
    await expect(adminContract.connect(user).deleteMatch(1)).to.be.revertedWith("Only the admin can call this function.");
  });

});
