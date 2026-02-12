# 🐾 Claw Domains

**Living, evolving on-chain generative art NFTs for agent identity on Abstract Chain.**

Every `.claw` domain is more than a name — it's a unique piece of generative art that lives entirely on-chain and evolves as your agent interacts with the world.

> `mojochitlin.claw` • `nova-7.claw` • `deepthought.claw`

---

## ✨ What is Claw Domains?

Claw Domains is an NFT-based agent identity system built on [Abstract Chain](https://abs.xyz) (ZK Stack L2). Each domain:

- **Is a unique name** — like DNS for autonomous agents (`yourname.claw`)
- **Has living generative art** — beautiful SVG art generated entirely on-chain from your wallet address
- **Evolves over time** — art changes as your agent's on-chain activity grows
- **Integrates with ERC-8004** — the emerging standard for agent identity and reputation

No IPFS. No external APIs. No off-chain images. Everything lives on the blockchain.

---

## 🎨 The Art System

### How Art Generation Works

Each `.claw` domain's art is deterministically generated from three on-chain inputs:

```
wallet address + token ID + mint block number → unique generative art
```

**From your wallet address, we derive:**

| Bytes | Parameter | Effect |
|-------|-----------|--------|
| 0-3 | Shape Type | Hexagonal, Spiral, Crystalline, or Organic base geometry |
| 4-7 | Geometry Params | Size, rotation, symmetry of core shapes |
| 8-14 | Color Palette | Harmonious 3-5 color HSL palette (analogous, triadic, split-complementary, or tetradic) |
| 15-19 | Detail Entropy | Pattern density, detail element placement |

**The art is built in 5 layers:**

1. **Background** — Rich gradient derived from mint block number
2. **Core Geometry** — The "seed crystal" — hexagons, spirals, crystals, or organic blobs
3. **Detail Patterns** — Small repeating elements (circles, diamonds, rings) scattered with address entropy
4. **Glow Layer** — Radial energy effects with depth
5. **Frame & Label** — Subtle border and the domain name

SVG filters (turbulence, blur, displacement) add an organic, non-digital feel.

### What the Art Looks Like

- **Hexagonal domains** → Nested rotating hexagons with crystalline inner glow, like looking into a kaleidoscope
- **Spiral domains** → Golden-angle spirals of softly glowing orbs, like a galaxy forming
- **Crystalline domains** → Angular faceted shapes radiating from center, like a gemstone cross-section
- **Organic domains** → Flowing blurred ellipses with turbulence distortion, like bioluminescent creatures

Every wallet produces a unique combination. Same wallet always produces the same art.

---

## 🧬 The 4-Phase Evolution System

### Phase 1: Genesis (✅ Built)
The base generative art — unique to each wallet, beautiful from day one.

### Phase 2: Evolution (🔧 Scaffolded)
Art evolves based on your agent's on-chain activity:
- **Transfers** → Increases energy glow intensity
- **Contract interactions** → Adds complexity layers
- **DeFi activity** → Adds orbital ring elements
- **NFT activity** → Adds sparkle particle effects
- **Governance** → Adds crown/halo elements

Six evolution stages: Genesis → Awakening → Growth → Maturity → Transcendence → Legendary

### Phase 3: Reputation Aura (🔧 Scaffolded)
Integration with ERC-8004 agent identity standard:
- Reputation score adds visual "aura" effects
- Six aura tiers: None → Ember → Flame → Radiant → Stellar → Transcendent
- Verified agents get a special badge effect
- Top 1% reputation unlocks legendary particle effects

### Phase 4: Social Graph (🗺️ Planned)
Future: Visual connections between agents, collaborative art effects.

---

## 🏗️ Architecture

```
contracts/
├── ClawRegistry.sol         # ERC-721 + name registry (mint, resolve, metadata)
├── ClawRenderer.sol         # On-chain SVG art generator (the creative engine)
├── ClawEvolution.sol        # Activity-based art evolution (Phase 2 scaffold)
├── ClawReputation.sol       # ERC-8004 reputation integration (Phase 3 scaffold)
└── libraries/
    ├── SVGLib.sol            # SVG string building utilities
    ├── ColorLib.sol          # HSL color palette generation from bytes
    └── MathLib.sol           # Fixed-point trig for SVG coordinates
```

### Key Design Decisions

- **Split rendering** — Renderer is a separate contract so it can be upgraded without migrating NFTs
- **Library pattern** — Math, color, and SVG logic in libraries to keep contract sizes manageable
- **Deterministic** — Same inputs always produce identical output. No randomness, no oracles needed for base art.
- **HSL color space** — Generates naturally harmonious palettes (analogous, triadic, split-comp, tetradic)
- **SVG filters** — `feTurbulence` + `feDisplacementMap` for organic, non-digital aesthetics

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- A wallet with Abstract testnet ETH ([faucet](https://faucet.abs.xyz))

### Install
```bash
git clone https://github.com/0xChitlin/claw-domains.git
cd claw-domains
npm install
```

### Configure
```bash
cp .env.example .env
# Edit .env and add your private key (testnet only!)
```

### Compile
```bash
npm run compile
```

### Deploy to Abstract Testnet
```bash
npm run deploy:testnet
```

### Mint a Test Domain
```bash
# Set REGISTRY_ADDRESS in .env to your deployed address
npm run mint:test
```

This will mint "mojochitlin.claw" and save the generated SVG to `output-mojochitlin.svg`.

---

## 📋 Contract Interface

### ClawRegistry

```solidity
// Mint a domain
function mint(string name) → uint256 tokenId

// Resolve a name
function resolve(string name) → uint256 tokenId

// Check availability
function isAvailable(string name) → bool

// Get on-chain metadata + SVG art
function tokenURI(uint256 tokenId) → string dataURI

// Set metadata (owner only)
function setDescription(uint256 tokenId, string description)
function setWebsite(uint256 tokenId, string website)
function setSocials(uint256 tokenId, string socials)
```

### Name Rules
- 3-32 characters
- Lowercase letters (a-z), digits (0-9), hyphens (-)
- Must be unique
- First come, first served

---

## 🛠️ Tech Stack

- **Blockchain**: Abstract Chain (ZK Stack L2)
- **Language**: Solidity 0.8.24
- **Framework**: Hardhat + @matterlabs/hardhat-zksync
- **Standards**: ERC-721 (OpenZeppelin v5), ERC-8004 (planned)
- **Art**: Pure on-chain SVG (no IPFS, no external dependencies)
- **Color System**: HSL-based harmonious palette generation
- **Math**: Fixed-point trigonometry library for SVG coordinate calculation

---

## 🗺️ Roadmap

- [x] **v0.1** — Genesis art: on-chain SVG renderer with 4 shape types
- [x] **v0.1** — Name registry with ERC-721
- [ ] **v0.2** — Evolution system: activity-based art changes
- [ ] **v0.3** — ERC-8004 reputation aura integration
- [ ] **v0.4** — Abstract mainnet deployment
- [ ] **v0.5** — Frontend: mint page + gallery
- [ ] **v1.0** — Social graph visualization

---

## 📜 License

MIT

---

<p align="center">
  <em>Every agent deserves an identity. Every identity deserves beautiful art.</em><br/>
  <strong>🐾 Claw Domains</strong>
</p>
