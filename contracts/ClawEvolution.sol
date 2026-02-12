// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ClawRegistry.sol";

/// @title ClawEvolution - Activity-based art evolution for .claw domains (Phase 2 Scaffold)
/// @notice Reads agent on-chain activity and updates art parameters accordingly
/// @dev SCAFFOLD — interfaces and structs defined, core logic TODO
contract ClawEvolution {

    // ============================================================
    //                     DATA STRUCTURES
    // ============================================================

    /// @notice Categories of on-chain activity that affect art evolution
    enum ActivityCategory {
        TRANSFERS,           // ETH/token transfers
        CONTRACT_INTERACTIONS, // Smart contract calls
        DEFI,               // DEX swaps, lending, etc.
        NFT,                // NFT mints, trades
        GOVERNANCE          // DAO votes, proposals
    }

    /// @notice Activity snapshot for a domain
    struct ActivitySnapshot {
        uint256 totalTransactions;
        uint256 transferCount;
        uint256 contractInteractionCount;
        uint256 defiCount;
        uint256 nftCount;
        uint256 governanceCount;
        uint256 lastUpdatedBlock;
        uint256 evolutionStage; // 0 = genesis, 1-5 = evolution stages
    }

    /// @notice Evolution visual parameters derived from activity
    struct EvolutionParams {
        uint8 complexity;      // 0-255: how many extra visual elements
        uint8 energyLevel;     // 0-255: glow intensity
        uint8 colorShift;      // 0-255: hue rotation from base
        uint8 patternDensity;  // 0-255: detail element density
        uint8 auraSize;        // 0-255: outer glow radius
        bool hasDefiRing;      // DeFi activity adds orbital ring
        bool hasNftSparkle;    // NFT activity adds sparkle particles
        bool hasGovCrown;      // Governance activity adds crown element
    }

    // ============================================================
    //                          STORAGE
    // ============================================================

    /// @notice Reference to the ClawRegistry
    ClawRegistry public registry;

    /// @notice Activity snapshots per token
    mapping(uint256 => ActivitySnapshot) public activities;

    /// @notice Evolution parameters per token
    mapping(uint256 => EvolutionParams) public evolutionParams;

    /// @notice Authorized activity reporters (oracles/indexers)
    mapping(address => bool) public reporters;

    // ============================================================
    //                          EVENTS
    // ============================================================

    event ArtEvolved(uint256 indexed tokenId, uint256 newStage);
    event ActivityReported(uint256 indexed tokenId, ActivityCategory category, uint256 count);
    event ReporterUpdated(address indexed reporter, bool authorized);

    // ============================================================
    //                       CONSTRUCTOR
    // ============================================================

    constructor(address _registry) {
        registry = ClawRegistry(_registry);
    }

    // ============================================================
    //                    EVOLUTION FUNCTIONS
    // ============================================================

    /// @notice Update the art for a token based on latest activity data
    /// @param tokenId The token to evolve
    /// @dev TODO: Implement activity reading and evolution calculation
    function updateArt(uint256 tokenId) external {
        // TODO: Phase 2 Implementation
        // 1. Read current activity snapshot
        // 2. Query on-chain activity (or accept from authorized reporter)
        // 3. Calculate new evolution parameters
        // 4. Update evolution stage if thresholds met
        // 5. Emit ArtEvolved event

        revert("ClawEvolution: not yet implemented");
    }

    /// @notice Report activity for a token (called by authorized reporters/oracles)
    /// @param tokenId The token ID
    /// @param category The activity category
    /// @param count Number of new activities in this category
    /// @dev TODO: Implement activity aggregation
    function reportActivity(
        uint256 tokenId,
        ActivityCategory category,
        uint256 count
    ) external {
        // TODO: Phase 2 Implementation
        // 1. Verify caller is authorized reporter
        // 2. Update activity snapshot
        // 3. Check if evolution thresholds are met
        // 4. If so, trigger art evolution

        revert("ClawEvolution: not yet implemented");
    }

    // ============================================================
    //                      VIEW FUNCTIONS
    // ============================================================

    /// @notice Get current evolution stage for a token
    function getEvolutionStage(uint256 tokenId) external view returns (uint256) {
        return activities[tokenId].evolutionStage;
    }

    /// @notice Get evolution visual parameters for a token
    function getEvolutionParams(uint256 tokenId) external view returns (EvolutionParams memory) {
        return evolutionParams[tokenId];
    }

    /// @notice Get full activity snapshot for a token
    function getActivity(uint256 tokenId) external view returns (ActivitySnapshot memory) {
        return activities[tokenId];
    }

    // ============================================================
    //                  INTERNAL HELPERS (TODO)
    // ============================================================

    /// @dev Calculate evolution parameters from activity data
    /// TODO: Implement the mapping from activity counts to visual parameters
    function _calculateEvolution(ActivitySnapshot memory snapshot)
        internal
        pure
        returns (EvolutionParams memory)
    {
        // TODO: Phase 2 Implementation
        // Mapping ideas:
        // - totalTransactions > 100 → complexity increases
        // - DeFi count > 10 → adds orbital ring
        // - NFT count > 5 → adds sparkle particles
        // - Governance count > 3 → adds crown element
        // - Each category shifts color palette slightly
        // - Higher activity = more energy glow

        return EvolutionParams({
            complexity: 0,
            energyLevel: 0,
            colorShift: 0,
            patternDensity: 0,
            auraSize: 0,
            hasDefiRing: false,
            hasNftSparkle: false,
            hasGovCrown: false
        });
    }

    /// @dev Determine evolution stage from total activity
    /// TODO: Define thresholds for each stage
    function _calculateStage(uint256 totalTransactions) internal pure returns (uint256) {
        // TODO: Phase 2 Implementation
        // Stage 0: Genesis (0-49 txns)
        // Stage 1: Awakening (50-199 txns)
        // Stage 2: Growth (200-499 txns)
        // Stage 3: Maturity (500-999 txns)
        // Stage 4: Transcendence (1000-4999 txns)
        // Stage 5: Legendary (5000+ txns)

        if (totalTransactions < 50) return 0;
        if (totalTransactions < 200) return 1;
        if (totalTransactions < 500) return 2;
        if (totalTransactions < 1000) return 3;
        if (totalTransactions < 5000) return 4;
        return 5;
    }
}
