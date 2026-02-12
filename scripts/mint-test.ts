import { Deployer } from "@matterlabs/hardhat-zksync";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Wallet, Contract } from "zksync-ethers";
import dotenv from "dotenv";

dotenv.config();

export default async function (hre: HardhatRuntimeEnvironment) {
  console.log("🐾 Minting a test .claw domain...\n");

  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    throw new Error("PRIVATE_KEY not set in .env");
  }

  // Replace with your deployed contract addresses
  const REGISTRY_ADDRESS = process.env.REGISTRY_ADDRESS || "";
  if (!REGISTRY_ADDRESS) {
    throw new Error("Set REGISTRY_ADDRESS in .env to your deployed ClawRegistry address");
  }

  const wallet = new Wallet(privateKey);
  const deployer = new Deployer(hre, wallet);

  const registryArtifact = await deployer.loadArtifact("ClawRegistry");
  const registry = new Contract(REGISTRY_ADDRESS, registryArtifact.abi, wallet);

  // Mint a test domain
  const testName = "mojochitlin";
  console.log(`Minting "${testName}.claw"...`);

  const tx = await registry.mint(testName);
  const receipt = await tx.wait();
  console.log(`✅ Minted in tx: ${receipt.hash}\n`);

  // Get the token ID
  const tokenId = await registry.resolve(testName);
  console.log(`Token ID: ${tokenId}`);

  // Get the tokenURI (contains the SVG)
  const uri = await registry.tokenURI(tokenId);
  console.log(`\nToken URI (base64 JSON):`);
  console.log(uri.substring(0, 100) + "...\n");

  // Decode and display
  if (uri.startsWith("data:application/json;base64,")) {
    const jsonBase64 = uri.replace("data:application/json;base64,", "");
    const jsonStr = Buffer.from(jsonBase64, "base64").toString("utf-8");
    const metadata = JSON.parse(jsonStr);

    console.log("📋 Metadata:");
    console.log(`  Name: ${metadata.name}`);
    console.log(`  Description: ${metadata.description}`);
    console.log(`  Attributes:`, metadata.attributes);

    // Extract and save the SVG
    if (metadata.image && metadata.image.startsWith("data:image/svg+xml;base64,")) {
      const svgBase64 = metadata.image.replace("data:image/svg+xml;base64,", "");
      const svg = Buffer.from(svgBase64, "base64").toString("utf-8");

      const fs = require("fs");
      const outPath = `./output-${testName}.svg`;
      fs.writeFileSync(outPath, svg);
      console.log(`\n🎨 SVG art saved to: ${outPath}`);
      console.log("   Open in a browser to view your generative art!");
    }
  }
}
