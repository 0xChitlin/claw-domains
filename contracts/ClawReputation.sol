// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ClawRegistry.sol";

/// @notice Interface for ERC-8004 Agent Identity standard
/// @dev TODO: Update when ERC-8004 is finalized
interface IERC8004 {
    /// @notice Get the reputation score for an agent
    /// @param agent The agent's address
    /// @return score Reputation score (0-10000, basis points)
    function reputationScore(address agent) external view returns (uint256 score);

    /// @notice Get reputation breakdown by category
    /// @param agent The agent's address
    /// @return reliability Score for task completion reliability
    /// @return accuracy Score for output accuracy
    /// @return safety Score for safety compliance
    /// @return responsiveness Score for response time
    function reputationBreakdown(address agent) external view returns (
        uint256 reliability,
        uint256 accuracy,
        uint256 safety,
        uint256 responsiveness
    );

    /// @notice Check if an agent is verified
    /// @param agent The agent's address
    /// @return Whether the agent has been verified
    function isVerified(address agent) external view returns (bool);
}

/// @title ClawReputation - ERC-8004 Agent Identity integration for .claw domains (Phase 3 Scaffold)
/// @notice Hooks for reading reputation scores and rendering auras based on agent reputation
/// @dev SCAFFOLD — interfaces defined, implementation TODO
contract ClawReputation {

    // ============================================================
    //                     DATA STRUCTURES
    // ============================================================

    /// @notice Reputation visual parameters for art rendering
    struct ReputationAura {
        uint8 auraIntensity;    // 0-255: brightness of aura glow
        uint8 auraColor;        // Hue shift for reputation-based coloring
        uint8 auraRings;        // Number of concentric aura rings (0-5)
        bool verified;          // Whether agent shows verified badge
        bool legendary;         // Top 1% reputation — special effects
        uint256 cachedScore;    // Last known reputation score
        uint256 lastUpdated;    // Block of last update
    }

    /// @notice Aura tiers based on reputation score
    enum AuraTier {
        NONE,       // 0-999:    No aura
        EMBER,      // 1000-2999: Subtle warm glow
        FLAME,      // 3000-4999: Visible orange aura
        RADIANT,    // 5000-6999: Bright golden aura
        STELLAR,    // 7000-8999: Multi-ring cosmic aura
        TRANSCENDENT // 9000-10000: Full legendary aura with particles
    }

    // ============================================================
    //                          STORAGE
    // ============================================================

    /// @notice Reference to the ClawRegistry
    ClawRegistry public registry;

    /// @notice Reference to the ERC-8004 reputation contract
    /// @dev TODO: Set when ERC-8004 contract is deployed on Abstract
    address public erc8004Contract;

    /// @notice Cached reputation aura per token
    mapping(uint256 => ReputationAura) public auras;

    // ============================================================
    //                          EVENTS
    // ============================================================

    event ReputationUpdated(uint256 indexed tokenId, uint256 newScore, AuraTier tier);
    event ERC8004ContractUpdated(address indexed newContract);

    // ============================================================
    //                       CONSTRUCTOR
    // ============================================================

    constructor(address _registry) {
        registry = ClawRegistry(_registry);
    }

    // ============================================================
    //                  REPUTATION FUNCTIONS
    // ============================================================

    /// @notice Update the reputation aura for a token
    /// @param tokenId The token to update
    /// @dev TODO: Implement when ERC-8004 is available on Abstract
    function updateReputation(uint256 tokenId) external {
        // TODO: Phase 3 Implementation
        // 1. Get minter address from registry
        // 2. Query ERC-8004 contract for reputation score
        // 3. Calculate aura tier and visual params
        // 4. Cache results
        // 5. Emit event

        revert("ClawReputation: not yet implemented");
    }

    /// @notice Get the aura rendering parameters for a token
    /// @dev Used by ClawRenderer to add reputation-based visual elements
    function getAura(uint256 tokenId) external view returns (ReputationAura memory) {
        return auras[tokenId];
    }

    /// @notice Get the aura tier for a reputation score
    function getAuraTier(uint256 score) public pure returns (AuraTier) {
        if (score < 1000) return AuraTier.NONE;
        if (score < 3000) return AuraTier.EMBER;
        if (score < 5000) return AuraTier.FLAME;
        if (score < 7000) return AuraTier.RADIANT;
        if (score < 9000) return AuraTier.STELLAR;
        return AuraTier.TRANSCENDENT;
    }

    // ============================================================
    //                   ADMIN FUNCTIONS
    // ============================================================

    /// @notice Set the ERC-8004 contract address
    /// @dev TODO: Add access control
    function setERC8004Contract(address _contract) external {
        // TODO: Add onlyOwner or similar access control
        erc8004Contract = _contract;
        emit ERC8004ContractUpdated(_contract);
    }

    // ============================================================
    //                   INTERNAL HELPERS (TODO)
    // ============================================================

    /// @dev Calculate aura visual parameters from reputation score
    /// TODO: Implement visual mapping
    function _calculateAura(uint256 score, bool verified)
        internal
        pure
        returns (ReputationAura memory)
    {
        // TODO: Phase 3 Implementation
        // Aura rendering ideas:
        // - NONE: No additional visual elements
        // - EMBER: Subtle warm glow behind the core geometry
        // - FLAME: Visible pulsing orange ring
        // - RADIANT: Golden halo with light rays
        // - STELLAR: Multi-ring cosmic aura, constellation dots
        // - TRANSCENDENT: Full particle system, color-shifting aura, special border

        AuraTier tier = ClawReputation(address(0)).getAuraTier(score);

        return ReputationAura({
            auraIntensity: 0,
            auraColor: 0,
            auraRings: 0,
            verified: verified,
            legendary: tier == AuraTier.TRANSCENDENT,
            cachedScore: score,
            lastUpdated: 0
        });
    }

    /// @dev Generate SVG elements for the reputation aura
    /// TODO: Implement SVG generation for each tier
    function _renderAuraSVG(ReputationAura memory aura)
        internal
        pure
        returns (string memory)
    {
        // TODO: Phase 3 Implementation
        // Returns SVG string to be inserted by ClawRenderer
        // Each tier adds progressively more elaborate visual effects
        return "";
    }
}
