import fs from "fs";
import { preverifyEmail } from "@vlayer/sdk";
import { createVlayerClient } from "@vlayer/sdk";
import {
  getConfig,
  createContext,
  waitForContractDeploy,
} from "@vlayer/sdk/config";

import emailSpec from "../out/SimpleEmailProver.sol/IDProver"

const config = getConfig();
const {
  chain,
  ethClient,
  account: john,
  proverUrl,
  confirmations,
} = await createContext(config);


const emailDeployTransactionHash = await ethClient.deployContract({
  abi: emailSpec.abi,
  bytecode: emailSpec.bytecode.object,
  account: john,
  args: [],
})

const emailContractAddress = await waitForContractDeploy({
  hash: emailDeployTransactionHash
})


console.log("Proving...");
const vlayer = createVlayerClient({
  url: proverUrl,
});

const email = fs.readFileSync("PrivId.eml").toString();
const unverifiedEmail = await preverifyEmail(email);
const emailHash = await vlayer.prove({
  address: emailContractAddress,
  proverAbi: emailSpec.abi,
  functionName: "main",
  args: [unverifiedEmail],
  chainId: chain.id,
});
const emailResult = await vlayer.waitForProvingResult(emailHash);
const [emailProof, emailBody] = emailResult;

const regex = /&[0-9A-Za-z]*&/g;
const match = emailBody.match(regex)
console.log(match)

const name = match[1].slice(1, -1)


function stringToUint8Array(input: string): Uint8Array {
  const encoder = new TextEncoder();
  return encoder.encode(input);
}

console.log(stringToUint8Array(name))