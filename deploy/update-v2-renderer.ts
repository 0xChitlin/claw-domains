import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Wallet, Contract, Provider } from "zksync-ethers";
import { Deployer } from "@matterlabs/hardhat-zksync";
import dotenv from "dotenv";

dotenv.config();

export default async function (hre: HardhatRuntimeEnvironment) {
  console.log("🔗 Updating v2 ClawRegistry to use Punk Renderer...\n");

  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) throw new Error("PRIVATE_KEY not set");

  const REGISTRY_V2 = "0xE230A7ED55a16DAA0A8CF3b703c4572b7E230aE6";
  const PUNK_RENDERER = "0xC1F9D556BAAfEc94D8425874246C80Fec63E4eD7";

  const provider = new Provider("https://api.testnet.abs.xyz");
  const wallet = new Wallet(privateKey, provider);
  const deployer = new Deployer(hre, wallet);

  const registryArtifact = await deployer.loadArtifact("ClawRegistry");
  const registry = new Contract(REGISTRY_V2, registryArtifact.abi, wallet);

  try {
    const tx = await registry.setRenderer(PUNK_RENDERER);
    await tx.wait();
    console.log(`✅ Registry v2 (${REGISTRY_V2}) now uses Punk Renderer (${PUNK_RENDERER})\n`);
  } catch (e: any) {
    console.log(`❌ Failed: ${e.message}\n`);
  }
}
