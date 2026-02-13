import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { defineChain } from 'viem';

export const abstractTestnet = defineChain({
  id: 11124,
  name: 'Abstract Testnet',
  nativeCurrency: {
    name: 'Ether',
    symbol: 'ETH',
    decimals: 18,
  },
  rpcUrls: {
    default: {
      http: ['https://api.testnet.abs.xyz'],
    },
  },
  blockExplorers: {
    default: {
      name: 'Abstract Explorer',
      url: 'https://explorer.testnet.abs.xyz',
    },
  },
  testnet: true,
});

export const config = getDefaultConfig({
  appName: '.claw domains',
  projectId: 'claw-domains-mint', // WalletConnect project ID placeholder
  chains: [abstractTestnet],
  ssr: false,
});
