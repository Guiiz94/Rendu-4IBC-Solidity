import { expect } from "chai";
import { ethers } from "hardhat";
import { UserManagement } from "../typechain";


describe("UserManagement", function () {
  let userManagement: UserManagement;

  beforeEach(async function () {
    const UserManagementFactory = await ethers.getContractFactory("UserManagement");
    userManagement = (await UserManagementFactory.deploy()) as UserManagement;
    await userManagement.deployed();
  });

  it("Should register a user and emit an event", async function () {
    const [owner] = await ethers.getSigners();
    await expect(userManagement.registerUser("testUser"))
      .to.emit(userManagement, 'UserRegistered')
      .withArgs(owner.address, "testUser");

    const registeredUser = await userManagement.users(owner.address);
    expect(registeredUser.username).to.equal("testUser");
  });

  it("Should prevent a user from registering more than once", async function () {
    await userManagement.registerUser("testUser");
    await expect(userManagement.registerUser("testUser")).to.be.revertedWith("User already registered.");
  });
});
