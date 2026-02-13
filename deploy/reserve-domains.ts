import { Deployer } from "@matterlabs/hardhat-zksync";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Wallet, Contract, Provider } from "zksync-ethers";
import dotenv from "dotenv";
import * as fs from "fs";

dotenv.config();

const DOMAINS_TO_MINT = [
  "openclaw",
  "abstract",
  "clawpinch",
  "chitlin",
  "0xchitlin",
  "mikeebuilds",
  "agent",
  "wallet",
  "defi",
];

export default async function (hre: HardhatRuntimeEnvironment) {
  console.log("🐾 Reserving important .claw domain names...\n");

  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    throw new Error("PRIVATE_KEY not set in .env");
  }

  const REGISTRY_ADDRESS =
    process.env.REGISTRY_ADDRESS ||
    "0x01949e45FabCD684bcD4747966145140aB4778E5";

  const provider = new Provider("https://api.testnet.abs.xyz");
  const wallet = new Wallet(privateKey, provider);
  const deployer = new Deployer(hre, wallet);

  const balance = await provider.getBalance(wallet.address);
  console.log(`Wallet: ${wallet.address}`);
  console.log(`Balance: ${hre.ethers.formatEther(balance)} ETH\n`);

  const registryArtifact = await deployer.loadArtifact("ClawRegistry");
  const registry = new Contract(REGISTRY_ADDRESS, registryArtifact.abi, wallet);

  const mintPrice = hre.ethers.parseEther("0.0005");

  const results: {
    minted: { name: string; tokenId: string; txHash: string }[];
    failed: { name: string; error: string }[];
    skipped: { name: string; reason: string }[];
  } = {
    minted: [],
    failed: [],
    skipped: [],
  };

  for (const name of DOMAINS_TO_MINT) {
    try {
      // Check if already minted
      const exists = await registry.nameExists(name);
      if (exists) {
        const tokenId = await registry.resolve(name);
        console.log(`⏭️  "${name}.claw" already minted (token #${tokenId})`);
        results.skipped.push({
          name,
          reason: `already minted as token #${tokenId}`,
        });
        continue;
      }

      // Check balance before minting
      const currentBalance = await provider.getBalance(wallet.address);
      if (currentBalance < mintPrice + hre.ethers.parseEther("0.0002")) {
        console.log(`⚠️  Low balance, stopping. Remaining: ${hre.ethers.formatEther(currentBalance)} ETH`);
        results.failed.push({ name, error: "insufficient balance" });
        continue;
      }

      console.log(`🔄 Minting "${name}.claw"...`);
      const tx = await registry.mint(name, { value: mintPrice });
      const receipt = await tx.wait();

      const tokenId = await registry.resolve(name);
      console.log(
        `   ✅ Minted! Token #${tokenId} | tx: ${receipt!.hash}`
      );

      results.minted.push({
        name,
        tokenId: tokenId.toString(),
        txHash: receipt!.hash,
      });

      // Small delay between mints to avoid nonce issues
      await new Promise((r) => setTimeout(r, 1000));
    } catch (err: any) {
      const errorMsg = err.message?.substring(0, 200) || "unknown error";
      console.log(`   ❌ Failed to mint "${name}": ${errorMsg}`);
      results.failed.push({ name, error: errorMsg });
    }
  }

  // Final balance
  const finalBalance = await provider.getBalance(wallet.address);

  console.log("\n" + "=".repeat(50));
  console.log("DOMAIN RESERVATION RESULTS");
  console.log("=".repeat(50));
  console.log(`✅ Minted: ${results.minted.length}`);
  results.minted.forEach((d) =>
    console.log(`   ${d.name}.claw → Token #${d.tokenId}`)
  );
  console.log(`⏭️  Skipped: ${results.skipped.length}`);
  results.skipped.forEach((d) => console.log(`   ${d.name}.claw (${d.reason})`));
  console.log(`❌ Failed: ${results.failed.length}`);
  results.failed.forEach((d) => console.log(`   ${d.name}.claw: ${d.error}`));
  console.log(`\nFinal balance: ${hre.ethers.formatEther(finalBalance)} ETH`);

  // Save results
  const outputPath = "./reserved-domains.json";
  const output = {
    timestamp: new Date().toISOString(),
    network: "abstract-testnet",
    registry: REGISTRY_ADDRESS,
    wallet: wallet.address,
    mintPrice: "0.0005 ETH",
    finalBalance: hre.ethers.formatEther(finalBalance) + " ETH",
    results,
  };
  fs.writeFileSync(outputPath, JSON.stringify(output, null, 2));
  console.log(`\n📝 Results saved to ${outputPath}`);
}
