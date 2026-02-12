// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title MathLib - Fixed-point trigonometry helpers for SVG path generation
/// @notice All angles in degrees (0-359). Returns scaled integers for SVG coords.
library MathLib {
    /// @dev Sine lookup table (0-90 degrees), values scaled by 1000
    /// sin(0)=0, sin(30)=500, sin(45)=707, sin(60)=866, sin(90)=1000
    function sin(uint256 degrees) internal pure returns (int256) {
        degrees = degrees % 360;
        bool negative = degrees >= 180;
        if (degrees >= 180) degrees -= 180;
        if (degrees > 90) degrees = 180 - degrees;

        // Attempt a polynomial approximation scaled by 1000
        // sin(x) ≈ x*(180-x)*4 / (40500 - x*(180-x)) [Bhaskara I]
        // But we need radians... let's use a lookup instead for key angles
        // and linear interpolation

        int256 result;
        if (degrees <= 5) {
            // sin(0-5) ≈ linear: 0 to 87
            result = int256(degrees) * 87 / 5;
        } else if (degrees <= 10) {
            result = 87 + int256(degrees - 5) * (174 - 87) / 5;
        } else if (degrees <= 15) {
            result = 174 + int256(degrees - 10) * (259 - 174) / 5;
        } else if (degrees <= 20) {
            result = 259 + int256(degrees - 15) * (342 - 259) / 5;
        } else if (degrees <= 25) {
            result = 342 + int256(degrees - 20) * (423 - 342) / 5;
        } else if (degrees <= 30) {
            result = 423 + int256(degrees - 25) * (500 - 423) / 5;
        } else if (degrees <= 35) {
            result = 500 + int256(degrees - 30) * (574 - 500) / 5;
        } else if (degrees <= 40) {
            result = 574 + int256(degrees - 35) * (643 - 574) / 5;
        } else if (degrees <= 45) {
            result = 643 + int256(degrees - 40) * (707 - 643) / 5;
        } else if (degrees <= 50) {
            result = 707 + int256(degrees - 45) * (766 - 707) / 5;
        } else if (degrees <= 55) {
            result = 766 + int256(degrees - 50) * (819 - 766) / 5;
        } else if (degrees <= 60) {
            result = 819 + int256(degrees - 55) * (866 - 819) / 5;
        } else if (degrees <= 65) {
            result = 866 + int256(degrees - 60) * (906 - 866) / 5;
        } else if (degrees <= 70) {
            result = 906 + int256(degrees - 65) * (940 - 906) / 5;
        } else if (degrees <= 75) {
            result = 940 + int256(degrees - 70) * (966 - 940) / 5;
        } else if (degrees <= 80) {
            result = 966 + int256(degrees - 75) * (985 - 966) / 5;
        } else if (degrees <= 85) {
            result = 985 + int256(degrees - 80) * (996 - 985) / 5;
        } else {
            result = 996 + int256(degrees - 85) * (1000 - 996) / 5;
        }

        return negative ? -result : result;
    }

    function cos(uint256 degrees) internal pure returns (int256) {
        return sin(degrees + 90);
    }

    /// @dev Returns x coordinate on a circle: cx + radius * cos(angle)
    /// Result scaled assuming radius and cx are in SVG units
    function circleX(uint256 cx, uint256 radius, uint256 angleDeg) internal pure returns (uint256) {
        int256 cosVal = cos(angleDeg);
        int256 result = int256(cx) + (int256(radius) * cosVal) / 1000;
        return result >= 0 ? uint256(result) : 0;
    }

    /// @dev Returns y coordinate on a circle: cy + radius * sin(angle)
    function circleY(uint256 cy, uint256 radius, uint256 angleDeg) internal pure returns (uint256) {
        int256 sinVal = sin(angleDeg);
        int256 result = int256(cy) + (int256(radius) * sinVal) / 1000;
        return result >= 0 ? uint256(result) : 0;
    }

    /// @dev Pseudo-random number from seed, bounded
    function random(uint256 seed, uint256 max) internal pure returns (uint256) {
        if (max == 0) return 0;
        return uint256(keccak256(abi.encodePacked(seed))) % max;
    }

    /// @dev Derive multiple random values from a single seed
    function randomN(uint256 seed, uint256 index, uint256 max) internal pure returns (uint256) {
        return random(uint256(keccak256(abi.encodePacked(seed, index))), max);
    }
}
