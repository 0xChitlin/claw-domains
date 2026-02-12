// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Strings.sol";

/// @title ColorLib - Deterministic color palette generation from wallet bytes
/// @notice Generates harmonious HSL color palettes from address entropy
library ColorLib {
    using Strings for uint256;

    struct HSL {
        uint256 h; // 0-359
        uint256 s; // 0-100
        uint256 l; // 0-100
    }

    /// @dev Generate a 5-color harmonious palette from an address
    /// Uses bytes 8-14 of the address for color derivation
    function generatePalette(address wallet) internal pure returns (HSL[5] memory palette) {
        bytes20 addrBytes = bytes20(wallet);

        // Base hue from bytes 8-9
        uint256 baseHue = (uint8(addrBytes[8]) * 256 + uint8(addrBytes[9])) % 360;

        // Harmony type from byte 10: 0=analogous, 1=triadic, 2=split-complementary, 3=tetradic
        uint256 harmonyType = uint8(addrBytes[10]) % 4;

        // Saturation range from byte 11 (50-90 range — rich but not neon)
        uint256 baseSat = 50 + (uint8(addrBytes[11]) % 41);

        // Lightness base from byte 12 (35-65 range — not too dark, not too light)
        uint256 baseLit = 35 + (uint8(addrBytes[12]) % 31);

        // Variation seeds from bytes 13-14
        uint256 satVar = uint8(addrBytes[13]) % 15;
        uint256 litVar = uint8(addrBytes[14]) % 15;

        if (harmonyType == 0) {
            // Analogous: hues within 30° of each other
            palette[0] = HSL(baseHue, baseSat, baseLit);
            palette[1] = HSL((baseHue + 25) % 360, baseSat - satVar, baseLit + litVar);
            palette[2] = HSL((baseHue + 350) % 360, baseSat + satVar / 2, baseLit - litVar / 2);
            palette[3] = HSL((baseHue + 15) % 360, baseSat - satVar / 2, baseLit + litVar / 2);
            palette[4] = HSL((baseHue + 340) % 360, baseSat, baseLit - litVar);
        } else if (harmonyType == 1) {
            // Triadic: 120° apart
            palette[0] = HSL(baseHue, baseSat, baseLit);
            palette[1] = HSL((baseHue + 120) % 360, baseSat - satVar, baseLit + litVar / 2);
            palette[2] = HSL((baseHue + 240) % 360, baseSat - satVar / 2, baseLit);
            palette[3] = HSL((baseHue + 60) % 360, baseSat / 2 + 20, baseLit + litVar);
            palette[4] = HSL((baseHue + 180) % 360, baseSat / 2 + 15, baseLit - litVar / 2);
        } else if (harmonyType == 2) {
            // Split-complementary: base + 150° + 210°
            palette[0] = HSL(baseHue, baseSat, baseLit);
            palette[1] = HSL((baseHue + 150) % 360, baseSat - satVar, baseLit + litVar / 2);
            palette[2] = HSL((baseHue + 210) % 360, baseSat - satVar / 2, baseLit);
            palette[3] = HSL((baseHue + 30) % 360, baseSat / 2 + 25, baseLit + litVar);
            palette[4] = HSL((baseHue + 180) % 360, baseSat / 2 + 10, baseLit - litVar);
        } else {
            // Tetradic: 90° apart
            palette[0] = HSL(baseHue, baseSat, baseLit);
            palette[1] = HSL((baseHue + 90) % 360, baseSat - satVar, baseLit);
            palette[2] = HSL((baseHue + 180) % 360, baseSat, baseLit + litVar / 2);
            palette[3] = HSL((baseHue + 270) % 360, baseSat - satVar / 2, baseLit - litVar / 2);
            palette[4] = HSL((baseHue + 45) % 360, baseSat / 2 + 20, baseLit + litVar);
        }

        return palette;
    }

    /// @dev Convert HSL to "hsl(h, s%, l%)" CSS string
    function toHSLString(HSL memory color) internal pure returns (string memory) {
        return string(abi.encodePacked(
            "hsl(",
            color.h.toString(),
            ",",
            color.s.toString(),
            "%,",
            color.l.toString(),
            "%)"
        ));
    }

    /// @dev Generate a darker version of a color
    function darken(HSL memory color, uint256 amount) internal pure returns (HSL memory) {
        uint256 newL = color.l > amount ? color.l - amount : 5;
        return HSL(color.h, color.s, newL);
    }

    /// @dev Generate a lighter version of a color
    function lighten(HSL memory color, uint256 amount) internal pure returns (HSL memory) {
        uint256 newL = color.l + amount > 95 ? 95 : color.l + amount;
        return HSL(color.h, color.s, newL);
    }

    /// @dev Generate a more saturated version
    function saturate(HSL memory color, uint256 amount) internal pure returns (HSL memory) {
        uint256 newS = color.s + amount > 100 ? 100 : color.s + amount;
        return HSL(color.h, newS, color.l);
    }

    /// @dev Generate a desaturated version
    function desaturate(HSL memory color, uint256 amount) internal pure returns (HSL memory) {
        uint256 newS = color.s > amount ? color.s - amount : 5;
        return HSL(color.h, newS, color.l);
    }
}
