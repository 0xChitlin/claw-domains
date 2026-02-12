import { expect } from "chai";
import { Deployer } from "@matterlabs/hardhat-zksync";
import { Wallet, Contract } from "zksync-ethers";
import hre from "hardhat";

describe("ClawRenderer", function () {
  let renderer: Contract;
  let wallet: Wallet;
  let deployer: Deployer;

  // Test addresses for deterministic art generation
  const testWallets = [
    "0x1234567890abcdef1234567890abcdef12345678",
    "0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef",
    "0xabcdef0123456789abcdef0123456789abcdef01",
    "0x0000000000000000000000000000000000000001",
  ];

  before(async function () {
    wallet = new Wallet("0xac1e735be8536c6c3f5a83e3b8e1e9b3e3c5a7f9d1b3e5a7c9d1f3e5a7b9c1d3");
    deployer = new Deployer(hre, wallet);

    const rendererArtifact = await deployer.loadArtifact("ClawRenderer");
    renderer = await deployer.deploy(rendererArtifact, []);
  });

  describe("SVG Generation", function () {
    it("should generate a valid SVG string", async function () {
      const svg = await renderer.renderSVG(
        testWallets[0],
        1,
        1000000,
        "testdomain"
      );

      expect(svg).to.include("<svg");
      expect(svg).to.include("</svg>");
      expect(svg).to.include("xmlns");
      expect(svg).to.include("viewBox");
    });

    it("should include the domain name in the SVG", async function () {
      const svg = await renderer.renderSVG(
        testWallets[0],
        1,
        1000000,
        "mojochitlin"
      );

      expect(svg).to.include("mojochitlin.claw");
    });

    it("should include SVG filters for organic feel", async function () {
      const svg = await renderer.renderSVG(
        testWallets[0],
        1,
        1000000,
        "test"
      );

      expect(svg).to.include("feTurbulence");
      expect(svg).to.include("feGaussianBlur");
      expect(svg).to.include("feDisplacementMap");
    });

    it("should include gradient definitions", async function () {
      const svg = await renderer.renderSVG(
        testWallets[0],
        1,
        1000000,
        "test"
      );

      expect(svg).to.include("linearGradient");
      expect(svg).to.include("radialGradient");
      expect(svg).to.include("hsl(");
    });

    it("should produce different art for different wallets", async function () {
      const svg1 = await renderer.renderSVG(testWallets[0], 1, 1000000, "domain1");
      const svg2 = await renderer.renderSVG(testWallets[1], 2, 1000001, "domain2");

      // SVGs should be different (different wallet = different art)
      expect(svg1).to.not.equal(svg2);
    });

    it("should be deterministic (same input = same output)", async function () {
      const svg1 = await renderer.renderSVG(testWallets[0], 1, 1000000, "test");
      const svg2 = await renderer.renderSVG(testWallets[0], 1, 1000000, "test");

      expect(svg1).to.equal(svg2);
    });

    it("should generate valid SVGs for all test wallets", async function () {
      for (let i = 0; i < testWallets.length; i++) {
        const svg = await renderer.renderSVG(
          testWallets[i],
          i + 1,
          1000000 + i,
          `wallet${i}`
        );

        expect(svg).to.include("<svg");
        expect(svg).to.include("</svg>");
        expect(svg).to.include(`wallet${i}.claw`);
      }
    });
  });

  describe("Token URI Generation", function () {
    it("should return a valid base64 data URI", async function () {
      const uri = await renderer.renderTokenURI(
        testWallets[0],
        1,
        1000000,
        "mojochitlin",
        "An agent identity"
      );

      expect(uri).to.match(/^data:application\/json;base64,/);
    });

    it("should contain valid JSON with required fields", async function () {
      const uri = await renderer.renderTokenURI(
        testWallets[0],
        1,
        1000000,
        "testname",
        ""
      );

      const base64 = uri.replace("data:application/json;base64,", "");
      const json = Buffer.from(base64, "base64").toString("utf-8");
      const metadata = JSON.parse(json);

      expect(metadata).to.have.property("name", "testname.claw");
      expect(metadata).to.have.property("description");
      expect(metadata).to.have.property("image");
      expect(metadata).to.have.property("attributes");
      expect(metadata.attributes).to.be.an("array");
      expect(metadata.image).to.match(/^data:image\/svg\+xml;base64,/);
    });

    it("should include shape type as attribute", async function () {
      const uri = await renderer.renderTokenURI(
        testWallets[0],
        1,
        1000000,
        "test",
        ""
      );

      const base64 = uri.replace("data:application/json;base64,", "");
      const json = Buffer.from(base64, "base64").toString("utf-8");
      const metadata = JSON.parse(json);

      const shapeTrait = metadata.attributes.find(
        (a: any) => a.trait_type === "Shape"
      );
      expect(shapeTrait).to.exist;
      expect(["Hexagonal", "Spiral", "Crystalline", "Organic"]).to.include(
        shapeTrait.value
      );
    });

    it("should use custom description when provided", async function () {
      const uri = await renderer.renderTokenURI(
        testWallets[0],
        1,
        1000000,
        "test",
        "My custom description"
      );

      const base64 = uri.replace("data:application/json;base64,", "");
      const json = Buffer.from(base64, "base64").toString("utf-8");
      const metadata = JSON.parse(json);

      expect(metadata.description).to.equal("My custom description");
    });
  });
});
