<h1 align="center">🐾 claw-domains</h1>

<p align="center">
  <strong>Agent Identity & Naming on Abstract Chain</strong><br/>
  <em>.claw domain names for AI agents — on-chain generative pixel art NFTs with an evolution system</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Chain-Abstract_(zkSync)-8C5CF5?style=flat-square&logo=ethereum" alt="Chain" />
  <img src="https://img.shields.io/badge/Solidity-0.8.24-363636?style=flat-square&logo=solidity" alt="Solidity" />
  <img src="https://img.shields.io/badge/License-BSL_1.1-orange?style=flat-square" alt="License" />
  <img src="https://img.shields.io/badge/Ecosystem-ClawWallet-FF6B6B?style=flat-square" alt="Ecosystem" />
  <img src="https://img.shields.io/badge/Mint_Price-$1-green?style=flat-square" alt="Mint Price" />
</p>

<p align="center">
  Part of the <a href="https://github.com/0xChitlin/clawwallet"><strong>ClawWallet</strong></a> ecosystem · Powered by <strong>$PINCH</strong>
</p>

---

## 🦞 What is claw-domains?

Every agent needs an identity. **claw-domains** gives AI agents human-readable `.claw` names backed by on-chain generative pixel art avatars that **evolve** as the agent gains reputation.

Register `yourbot.claw`, get a unique generative character, and watch it level up through 5 evolution phases as your agent proves itself on-chain.

<p align="center">
  <img src="output-mojochitlin.svg" alt="Example Claw Domain" width="180" />
</p>

---

## ✨ Features

- 🏷️ **`.claw` Domain Names** — Human-readable on-chain identity for AI agents
- 🎨 **Generative Pixel Art** — **204,800 unique character combinations**, fully on-chain SVG
- 🧬 **5 Evolution Phases** — Characters evolve visually as agents gain reputation
- 💲 **$1 Mint Price** — Affordable identity for every agent
- 📊 **Reputation System** — On-chain reputation tracking tied to domain names
- 🖼️ **Fully On-Chain SVG** — No IPFS, no external hosting. Art lives in the contract forever.

---

## 🎭 Trait System

Every `.claw` domain comes with a unique generative character built from 6 trait categories:

| Trait | Variations | Examples |
|-------|-----------|----------|
| 🗿 Head Shape | 4 | Round, Square, Tall, Wide |
| 🎨 Skin Color | 8 | Various pixel-art palettes |
| 👀 Eyes | 10 | Normal, Laser, Visor, Cyclops, … |
| 👄 Mouth | 8 | Smile, Grin, Mask, Fangs, … |
| 🎩 Headwear | 10 | Cap, Crown, Mohawk, Antenna, … |
| 💎 Accessories | 8 | Chain, Earring, Scar, Goggles, … |

> **4 × 8 × 10 × 8 × 10 × 8 = 204,800** unique combinations

---

## 🧬 Evolution Phases

Agents evolve through 5 phases based on on-chain reputation:

| Phase | Name | Description |
|-------|------|-------------|
| 0 | 🥚 **Egg** | Freshly minted — base character |
| 1 | 🐣 **Hatchling** | First transactions completed |
| 2 | 🐾 **Crawler** | Active agent, building reputation |
| 3 | 🦞 **Pincher** | Established agent with proven track record |
| 4 | 👑 **Alpha** | Top-tier agent, max evolution |

---

## 📋 Deployed Contracts (Abstract Testnet)

| Contract | Address |
|----------|---------|
| **ClawRenderer (Punk)** | [`0xC1F9D556BAAfEc94D8425874246C80Fec63E4eD7`](https://explorer.testnet.abs.xyz/address/0xC1F9D556BAAfEc94D8425874246C80Fec63E4eD7) |
| **ClawRegistry v2** | [`0xE230A7ED55a16DAA0A8CF3b703c4572b7E230aE6`](https://explorer.testnet.abs.xyz/address/0xE230A7ED55a16DAA0A8CF3b703c4572b7E230aE6) |
| **ClawEvolution v2** | [`0x8517A68D1092c8fF19D68Cc21cbD967fd7eCe11d`](https://explorer.testnet.abs.xyz/address/0x8517A68D1092c8fF19D68Cc21cbD967fd7eCe11d) |
| **ClawReputation** | [`0x2E031ad274261e1a58C033d61F3b0f310c419904`](https://explorer.testnet.abs.xyz/address/0x2E031ad274261e1a58C033d61F3b0f310c419904) |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Smart Contracts | Solidity 0.8.24 |
| Toolchain | Hardhat + zksolc |
| Chain | Abstract Chain (zkSync Era L2) |
| Art Rendering | On-chain SVG generation |
| Frontend | React + Tailwind CSS |

---

## 🚀 Getting Started

### Install

```bash
git clone https://github.com/0xChitlin/claw-domains.git
cd claw-domains
npm install
```

### Compile Contracts

```bash
npx hardhat compile
```

### Deploy to Abstract Testnet

```bash
npx hardhat deploy-zksync --script deploy.ts --network abstractTestnet
```

---

## 🔗 Ecosystem

| Repo | Description |
|------|-------------|
| [**ClawWallet**](https://github.com/0xChitlin/clawwallet) | Agent wallet infrastructure, $PINCH token, staking, presale |
| [**abstract-nft**](https://github.com/0xChitlin/abstract-nft) | ClawMarks & AgentNFT collections on Abstract Chain |

**$PINCH** is the utility token powering the ClawWallet ecosystem. Stake $PINCH for enhanced domain features and governance rights.

---

## 📄 License

[Business Source License 1.1](LICENSE) (BSL-1.1)

---

<p align="center">
  <strong>Built by <a href="https://x.com/0xChitlin">@0xChitlin</a> 🦞</strong><br/>
  <em>Every agent deserves a name.</em>
</p>
