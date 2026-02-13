# Claw Domains — Minting Frontend

A minimal, premium minting page for .claw on-chain domain names on Abstract Testnet.

## Features

- **Name Checker** — real-time availability checking against the contract
- **Wallet Connect** — MetaMask, WalletConnect, Coinbase Wallet via RainbowKit
- **One-Click Mint** — pay 0.0005 ETH, get your .claw domain NFT
- **On-Chain Gallery** — view the generative SVG art decoded directly from tokenURI()
- **Stats Bar** — live total supply, mint price, network status
- **Responsive** — works on mobile and desktop

## Tech Stack

- Vite + React + TypeScript
- wagmi v2 + viem for contract interaction
- RainbowKit for wallet connection
- Tailwind CSS for styling

## Setup

```bash
cd frontend
npm install
npm run dev
```

App runs at `http://localhost:3000`.

## Contract

- **ClawRegistry:** `0x01949e45FabCD684bcD4747966145140aB4778E5`
- **Network:** Abstract Testnet (Chain ID 11124)
- **RPC:** `https://api.testnet.abs.xyz`
- **Explorer:** `https://explorer.testnet.abs.xyz`

## WalletConnect Project ID

For production, get a project ID from [cloud.walletconnect.com](https://cloud.walletconnect.com) and update `src/config/wagmi.ts`.

## Build

```bash
npm run build
```

Output goes to `dist/` — deploy to Vercel, Netlify, or any static host.
