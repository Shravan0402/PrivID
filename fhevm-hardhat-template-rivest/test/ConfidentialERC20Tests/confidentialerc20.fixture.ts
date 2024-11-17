import { ethers } from "hardhat";

import type { PrivID } from "../../types";
import { getSigners } from "../signers";

export async function deployPrivIdFixture(): Promise<PrivID> {
  const signers = await getSigners();

  const contractFactory = await ethers.getContractFactory("PrivId");
  const contract = await contractFactory.connect(signers.alice).deploy();
  await contract.waitForDeployment();
  console.log("PrivId Contract Address is:", await contract.getAddress());

  return contract;
}
