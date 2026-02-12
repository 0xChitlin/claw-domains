import { Deployer } from "@matterlabs/hardhat-zksync";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Wallet } from "zksync-ethers";
import dotenv from "dotenv";

dotenv.config();

export default async function (hre: HardhatRuntimeEnvironment) {
  console.log("🐾 Deploying Claw Domains to", hre.network.name, "...\n");

  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    throw new Error("PRIVATE_KEY not set in .env");
  }

  const wallet = new Wallet(privateKey);
  const deployer = new Deployer(hre, wallet);

  // 1. Deploy ClawRenderer (the art engine)
  console.log("📐 Deploying ClawRenderer...");
  const rendererArtifact = await deployer.loadArtifact("ClawRenderer");
  const renderer = await deployer.deploy(rendererArtifact, []);
  const rendererAddress = await renderer.getAddress();
  console.log(`   ✅ ClawRenderer deployed to: ${rendererAddress}\n`);

  // 2. Deploy ClawRegistry (the NFT + name registry)
  console.log("📋 Deploying ClawRegistry...");
  const registryArtifact = await deployer.loadArtifact("ClawRegistry");
  const registry = await deployer.deploy(registryArtifact, [rendererAddress]);
  const registryAddress = await registry.getAddress();
  console.log(`   ✅ ClawRegistry deployed to: ${registryAddress}\n`);

  // 3. Deploy ClawEvolution scaffold
  console.log("🧬 Deploying ClawEvolution (scaffold)...");
  const evolutionArtifact = await deployer.loadArtifact("ClawEvolution");
  const evolution = await deployer.deploy(evolutionArtifact, [registryAddress]);
  const evolutionAddress = await evolution.getAddress();
  console.log(`   ✅ ClawEvolution deployed to: ${evolutionAddress}\n`);

  // 4. Deploy ClawReputation scaffold
  console.log("⭐ Deploying ClawReputation (scaffold)...");
  const reputationArtifact = await deployer.loadArtifact("ClawReputation");
  const reputation = await deployer.deploy(reputationArtifact, [registryAddress]);
  const reputationAddress = await reputation.getAddress();
  console.log(`   ✅ ClawReputation deployed to: ${reputationAddress}\n`);

  console.log("═══════════════════════════════════════");
  console.log("🐾 CLAW DOMAINS — Deployment Complete");
  console.log("═══════════════════════════════════════");
  console.log(`  ClawRenderer:   ${rendererAddress}`);
  console.log(`  ClawRegistry:   ${registryAddress}`);
  console.log(`  ClawEvolution:  ${evolutionAddress}`);
  console.log(`  ClawReputation: ${reputationAddress}`);
  console.log("═══════════════════════════════════════\n");

  console.log("Next steps:");
  console.log("  1. Mint a test domain: npm run mint:test");
  console.log("  2. View your NFT on the Abstract explorer");
  console.log(`  3. Registry: https://explorer.testnet.abs.xyz/address/${registryAddress}`);
}
