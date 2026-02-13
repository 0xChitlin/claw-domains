import { Deployer } from "@matterlabs/hardhat-zksync";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Wallet, Provider, Contract } from "zksync-ethers";
import dotenv from "dotenv";

dotenv.config();

export default async function (hre: HardhatRuntimeEnvironment) {
  console.log("🐾 Minting a test .claw domain...\n");

  const privateKey = process.env.PRIVATE_KEY!;
  const REGISTRY_ADDRESS = process.env.REGISTRY_ADDRESS!;

  const provider = new Provider("https://api.testnet.abs.xyz");
  const wallet = new Wallet(privateKey, provider);
  const deployer = new Deployer(hre, wallet);

  const registryArtifact = await deployer.loadArtifact("ClawRegistry");
  const registry = new Contract(REGISTRY_ADDRESS, registryArtifact.abi, wallet);

  const testName = "mojochitlin";
  console.log(`Minting "${testName}.claw"...`);

  const tx = await registry.mint(testName);
  const receipt = await tx.wait();
  console.log(`✅ Minted in tx: ${receipt.hash}\n`);

  const tokenId = await registry.resolve(testName);
  console.log(`Token ID: ${tokenId}`);

  const uri = await registry.tokenURI(tokenId);
  console.log(`\nToken URI (base64 JSON):`);
  console.log(uri.substring(0, 100) + "...\n");

  if (uri.startsWith("data:application/json;base64,")) {
    const jsonBase64 = uri.replace("data:application/json;base64,", "");
    const jsonStr = Buffer.from(jsonBase64, "base64").toString("utf-8");
    const metadata = JSON.parse(jsonStr);

    console.log("📋 Metadata:");
    console.log(`  Name: ${metadata.name}`);
    console.log(`  Description: ${metadata.description}`);
    console.log(`  Attributes:`, metadata.attributes);

    if (metadata.image && metadata.image.startsWith("data:image/svg+xml;base64,")) {
      const svgBase64 = metadata.image.replace("data:image/svg+xml;base64,", "");
      const svg = Buffer.from(svgBase64, "base64").toString("utf-8");
      const fs = require("fs");
      fs.writeFileSync(`./output-${testName}.svg`, svg);
      console.log(`\n🎨 SVG art saved to: ./output-${testName}.svg`);
    }
  }
}
