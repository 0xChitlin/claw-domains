import { HardhatUserConfig } from "hardhat/config";
import "@matterlabs/hardhat-zksync";
import dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  defaultNetwork: "abstractTestnet",
  networks: {
    abstractTestnet: {
      url: "https://api.testnet.abs.xyz",
      ethNetwork: "sepolia",
      zksync: true,
      verifyURL: "https://api-explorer-verify.testnet.abs.xyz/contract_verification",
    },
    abstractMainnet: {
      url: "https://api.mainnet.abs.xyz",
      ethNetwork: "mainnet",
      zksync: true,
      verifyURL: "https://api-explorer-verify.mainnet.abs.xyz/contract_verification",
    },
    hardhat: {
      zksync: true,
    },
    inMemoryNode: {
      url: "http://127.0.0.1:8011",
      ethNetwork: "localhost",
      zksync: true,
    },
  },
  zksolc: {
    version: "1.5.10",
    settings: {
      // Enable optimization for contract size
      optimizer: {
        enabled: true,
        mode: "z", // Optimize for size
      },
    },
  },
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      evmVersion: "paris",
    },
  },
};

export default config;
