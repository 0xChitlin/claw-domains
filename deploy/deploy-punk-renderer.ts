import { Deployer } from "@matterlabs/hardhat-zksync";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Wallet, Contract, Provider } from "zksync-ethers";
import * as fs from "fs";
import dotenv from "dotenv";

dotenv.config();

export default async function (hre: HardhatRuntimeEnvironment) {
  console.log("🎨 Deploying Punk-Style ClawRenderer to", hre.network.name, "...\n");

  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    throw new Error("PRIVATE_KEY not set in .env");
  }

  const REGISTRY_ADDRESS = process.env.REGISTRY_ADDRESS || "0xE230A7ED55a16DAA0A8CF3b703c4572b7E230aE6";

  const provider = new Provider("https://api.testnet.abs.xyz");
  const wallet = new Wallet(privateKey, provider);
  const deployer = new Deployer(hre, wallet);

  const balance = await provider.getBalance(wallet.address);
  console.log(`💰 Wallet balance: ${hre.ethers.formatEther(balance)} ETH\n`);

  // 1. Deploy new punk-style ClawRenderer
  console.log("🤖 Deploying Punk ClawRenderer...");
  const rendererArtifact = await deployer.loadArtifact("ClawRenderer");
  const renderer = await deployer.deploy(rendererArtifact, []);
  const rendererAddress = await renderer.getAddress();
  console.log(`   ✅ Punk ClawRenderer deployed to: ${rendererAddress}\n`);

  // 2. Update the ClawRegistry to point to new renderer
  console.log("🔗 Updating ClawRegistry renderer...");
  const registryArtifact = await deployer.loadArtifact("ClawRegistry");
  const registry = new Contract(REGISTRY_ADDRESS, registryArtifact.abi, wallet);
  
  try {
    const tx = await registry.setRenderer(rendererAddress);
    await tx.wait();
    console.log(`   ✅ Registry updated to use new renderer\n`);
  } catch (e: any) {
    console.log(`   ⚠️ Could not update registry (may not be owner): ${e.message}\n`);
  }

  // 3. Generate test SVGs for all 5 phases
  console.log("🎨 Generating test SVGs for all phases...\n");
  const testMinter = wallet.address;
  const testTokenId = 1;
  const testMintBlock = 12345;
  const testName = "punk";
  
  for (let phase = 0; phase <= 4; phase++) {
    try {
      const svg = await renderer.renderEvolvedSVG(
        testMinter,
        testTokenId,
        testMintBlock,
        testName,
        phase,
        phase * 10
      );
      const filename = `output-punk-phase${phase}.svg`;
      fs.writeFileSync(`./${filename}`, svg);
      console.log(`   ✅ Phase ${phase} SVG saved to ${filename}`);
    } catch (e: any) {
      console.log(`   ❌ Phase ${phase} SVG failed: ${e.message}`);
    }
  }

  // 4. Also generate a few different character variations
  console.log("\n🎭 Generating character variations...\n");
  for (let tokenId = 1; tokenId <= 5; tokenId++) {
    try {
      const svg = await renderer.renderEvolvedSVG(
        testMinter,
        tokenId,
        testMintBlock,
        `agent${tokenId}`,
        0,
        0
      );
      const filename = `output-punk-char${tokenId}.svg`;
      fs.writeFileSync(`./${filename}`, svg);
      console.log(`   ✅ Character ${tokenId} SVG saved to ${filename}`);
    } catch (e: any) {
      console.log(`   ❌ Character ${tokenId} SVG failed: ${e.message}`);
    }
  }

  // Save deployment info
  const deploymentInfo = {
    network: "abstract-testnet",
    chainId: 11124,
    deployer: wallet.address,
    timestamp: new Date().toISOString(),
    version: "v3-punk-renderer",
    contracts: {
      ClawRenderer: rendererAddress,
      ClawRegistry: REGISTRY_ADDRESS,
    },
    previousDeploy: {
      ClawRenderer: "0xE80c768bBB3171aE32351e569e13e2Ee05642B93",
    }
  };

  fs.writeFileSync("./deployment-punk.json", JSON.stringify(deploymentInfo, null, 2));

  const balanceAfter = await provider.getBalance(wallet.address);
  
  console.log("\n═══════════════════════════════════════");
  console.log("🤖 PUNK RENDERER — Deployment Complete");
  console.log("═══════════════════════════════════════");
  console.log(`  Punk ClawRenderer: ${rendererAddress}`);
  console.log(`  ClawRegistry:      ${REGISTRY_ADDRESS}`);
  console.log("═══════════════════════════════════════\n");
  console.log(`💰 Remaining balance: ${hre.ethers.formatEther(balanceAfter)} ETH`);
  console.log(`💸 Deploy cost: ${hre.ethers.formatEther(balance - balanceAfter)} ETH\n`);
}
