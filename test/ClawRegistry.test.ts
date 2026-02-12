import { expect } from "chai";
import { Deployer } from "@matterlabs/hardhat-zksync";
import { Wallet, Contract } from "zksync-ethers";
import hre from "hardhat";

describe("ClawRegistry", function () {
  let registry: Contract;
  let renderer: Contract;
  let wallet: Wallet;
  let deployer: Deployer;

  before(async function () {
    // Use a deterministic test wallet
    wallet = new Wallet("0xac1e735be8536c6c3f5a83e3b8e1e9b3e3c5a7f9d1b3e5a7c9d1f3e5a7b9c1d3");
    deployer = new Deployer(hre, wallet);

    // Deploy renderer
    const rendererArtifact = await deployer.loadArtifact("ClawRenderer");
    renderer = await deployer.deploy(rendererArtifact, []);

    // Deploy registry
    const registryArtifact = await deployer.loadArtifact("ClawRegistry");
    registry = await deployer.deploy(registryArtifact, [await renderer.getAddress()]);
  });

  describe("Deployment", function () {
    it("should have correct name and symbol", async function () {
      expect(await registry.name()).to.equal("Claw Domains");
      expect(await registry.symbol()).to.equal("CLAW");
    });

    it("should start with 0 total supply", async function () {
      expect(await registry.totalSupply()).to.equal(0n);
    });

    it("should have renderer set", async function () {
      expect(await registry.renderer()).to.equal(await renderer.getAddress());
    });
  });

  describe("Minting", function () {
    it("should mint a valid domain name", async function () {
      const tx = await registry.mint("mojochitlin");
      await tx.wait();

      expect(await registry.totalSupply()).to.equal(1n);
      expect(await registry.tokenName(1)).to.equal("mojochitlin");
      expect(await registry.resolve("mojochitlin")).to.equal(1n);
    });

    it("should mint another domain", async function () {
      const tx = await registry.mint("testdomain");
      await tx.wait();

      expect(await registry.totalSupply()).to.equal(2n);
      expect(await registry.tokenName(2)).to.equal("testdomain");
    });

    it("should reject duplicate names", async function () {
      try {
        await registry.mint("mojochitlin");
        expect.fail("Should have reverted");
      } catch (e: any) {
        expect(e.message).to.include("NameAlreadyTaken");
      }
    });

    it("should reject names shorter than 3 chars", async function () {
      try {
        await registry.mint("ab");
        expect.fail("Should have reverted");
      } catch (e: any) {
        expect(e.message).to.include("NameTooShort");
      }
    });

    it("should reject names longer than 32 chars", async function () {
      try {
        await registry.mint("a]".repeat(17)); // 34 chars
        expect.fail("Should have reverted");
      } catch (e: any) {
        // Should revert with NameTooLong or InvalidCharacter
        expect(e.message).to.satisfy(
          (msg: string) => msg.includes("NameTooLong") || msg.includes("InvalidCharacter")
        );
      }
    });

    it("should reject uppercase letters", async function () {
      try {
        await registry.mint("UpperCase");
        expect.fail("Should have reverted");
      } catch (e: any) {
        expect(e.message).to.include("InvalidCharacter");
      }
    });

    it("should accept hyphens", async function () {
      const tx = await registry.mint("my-domain");
      await tx.wait();
      expect(await registry.nameExists("my-domain")).to.be.true;
    });

    it("should accept numeric names", async function () {
      const tx = await registry.mint("123");
      await tx.wait();
      expect(await registry.nameExists("123")).to.be.true;
    });
  });

  describe("View Functions", function () {
    it("should check availability", async function () {
      expect(await registry.isAvailable("mojochitlin")).to.be.false;
      expect(await registry.isAvailable("unclaimed")).to.be.true;
    });

    it("should return full name with .claw", async function () {
      expect(await registry.fullName(1)).to.equal("mojochitlin.claw");
    });

    it("should return 0 for unregistered names", async function () {
      expect(await registry.resolve("nonexistent")).to.equal(0n);
    });
  });

  describe("Token URI", function () {
    it("should return a base64-encoded data URI", async function () {
      const uri = await registry.tokenURI(1);
      expect(uri).to.match(/^data:application\/json;base64,/);
    });

    it("should contain valid JSON with name and image", async function () {
      const uri = await registry.tokenURI(1);
      const base64 = uri.replace("data:application/json;base64,", "");
      const json = Buffer.from(base64, "base64").toString("utf-8");
      const metadata = JSON.parse(json);

      expect(metadata.name).to.equal("mojochitlin.claw");
      expect(metadata.image).to.match(/^data:image\/svg\+xml;base64,/);
      expect(metadata.attributes).to.be.an("array");
    });
  });

  describe("Metadata", function () {
    it("should allow owner to set description", async function () {
      const tx = await registry.setDescription(1, "My agent identity");
      await tx.wait();
      expect(await registry.tokenDescription(1)).to.equal("My agent identity");
    });

    it("should allow owner to set website", async function () {
      const tx = await registry.setWebsite(1, "https://mojochitlin.claw");
      await tx.wait();
      expect(await registry.tokenWebsite(1)).to.equal("https://mojochitlin.claw");
    });

    it("should allow owner to set socials", async function () {
      const tx = await registry.setSocials(1, '{"twitter":"@mojochitlin"}');
      await tx.wait();
      expect(await registry.tokenSocials(1)).to.equal('{"twitter":"@mojochitlin"}');
    });
  });
});
