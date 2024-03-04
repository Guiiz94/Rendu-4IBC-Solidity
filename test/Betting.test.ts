import { ethers } from "hardhat";
import { Signer } from "ethers";
import { expect } from "chai";
import { Betting } from "../typechain";

describe("Betting", function () {
  let betting: Betting;
  let owner: Signer;
  let user1: Signer;
  let user2: Signer;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    const BettingFactory = await ethers.getContractFactory("Betting");
    betting = (await BettingFactory.deploy(owner.address, ethers.utils.parseEther("0.1"))) as Betting;
    await betting.deployed();
  });

  it("Should allow the admin to add a match", async function () {
    await betting.addMatch(1, 2, 3);
    const match = await betting.matches(1);
    expect(match.matchId).to.equal(1);
    expect(match.scoreTeamA).to.equal(2);
    expect(match.scoreTeamB).to.equal(3);
    expect(match.isFinished).to.be.false;
  });

  it("Should prevent non-admins from adding a match", async function () {
    await expect(betting.connect(user1).addMatch(1, 2, 3)).to.be.revertedWith("Only admin can call this function.");
  });

  it("Should allow the admin to update a match", async function () {
    await betting.addMatch(1, 2, 3);
    await betting.updateMatch(1, 4, 5, true);
    const match = await betting.matches(1);
    expect(match.scoreTeamA).to.equal(4);
    expect(match.scoreTeamB).to.equal(5);
    expect(match.isFinished).to.be.true;
  });

  it("Should prevent non-admins from updating a match", async function () {
    await betting.addMatch(1, 2, 3);
    await expect(betting.connect(user1).updateMatch(1, 4, 5, true)).to.be.revertedWith("Only admin can call this function.");
  });

  it("Should allow the admin to delete a match", async function () {
    await betting.addMatch(1, 2, 3);
    await betting.deleteMatch(1);
    const match = await betting.matches(1);
    expect(match.matchId).to.equal(0); 
  });

  it("Should prevent non-admins from deleting a match", async function () {
    await betting.addMatch(1, 2, 3);
    await expect(betting.connect(user1).deleteMatch(1)).to.be.revertedWith("Only admin can call this function.");
  });

});
