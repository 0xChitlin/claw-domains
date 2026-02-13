import { Deployer } from "@matterlabs/hardhat-zksync";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Wallet, Contract, Provider } from "zksync-ethers";
import * as fs from "fs";
import dotenv from "dotenv";

dotenv.config();

export default async function (hre: HardhatRuntimeEnvironment) {
  console.log("🧬 Deploying ClawEvolution system to", hre.network.name, "...\n");

  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    throw new Error("PRIVATE_KEY not set in .env");
  }

  const REGISTRY_ADDRESS = process.env.REGISTRY_ADDRESS || "0x01949e45FabCD684bcD4747966145140aB4778E5";

  const provider = new Provider("https://api.testnet.abs.xyz");
  const wallet = new Wallet(privateKey, provider);
  const deployer = new Deployer(hre, wallet);

  const balance = await provider.getBalance(wallet.address);
  console.log(`💰 Wallet balance: ${hre.ethers.formatEther(balance)} ETH\n`);

  // 1. Deploy new ClawRenderer (with evolution support)
  console.log("📐 Deploying ClawRenderer v2 (evolution-aware)...");
  const rendererArtifact = await deployer.loadArtifact("ClawRenderer");
  const renderer = await deployer.deploy(rendererArtifact, []);
  const rendererAddress = await renderer.getAddress();
  console.log(`   ✅ ClawRenderer v2 deployed to: ${rendererAddress}\n`);

  // 2. Deploy new ClawEvolution (full implementation)
  console.log("🧬 Deploying ClawEvolution v2 (full implementation)...");
  const evolutionArtifact = await deployer.loadArtifact("ClawEvolution");
  const evolution = await deployer.deploy(evolutionArtifact, []);
  const evolutionAddress = await evolution.getAddress();
  console.log(`   ✅ ClawEvolution v2 deployed to: ${evolutionAddress}\n`);

  // 3. Deploy new ClawRegistry (with evolution integration)
  console.log("📋 Deploying ClawRegistry v2 (evolution-integrated)...");
  const mintPrice = "500000000000000"; // 0.0005 ETH
  const treasury = wallet.address;
  const registryArtifact = await deployer.loadArtifact("ClawRegistry");
  const registry = await deployer.deploy(registryArtifact, [rendererAddress, mintPrice, treasury]);
  const registryAddress = await registry.getAddress();
  console.log(`   ✅ ClawRegistry v2 deployed to: ${registryAddress}\n`);

  // 4. Wire up: set evolution on registry
  console.log("🔗 Wiring up contracts...");
  const registryContract = new Contract(registryAddress, registryArtifact.abi, wallet);
  const tx1 = await registryContract.setEvolution(evolutionAddress);
  await tx1.wait();
  console.log(`   ✅ Registry -> Evolution set\n`);

  // 5. Add deployer wallet as approved recorder on evolution
  const evolutionContract = new Contract(evolutionAddress, evolutionArtifact.abi, wallet);
  const tx2 = await evolutionContract.addApprovedRecorder(wallet.address);
  await tx2.wait();
  console.log(`   ✅ Deployer added as approved recorder on Evolution\n`);

  // Save deployment info
  const deploymentInfo = {
    network: "abstract-testnet",
    chainId: 11124,
    deployer: wallet.address,
    timestamp: new Date().toISOString(),
    version: "v2-evolution",
    contracts: {
      ClawRenderer: rendererAddress,
      ClawRegistry: registryAddress,
      ClawEvolution: evolutionAddress,
    },
    previousDeploy: {
      ClawRenderer: "0x90f493bfB740F00E6Cf280f4B9A6943d4b96d274",
      ClawRegistry: REGISTRY_ADDRESS,
      ClawEvolution: "0xed61D90c46343D0399de04a2CDEd195A217aa583",
    }
  };

  fs.writeFileSync("./deployment-evolution.json", JSON.stringify(deploymentInfo, null, 2));

  console.log("═══════════════════════════════════════");
  console.log("🧬 CLAW EVOLUTION — Deployment Complete");
  console.log("═══════════════════════════════════════");
  console.log(`  ClawRenderer v2:  ${rendererAddress}`);
  console.log(`  ClawRegistry v2:  ${registryAddress}`);
  console.log(`  ClawEvolution v2: ${evolutionAddress}`);
  console.log("═══════════════════════════════════════\n");

  const balanceAfter = await provider.getBalance(wallet.address);
  console.log(`💰 Remaining balance: ${hre.ethers.formatEther(balanceAfter)} ETH`);
  console.log(`💸 Deploy cost: ${hre.ethers.formatEther(balance - balanceAfter)} ETH\n`);

  console.log("Next: run `npx hardhat deploy-zksync --script mint-evolution-test.ts` to test evolution");
}
