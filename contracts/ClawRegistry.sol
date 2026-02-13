// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ClawRenderer.sol";
import "./ClawEvolution.sol";

/// @title ClawRegistry - ERC-721 .claw domain name registry with on-chain generative art
/// @notice Mint unique .claw domain names with living, evolving on-chain SVG art
/// @dev Each domain is an NFT whose art is deterministically generated from the minter's wallet
contract ClawRegistry is ERC721, Ownable {
    using Strings for uint256;

    // ============================================================
    //                          STORAGE
    // ============================================================

    /// @notice The on-chain SVG renderer contract
    ClawRenderer public renderer;

    /// @notice The evolution tracking contract
    ClawEvolution public evolution;

    /// @notice Next token ID to mint
    uint256 private _nextTokenId;

    /// @notice Mapping from token ID to domain name
    mapping(uint256 => string) public tokenName;

    /// @notice Mapping from domain name (lowercase) to token ID
    mapping(string => uint256) public nameToTokenId;

    /// @notice Whether a name has been registered
    mapping(string => bool) public nameExists;

    /// @notice Mint block for each token (used in art generation)
    mapping(uint256 => uint256) public mintBlock;

    /// @notice Original minter address (used in art generation)
    mapping(uint256 => address) public minterAddress;

    /// @notice Optional metadata: description
    mapping(uint256 => string) public tokenDescription;

    /// @notice Optional metadata: website URL
    mapping(uint256 => string) public tokenWebsite;

    /// @notice Optional metadata: social links (JSON string)
    mapping(uint256 => string) public tokenSocials;

    /// @notice Mint price in wei (default ~$1 at launch)
    uint256 public mintPrice;

    /// @notice Treasury address for mint proceeds
    address public treasury;

    // ============================================================
    //                          EVENTS
    // ============================================================

    event DomainMinted(uint256 indexed tokenId, string name, address indexed minter);
    event MetadataUpdated(uint256 indexed tokenId);
    event RendererUpdated(address indexed newRenderer);
    event EvolutionUpdated(address indexed newEvolution);
    event MintPriceUpdated(uint256 newPrice);
    event TreasuryUpdated(address newTreasury);

    // ============================================================
    //                          ERRORS
    // ============================================================

    error NameTooShort();
    error NameTooLong();
    error NameAlreadyTaken();
    error InvalidCharacter();
    error NotTokenOwner();
    error RendererNotSet();
    error InsufficientPayment();
    error WithdrawFailed();

    // ============================================================
    //                       CONSTRUCTOR
    // ============================================================

    constructor(address _renderer, uint256 _mintPrice, address _treasury) ERC721("Claw Domains", "CLAW") Ownable(msg.sender) {
        renderer = ClawRenderer(_renderer);
        mintPrice = _mintPrice;
        treasury = _treasury;
        _nextTokenId = 1; // Start at 1, 0 means "not found"
    }

    // ============================================================
    //                      MINT FUNCTION
    // ============================================================

    /// @notice Mint a new .claw domain
    /// @param name The domain name (without .claw suffix). Must be lowercase alphanumeric, 3-32 chars.
    function mint(string calldata name) external payable returns (uint256) {
        if (msg.value < mintPrice) revert InsufficientPayment();
        _validateName(name);

        if (nameExists[name]) revert NameAlreadyTaken();

        uint256 tokenId = _nextTokenId++;

        // Store domain data
        tokenName[tokenId] = name;
        nameToTokenId[name] = tokenId;
        nameExists[name] = true;
        mintBlock[tokenId] = block.number;
        minterAddress[tokenId] = msg.sender;

        // Mint the NFT
        _safeMint(msg.sender, tokenId);

        emit DomainMinted(tokenId, name, msg.sender);

        return tokenId;
    }

    // ============================================================
    //                      TOKEN URI
    // ============================================================

    /// @notice Returns on-chain JSON metadata with embedded SVG art
    /// @dev If evolution contract is set, queries it for phase and activity count
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        if (address(renderer) == address(0)) revert RendererNotSet();

        // If evolution contract is set, use evolution-aware rendering
        if (address(evolution) != address(0)) {
            uint256 phase = evolution.getEvolutionPhase(tokenId);
            uint256 activityCount = evolution.getTotalActivities(tokenId);

            return renderer.renderEvolvedTokenURI(
                minterAddress[tokenId],
                tokenId,
                mintBlock[tokenId],
                tokenName[tokenId],
                tokenDescription[tokenId],
                phase,
                activityCount
            );
        }

        // Fallback: base rendering (phase 0)
        return renderer.renderTokenURI(
            minterAddress[tokenId],
            tokenId,
            mintBlock[tokenId],
            tokenName[tokenId],
            tokenDescription[tokenId]
        );
    }

    // ============================================================
    //                   METADATA SETTERS
    // ============================================================

    /// @notice Set description for your domain
    function setDescription(uint256 tokenId, string calldata description) external {
        if (ownerOf(tokenId) != msg.sender) revert NotTokenOwner();
        tokenDescription[tokenId] = description;
        emit MetadataUpdated(tokenId);
    }

    /// @notice Set website URL for your domain
    function setWebsite(uint256 tokenId, string calldata website) external {
        if (ownerOf(tokenId) != msg.sender) revert NotTokenOwner();
        tokenWebsite[tokenId] = website;
        emit MetadataUpdated(tokenId);
    }

    /// @notice Set social links (JSON string) for your domain
    function setSocials(uint256 tokenId, string calldata socials) external {
        if (ownerOf(tokenId) != msg.sender) revert NotTokenOwner();
        tokenSocials[tokenId] = socials;
        emit MetadataUpdated(tokenId);
    }

    // ============================================================
    //                      ADMIN FUNCTIONS
    // ============================================================

    /// @notice Update the renderer contract
    function setRenderer(address _renderer) external onlyOwner {
        renderer = ClawRenderer(_renderer);
        emit RendererUpdated(_renderer);
    }

    /// @notice Set the evolution contract
    function setEvolution(address _evolution) external onlyOwner {
        evolution = ClawEvolution(_evolution);
        emit EvolutionUpdated(_evolution);
    }

    /// @notice Update the mint price
    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
        emit MintPriceUpdated(_mintPrice);
    }

    /// @notice Update the treasury address
    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
        emit TreasuryUpdated(_treasury);
    }

    /// @notice Withdraw all mint proceeds to treasury
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = treasury.call{value: balance}("");
        if (!success) revert WithdrawFailed();
    }

    // ============================================================
    //                       VIEW FUNCTIONS
    // ============================================================

    /// @notice Resolve a name to its token ID (0 = not found)
    function resolve(string calldata name) external view returns (uint256) {
        return nameToTokenId[name];
    }

    /// @notice Get the total supply of minted domains
    function totalSupply() external view returns (uint256) {
        return _nextTokenId - 1;
    }

    /// @notice Check if a name is available
    function isAvailable(string calldata name) external view returns (bool) {
        return !nameExists[name];
    }

    /// @notice Get the full domain name for a token (with .claw suffix)
    function fullName(uint256 tokenId) external view returns (string memory) {
        _requireOwned(tokenId);
        return string(abi.encodePacked(tokenName[tokenId], ".claw"));
    }

    // ============================================================
    //                       INTERNAL
    // ============================================================

    /// @dev Validate a domain name: lowercase alphanumeric + hyphens, 3-32 chars
    function _validateName(string calldata name) internal pure {
        bytes memory nameBytes = bytes(name);

        if (nameBytes.length < 3) revert NameTooShort();
        if (nameBytes.length > 32) revert NameTooLong();

        for (uint256 i = 0; i < nameBytes.length; i++) {
            bytes1 char = nameBytes[i];
            bool isLower = (char >= 0x61 && char <= 0x7A);
            bool isDigit = (char >= 0x30 && char <= 0x39);
            bool isHyphen = (char == 0x2D);

            if (!isLower && !isDigit && !isHyphen) revert InvalidCharacter();
        }
    }
}
