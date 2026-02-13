// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ClawEvolution - Activity-based art evolution for .claw domains
/// @notice Tracks on-chain activity and computes evolution phase (0-4) for visual art
/// @dev Approved recorders (other contracts or EOAs) call recordActivity to track usage
contract ClawEvolution {

    // ============================================================
    //                     DATA STRUCTURES
    // ============================================================

    /// @notice Categories of on-chain activity
    enum ActivityType {
        TRANSFER,       // 0
        SKILL_USE,      // 1
        TOKEN_LAUNCH,   // 2
        TRADE,          // 3
        SOCIAL,         // 4
        GOVERNANCE      // 5
    }

    /// @notice Activity tracking data per token
    struct ActivityData {
        uint256 totalActivities;
        uint256 lastActivityBlock;
        uint256 lastActivityDay;      // block.timestamp / 86400
        uint256 streak;               // consecutive days active
        uint256[6] activityByType;    // count per ActivityType
    }

    // ============================================================
    //                          STORAGE
    // ============================================================

    /// @notice Contract owner
    address public owner;

    /// @notice Activity data per token ID
    mapping(uint256 => ActivityData) public activities;

    /// @notice Approved recorders who can call recordActivity
    mapping(address => bool) public approvedRecorders;

    // ============================================================
    //                          EVENTS
    // ============================================================

    event ActivityRecorded(uint256 indexed tokenId, ActivityType activityType, uint256 newTotal);
    event PhaseChanged(uint256 indexed tokenId, uint256 oldPhase, uint256 newPhase);
    event RecorderAdded(address indexed recorder);
    event RecorderRemoved(address indexed recorder);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    // ============================================================
    //                        MODIFIERS
    // ============================================================

    modifier onlyOwner() {
        require(msg.sender == owner, "ClawEvolution: not owner");
        _;
    }

    modifier onlyApprovedRecorder() {
        require(approvedRecorders[msg.sender], "ClawEvolution: not approved recorder");
        _;
    }

    // ============================================================
    //                       CONSTRUCTOR
    // ============================================================

    constructor() {
        owner = msg.sender;
    }

    // ============================================================
    //                   RECORDER MANAGEMENT
    // ============================================================

    /// @notice Add an approved recorder address
    function addApprovedRecorder(address recorder) external onlyOwner {
        approvedRecorders[recorder] = true;
        emit RecorderAdded(recorder);
    }

    /// @notice Remove an approved recorder address
    function removeApprovedRecorder(address recorder) external onlyOwner {
        approvedRecorders[recorder] = false;
        emit RecorderRemoved(recorder);
    }

    /// @notice Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "ClawEvolution: zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // ============================================================
    //                   ACTIVITY RECORDING
    // ============================================================

    /// @notice Record an activity for a token
    /// @param tokenId The token ID
    /// @param activityType The type of activity
    function recordActivity(uint256 tokenId, ActivityType activityType) external onlyApprovedRecorder {
        ActivityData storage data = activities[tokenId];

        uint256 oldPhase = _calculatePhase(data.totalActivities);

        // Update activity counts
        data.totalActivities += 1;
        data.activityByType[uint256(activityType)] += 1;

        // Update streak tracking
        uint256 currentDay = block.timestamp / 86400;
        if (data.lastActivityDay == 0) {
            // First activity ever
            data.streak = 1;
        } else if (currentDay == data.lastActivityDay + 1) {
            // Consecutive day — extend streak
            data.streak += 1;
        } else if (currentDay > data.lastActivityDay + 1) {
            // Streak broken — reset
            data.streak = 1;
        }
        // Same day — no streak change

        data.lastActivityBlock = block.number;
        data.lastActivityDay = currentDay;

        uint256 newPhase = _calculatePhase(data.totalActivities);

        emit ActivityRecorded(tokenId, activityType, data.totalActivities);

        if (newPhase != oldPhase) {
            emit PhaseChanged(tokenId, oldPhase, newPhase);
        }
    }

    /// @notice Batch record activities (gas efficient for bulk updates)
    /// @param tokenId The token ID
    /// @param activityType The type of activity
    /// @param count Number of activities to record
    function recordActivities(uint256 tokenId, ActivityType activityType, uint256 count) external onlyApprovedRecorder {
        require(count > 0 && count <= 100, "ClawEvolution: invalid count");

        ActivityData storage data = activities[tokenId];
        uint256 oldPhase = _calculatePhase(data.totalActivities);

        data.totalActivities += count;
        data.activityByType[uint256(activityType)] += count;

        // Update streak
        uint256 currentDay = block.timestamp / 86400;
        if (data.lastActivityDay == 0) {
            data.streak = 1;
        } else if (currentDay == data.lastActivityDay + 1) {
            data.streak += 1;
        } else if (currentDay > data.lastActivityDay + 1) {
            data.streak = 1;
        }

        data.lastActivityBlock = block.number;
        data.lastActivityDay = currentDay;

        uint256 newPhase = _calculatePhase(data.totalActivities);

        emit ActivityRecorded(tokenId, activityType, data.totalActivities);

        if (newPhase != oldPhase) {
            emit PhaseChanged(tokenId, oldPhase, newPhase);
        }
    }

    // ============================================================
    //                      VIEW FUNCTIONS
    // ============================================================

    /// @notice Get the evolution phase for a token (0-4)
    /// @dev Phase 0: Genesis (0), Phase 1: Awakening (1-10), Phase 2: Growth (11-50),
    ///      Phase 3: Maturity (51-200), Phase 4: Transcendence (201+)
    function getEvolutionPhase(uint256 tokenId) external view returns (uint256) {
        return _calculatePhase(activities[tokenId].totalActivities);
    }

    /// @notice Get total activity count for a token
    function getTotalActivities(uint256 tokenId) external view returns (uint256) {
        return activities[tokenId].totalActivities;
    }

    /// @notice Get activity count for a specific type
    function getActivityByType(uint256 tokenId, ActivityType activityType) external view returns (uint256) {
        return activities[tokenId].activityByType[uint256(activityType)];
    }

    /// @notice Get streak for a token
    function getStreak(uint256 tokenId) external view returns (uint256) {
        return activities[tokenId].streak;
    }

    /// @notice Get full activity data
    function getActivityData(uint256 tokenId) external view returns (
        uint256 totalActivities,
        uint256 lastActivityBlock,
        uint256 streak,
        uint256[6] memory activityByType
    ) {
        ActivityData storage data = activities[tokenId];
        return (data.totalActivities, data.lastActivityBlock, data.streak, data.activityByType);
    }

    // ============================================================
    //                      INTERNAL
    // ============================================================

    /// @dev Calculate evolution phase from total activities
    function _calculatePhase(uint256 total) internal pure returns (uint256) {
        if (total == 0) return 0;       // Genesis
        if (total <= 10) return 1;      // Awakening
        if (total <= 50) return 2;      // Growth
        if (total <= 200) return 3;     // Maturity
        return 4;                       // Transcendence
    }
}
