import { Deployer } from "@matterlabs/hardhat-zksync";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Wallet, Contract, Provider } from "zksync-ethers";
import * as fs from "fs";
import dotenv from "dotenv";

dotenv.config();

function decodeSVGFromURI(uri: string): string | null {
  if (uri.startsWith("data:application/json;base64,")) {
    const jsonBase64 = uri.replace("data:application/json;base64,", "");
    const jsonStr = Buffer.from(jsonBase64, "base64").toString("utf-8");
    const metadata = JSON.parse(jsonStr);
    if (metadata.image && metadata.image.startsWith("data:image/svg+xml;base64,")) {
      const svgBase64 = metadata.image.replace("data:image/svg+xml;base64,", "");
      return Buffer.from(svgBase64, "base64").toString("utf-8");
    }
  }
  return null;
}

export default async function (hre: HardhatRuntimeEnvironment) {
  console.log("🧬 ClawEvolution Mint & Test\n");

  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) throw new Error("PRIVATE_KEY not set in .env");

  // Load deployment addresses
  let deployInfo: any;
  try {
    deployInfo = JSON.parse(fs.readFileSync("./deployment-evolution.json", "utf-8"));
  } catch {
    throw new Error("deployment-evolution.json not found. Run deploy-evolution.ts first.");
  }

  const REGISTRY_ADDRESS = deployInfo.contracts.ClawRegistry;
  const EVOLUTION_ADDRESS = deployInfo.contracts.ClawEvolution;

  console.log(`Registry:  ${REGISTRY_ADDRESS}`);
  console.log(`Evolution: ${EVOLUTION_ADDRESS}\n`);

  const provider = new Provider("https://api.testnet.abs.xyz");
  const wallet = new Wallet(privateKey, provider);
  const deployer = new Deployer(hre, wallet);

  // Load artifacts
  const registryArtifact = await deployer.loadArtifact("ClawRegistry");
  const evolutionArtifact = await deployer.loadArtifact("ClawEvolution");

  const registry = new Contract(REGISTRY_ADDRESS, registryArtifact.abi, wallet);
  const evolution = new Contract(EVOLUTION_ADDRESS, evolutionArtifact.abi, wallet);

  // 1. Mint a new domain
  const testName = "evolver-" + Date.now().toString().slice(-6);
  console.log(`🐾 Minting "${testName}.claw"...`);
  const mintPrice = hre.ethers.parseEther("0.0005");
  const mintTx = await registry.mint(testName, { value: mintPrice });
  const mintReceipt = await mintTx.wait();
  console.log(`   ✅ Minted in tx: ${mintReceipt.hash}`);

  const tokenId = await registry.resolve(testName);
  console.log(`   Token ID: ${tokenId}\n`);

  // 2. Phase 0 — Genesis (0 activities)
  console.log("📸 Phase 0: Genesis (0 activities)");
  let phase = await evolution.getEvolutionPhase(tokenId);
  console.log(`   Phase: ${phase}`);
  let uri = await registry.tokenURI(tokenId);
  let svg = decodeSVGFromURI(uri);
  if (svg) {
    fs.writeFileSync("./output-phase0.svg", svg);
    console.log("   ✅ Saved output-phase0.svg\n");
  }

  // 3. Record 5 activities to reach Phase 1 (Awakening: 1-10)
  console.log("⚡ Recording 5 activities (→ Phase 1: Awakening)...");
  const tx3 = await evolution.recordActivities(tokenId, 0, 5); // TRANSFER type, 5 count
  await tx3.wait();
  phase = await evolution.getEvolutionPhase(tokenId);
  let total = await evolution.getTotalActivities(tokenId);
  console.log(`   Phase: ${phase}, Total: ${total}`);
  uri = await registry.tokenURI(tokenId);
  svg = decodeSVGFromURI(uri);
  if (svg) {
    fs.writeFileSync("./output-phase1.svg", svg);
    console.log("   ✅ Saved output-phase1.svg\n");
  }

  // 4. Record 46 more activities to reach Phase 2 (Growth: 11-50) — total = 51 → Phase 3
  // Actually let's go to phase 2 first (need total 11-50), then phase 3
  console.log("⚡ Recording 6 more activities (→ Phase 2: Growth, total=11)...");
  const tx4 = await evolution.recordActivities(tokenId, 1, 6); // SKILL_USE type
  await tx4.wait();
  phase = await evolution.getEvolutionPhase(tokenId);
  total = await evolution.getTotalActivities(tokenId);
  console.log(`   Phase: ${phase}, Total: ${total}`);
  uri = await registry.tokenURI(tokenId);
  svg = decodeSVGFromURI(uri);
  if (svg) {
    fs.writeFileSync("./output-phase2.svg", svg);
    console.log("   ✅ Saved output-phase2.svg\n");
  }

  // 5. Record 40 more activities to reach Phase 3 (Maturity: 51-200) — total = 51
  console.log("⚡ Recording 40 more activities (→ Phase 3: Maturity, total=51)...");
  const tx5 = await evolution.recordActivities(tokenId, 3, 40); // TRADE type
  await tx5.wait();
  phase = await evolution.getEvolutionPhase(tokenId);
  total = await evolution.getTotalActivities(tokenId);
  console.log(`   Phase: ${phase}, Total: ${total}`);
  uri = await registry.tokenURI(tokenId);
  svg = decodeSVGFromURI(uri);
  if (svg) {
    fs.writeFileSync("./output-phase3.svg", svg);
    console.log("   ✅ Saved output-phase3.svg\n");
  }

  // 6. Record 150 more to reach Phase 4 (Transcendence: 201+) — total = 201
  console.log("⚡ Recording 100 more activities (batch 1/2)...");
  const tx6a = await evolution.recordActivities(tokenId, 4, 100); // SOCIAL type
  await tx6a.wait();
  console.log("⚡ Recording 50 more activities (batch 2/2, → Phase 4: Transcendence, total=201)...");
  const tx6b = await evolution.recordActivities(tokenId, 5, 50); // GOVERNANCE type
  await tx6b.wait();
  phase = await evolution.getEvolutionPhase(tokenId);
  total = await evolution.getTotalActivities(tokenId);
  console.log(`   Phase: ${phase}, Total: ${total}`);
  uri = await registry.tokenURI(tokenId);
  svg = decodeSVGFromURI(uri);
  if (svg) {
    fs.writeFileSync("./output-phase4.svg", svg);
    console.log("   ✅ Saved output-phase4.svg\n");
  }

  // Summary
  console.log("═══════════════════════════════════════");
  console.log("🧬 EVOLUTION TEST COMPLETE");
  console.log("═══════════════════════════════════════");
  console.log(`  Domain: ${testName}.claw (Token #${tokenId})`);
  console.log(`  Final Phase: ${phase} (Transcendence)`);
  console.log(`  Total Activities: ${total}`);
  console.log("");
  console.log("  SVG files saved:");
  console.log("    output-phase0.svg — Genesis (seed crystal)");
  console.log("    output-phase1.svg — Awakening (glow effect)");
  console.log("    output-phase2.svg — Growth (extra shape layers)");
  console.log("    output-phase3.svg — Maturity (complex geometry)");
  console.log("    output-phase4.svg — Transcendence (animated!)");
  console.log("═══════════════════════════════════════");

  // Activity breakdown
  const data = await evolution.getActivityData(tokenId);
  console.log("\n📊 Activity Breakdown:");
  const types = ["TRANSFER", "SKILL_USE", "TOKEN_LAUNCH", "TRADE", "SOCIAL", "GOVERNANCE"];
  for (let i = 0; i < 6; i++) {
    console.log(`   ${types[i]}: ${data.activityByType[i]}`);
  }
  console.log(`   Streak: ${data.streak} days`);
}
