// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/// @title ClawRenderer - On-chain CryptoPunks-style pixel art generator for .claw domains
/// @notice Produces deterministic 24x24 pixel art characters from wallet address + tokenId
/// @dev All art is computed on-chain with no external dependencies. Supports evolution phases 0-4.
contract ClawRenderer {
    using Strings for uint256;

    // ============================================================
    //                       STRUCTS
    // ============================================================

    struct Traits {
        uint8 headType;    // 0-3
        uint8 skinColor;   // 0-7
        uint8 eyeType;     // 0-9
        uint8 mouthType;   // 0-7
        uint8 headwear;    // 0-9 (0 = none)
        uint8 accessory;   // 0-7 (0 = none)
    }

    // ============================================================
    //                    PUBLIC INTERFACE
    // ============================================================

    /// @notice Generate complete tokenURI JSON with embedded SVG (base version)
    function renderTokenURI(
        address minter,
        uint256 tokenId,
        uint256 mintBlock,
        string memory name,
        string memory description
    ) external pure returns (string memory) {
        return renderEvolvedTokenURI(minter, tokenId, mintBlock, name, description, 0, 0);
    }

    /// @notice Generate evolution-aware tokenURI JSON
    function renderEvolvedTokenURI(
        address minter,
        uint256 tokenId,
        uint256 mintBlock,
        string memory name,
        string memory description,
        uint256 phase,
        uint256 activityCount
    ) public pure returns (string memory) {
        Traits memory t = _getTraits(minter, tokenId);
        uint8 safePhase = phase > 4 ? 4 : uint8(phase);

        string memory svg = _renderSVG(t, safePhase, name);
        string memory imageURI = _svgToDataURI(svg);

        string memory json = string(abi.encodePacked(
            '{"name":"', name, '.claw",',
            '"description":"', bytes(description).length > 0 ? description : "A living .claw agent identity", '",',
            '"image":"', imageURI, '",',
            '"attributes":[',
            _buildAttributes(t, safePhase, activityCount, name),
            ']}'
        ));

        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        ));
    }

    /// @notice Generate just the SVG
    function renderSVG(
        address minter,
        uint256 tokenId,
        uint256 mintBlock,
        string memory name
    ) external pure returns (string memory) {
        return renderEvolvedSVG(minter, tokenId, mintBlock, name, 0, 0);
    }

    /// @notice Generate evolution-aware SVG
    function renderEvolvedSVG(
        address minter,
        uint256 tokenId,
        uint256 mintBlock,
        string memory name,
        uint256 phase,
        uint256 activityCount
    ) public pure returns (string memory) {
        Traits memory t = _getTraits(minter, tokenId);
        uint8 safePhase = phase > 4 ? 4 : uint8(phase);
        return _renderSVG(t, safePhase, name);
    }

    // ============================================================
    //                    TRAIT DERIVATION
    // ============================================================

    function _getTraits(address minter, uint256 tokenId) internal pure returns (Traits memory) {
        bytes32 hash = keccak256(abi.encodePacked(minter, tokenId));
        return Traits({
            headType:  uint8(hash[0]) % 4,
            skinColor: uint8(hash[1]) % 8,
            eyeType:   uint8(hash[2]) % 10,
            mouthType: uint8(hash[3]) % 8,
            headwear:  uint8(hash[4]) % 10,
            accessory: uint8(hash[5]) % 8
        });
    }

    // ============================================================
    //                     SVG RENDERING
    // ============================================================

    function _renderSVG(Traits memory t, uint8 phase, string memory name) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" shape-rendering="crispEdges" width="480" height="480">',
            _renderBackground(phase),
            _renderEvolutionBehind(phase),
            _renderCharacter(t),
            _renderEvolutionFront(phase),
            _renderNameLabel(name, phase),
            '</svg>'
        ));
    }

    // ============================================================
    //                     BACKGROUND
    // ============================================================

    function _renderBackground(uint8 phase) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<rect width="24" height="24" fill="', _bgColor(phase), '"/>'
        ));
    }

    function _bgColor(uint8 phase) internal pure returns (string memory) {
        if (phase == 0) return "#1a1a2e";
        if (phase == 1) return "#16213e";
        if (phase == 2) return "#1a1a3e";
        if (phase == 3) return "#0a2e1a";
        return "#2e2a0a";
    }

    // ============================================================
    //                  EVOLUTION EFFECTS (BEHIND)
    // ============================================================

    function _renderEvolutionBehind(uint8 phase) internal pure returns (string memory) {
        if (phase == 0) return "";

        string memory effects = "";

        if (phase >= 1) {
            // Subtle glow behind head
            effects = string(abi.encodePacked(
                '<rect x="8" y="5" width="8" height="10" rx="2" fill="', _glowColor(phase), '" opacity="0.2"/>'
            ));
        }

        if (phase >= 3) {
            // Aura ring
            effects = string(abi.encodePacked(
                effects,
                '<rect x="6" y="3" width="12" height="16" rx="3" fill="none" stroke="', _glowColor(phase), '" stroke-width="0.3" opacity="0.4"/>'
            ));
        }

        if (phase >= 4) {
            // Golden border
            effects = string(abi.encodePacked(
                effects,
                '<rect x="0.5" y="0.5" width="23" height="23" fill="none" stroke="#ffd700" stroke-width="0.5" opacity="0.6"/>',
                '<rect x="1" y="1" width="22" height="22" fill="none" stroke="#ffd700" stroke-width="0.2" opacity="0.3"/>'
            ));
        }

        return effects;
    }

    function _glowColor(uint8 phase) internal pure returns (string memory) {
        if (phase == 1) return "#2040a0";
        if (phase == 2) return "#6030b0";
        if (phase == 3) return "#20a040";
        return "#d4a017";
    }

    // ============================================================
    //                  EVOLUTION EFFECTS (FRONT)
    // ============================================================

    function _renderEvolutionFront(uint8 phase) internal pure returns (string memory) {
        if (phase < 2) return "";

        string memory effects = "";

        if (phase == 2) {
            // 3-4 small particles
            effects = string(abi.encodePacked(
                _px(3, 4, "#ffffff", "0.5"),
                _px(20, 7, "#ffffff", "0.5"),
                _px(5, 15, "#ffffff", "0.4")
            ));
        } else if (phase == 3) {
            // More particles
            effects = string(abi.encodePacked(
                _px(2, 3, "#ffffff", "0.5"),
                _px(21, 5, "#ffffff", "0.5"),
                _px(3, 16, "#ffffff", "0.5"),
                _px(20, 14, "#ffffff", "0.4"),
                _px(4, 9, "#ffffff", "0.3"),
                _px(19, 10, "#ffffff", "0.3")
            ));
        } else {
            // Phase 4: lots of particles + animation
            effects = string(abi.encodePacked(
                _px(2, 2, "#ffd700", "0.7"),
                _px(21, 3, "#ffd700", "0.6"),
                _px(1, 10, "#ffd700", "0.6"),
                _px(22, 11, "#ffd700", "0.5"),
                _px(3, 17, "#ffd700", "0.6"),
                _px(20, 16, "#ffd700", "0.5")
            ));
            effects = string(abi.encodePacked(
                effects,
                _px(4, 5, "#ffd700", "0.4"),
                _px(19, 6, "#ffd700", "0.4"),
                // Animated glow
                '<rect x="7" y="4" width="10" height="12" rx="2" fill="#ffd700" opacity="0.1">',
                '<animate attributeName="opacity" values="0.05;0.15;0.05" dur="3s" repeatCount="indefinite"/>',
                '</rect>'
            ));
        }

        return effects;
    }

    // ============================================================
    //                   CHARACTER RENDERING
    // ============================================================

    function _renderCharacter(Traits memory t) internal pure returns (string memory) {
        string memory skin = _skinColor(t.skinColor);
        string memory skinDk = _skinDark(t.skinColor);
        string memory skinLt = _skinLight(t.skinColor);

        return string(abi.encodePacked(
            _renderHead(t.headType, skin, skinDk, skinLt),
            _renderEyes(t.eyeType, t.headType),
            _renderMouth(t.mouthType, t.headType),
            _renderHeadwear(t.headwear),
            _renderAccessory(t.accessory)
        ));
    }

    // ============================================================
    //                    HEAD SHAPES
    // ============================================================

    function _renderHead(uint8 headType, string memory skin, string memory dark, string memory light) internal pure returns (string memory) {
        if (headType == 0) return _roundHead(skin, dark, light);
        if (headType == 1) return _squareHead(skin, dark, light);
        if (headType == 2) return _tallHead(skin, dark, light);
        return _wideHead(skin, dark, light);
    }

    /// @dev Type 0: Round robot head - friendly oval
    function _roundHead(string memory s, string memory d, string memory l) internal pure returns (string memory) {
        // Neck
        string memory neck = string(abi.encodePacked(
            _px(10, 16, s, "1"), _px(11, 16, s, "1"), _px(12, 16, s, "1"), _px(13, 16, s, "1"),
            _px(10, 17, d, "1"), _px(11, 17, d, "1"), _px(12, 17, d, "1"), _px(13, 17, d, "1")
        ));
        // Head outline - row by row
        // Row 4: top curve
        string memory r4 = string(abi.encodePacked(
            _px(9, 4, d, "1"), _px(10, 4, d, "1"), _px(11, 4, d, "1"), _px(12, 4, d, "1"), _px(13, 4, d, "1"), _px(14, 4, d, "1")
        ));
        // Row 5: wider
        string memory r5 = string(abi.encodePacked(
            _px(8, 5, d, "1"), _px(9, 5, l, "1"), _px(10, 5, l, "1"), _px(11, 5, s, "1"), _px(12, 5, s, "1"), _px(13, 5, s, "1"), _px(14, 5, s, "1"), _px(15, 5, d, "1")
        ));
        // Rows 6-13: main head body
        string memory body = _headBodyRows(6, 14, 7, 16, s, d, l);
        // Row 14: chin tapers
        string memory r14 = string(abi.encodePacked(
            _px(8, 14, d, "1"), _px(9, 14, s, "1"), _px(10, 14, s, "1"), _px(11, 14, s, "1"), _px(12, 14, s, "1"), _px(13, 14, s, "1"), _px(14, 14, s, "1"), _px(15, 14, d, "1")
        ));
        // Row 15: bottom
        string memory r15 = string(abi.encodePacked(
            _px(9, 15, d, "1"), _px(10, 15, d, "1"), _px(11, 15, s, "1"), _px(12, 15, s, "1"), _px(13, 15, d, "1"), _px(14, 15, d, "1")
        ));

        return string(abi.encodePacked(neck, r4, r5, body, r14, r15));
    }

    /// @dev Type 1: Square android head - boxy
    function _squareHead(string memory s, string memory d, string memory l) internal pure returns (string memory) {
        string memory neck = string(abi.encodePacked(
            _px(10, 16, s, "1"), _px(11, 16, s, "1"), _px(12, 16, s, "1"), _px(13, 16, s, "1"),
            _px(10, 17, d, "1"), _px(11, 17, d, "1"), _px(12, 17, d, "1"), _px(13, 17, d, "1")
        ));
        // Top edge
        string memory top = string(abi.encodePacked(
            _px(7, 5, d, "1"), _px(8, 5, d, "1"), _px(9, 5, d, "1"), _px(10, 5, d, "1"), _px(11, 5, d, "1"),
            _px(12, 5, d, "1"), _px(13, 5, d, "1"), _px(14, 5, d, "1"), _px(15, 5, d, "1"), _px(16, 5, d, "1")
        ));
        // Body rows 6-14 (square shape)
        string memory body = _headBodyRows(6, 15, 7, 16, s, d, l);
        // Bottom edge
        string memory bot = string(abi.encodePacked(
            _px(7, 15, d, "1"), _px(8, 15, d, "1"), _px(9, 15, d, "1"), _px(10, 15, d, "1"), _px(11, 15, d, "1"),
            _px(12, 15, d, "1"), _px(13, 15, d, "1"), _px(14, 15, d, "1"), _px(15, 15, d, "1"), _px(16, 15, d, "1")
        ));

        return string(abi.encodePacked(neck, top, body, bot));
    }

    /// @dev Type 2: Tall oval cyborg head
    function _tallHead(string memory s, string memory d, string memory l) internal pure returns (string memory) {
        string memory neck = string(abi.encodePacked(
            _px(10, 17, s, "1"), _px(11, 17, s, "1"), _px(12, 17, s, "1"), _px(13, 17, s, "1"),
            _px(10, 18, d, "1"), _px(11, 18, d, "1"), _px(12, 18, d, "1"), _px(13, 18, d, "1")
        ));
        // Top curve - narrow
        string memory r3 = string(abi.encodePacked(
            _px(10, 3, d, "1"), _px(11, 3, d, "1"), _px(12, 3, d, "1"), _px(13, 3, d, "1")
        ));
        string memory r4 = string(abi.encodePacked(
            _px(9, 4, d, "1"), _px(10, 4, l, "1"), _px(11, 4, s, "1"), _px(12, 4, s, "1"), _px(13, 4, s, "1"), _px(14, 4, d, "1")
        ));
        // Body rows 5-15
        string memory body = _headBodyRows(5, 15, 8, 15, s, d, l);
        // Bottom
        string memory r15 = string(abi.encodePacked(
            _px(9, 15, d, "1"), _px(10, 15, s, "1"), _px(11, 15, s, "1"), _px(12, 15, s, "1"), _px(13, 15, s, "1"), _px(14, 15, d, "1")
        ));
        string memory r16 = string(abi.encodePacked(
            _px(10, 16, d, "1"), _px(11, 16, d, "1"), _px(12, 16, d, "1"), _px(13, 16, d, "1")
        ));

        return string(abi.encodePacked(neck, r3, r4, body, r15, r16));
    }

    /// @dev Type 3: Wide tank bot head
    function _wideHead(string memory s, string memory d, string memory l) internal pure returns (string memory) {
        string memory neck = string(abi.encodePacked(
            _px(10, 15, s, "1"), _px(11, 15, s, "1"), _px(12, 15, s, "1"), _px(13, 15, s, "1"),
            _px(9, 16, d, "1"), _px(10, 16, d, "1"), _px(11, 16, d, "1"), _px(12, 16, d, "1"), _px(13, 16, d, "1"), _px(14, 16, d, "1")
        ));
        // Top
        string memory top = string(abi.encodePacked(
            _px(6, 5, d, "1"), _px(7, 5, d, "1"), _px(8, 5, d, "1"), _px(9, 5, d, "1"), _px(10, 5, d, "1"),
            _px(11, 5, d, "1"), _px(12, 5, d, "1"), _px(13, 5, d, "1"), _px(14, 5, d, "1"), _px(15, 5, d, "1"),
            _px(16, 5, d, "1"), _px(17, 5, d, "1")
        ));
        // Body rows 6-13 (wide)
        string memory body = _headBodyRows(6, 14, 5, 18, s, d, l);
        // Bottom
        string memory bot = string(abi.encodePacked(
            _px(6, 14, d, "1"), _px(7, 14, d, "1"), _px(8, 14, s, "1"), _px(9, 14, s, "1"), _px(10, 14, s, "1"),
            _px(11, 14, s, "1"), _px(12, 14, s, "1"), _px(13, 14, s, "1"), _px(14, 14, s, "1"), _px(15, 14, s, "1"),
            _px(16, 14, d, "1"), _px(17, 14, d, "1")
        ));

        return string(abi.encodePacked(neck, top, body, bot));
    }

    /// @dev Render a block of head body rows with left/right edge coloring
    function _headBodyRows(
        uint8 startY, uint8 endY, uint8 leftX, uint8 rightX,
        string memory s, string memory d, string memory l
    ) internal pure returns (string memory) {
        string memory rows = "";
        for (uint8 y = startY; y < endY; y++) {
            for (uint8 x = leftX; x <= rightX; x++) {
                string memory color;
                if (x == leftX) {
                    color = d;  // left edge shadow
                } else if (x == leftX + 1 && y == startY) {
                    color = l;  // top-left highlight
                } else if (x == rightX) {
                    color = d;  // right edge shadow
                } else if (x == leftX + 1) {
                    color = l;  // left highlight strip
                } else {
                    color = s;  // main skin
                }
                rows = string(abi.encodePacked(rows, _px(x, y, color, "1")));
            }
        }
        return rows;
    }

    // ============================================================
    //                       EYES
    // ============================================================

    function _renderEyes(uint8 eyeType, uint8 headType) internal pure returns (string memory) {
        string memory eyeColor = _eyeColor(eyeType);
        // Position eyes based on head type
        uint8 eyeY = headType == 2 ? 8 : (headType == 3 ? 8 : 9);
        uint8 leftEyeX = headType == 3 ? 8 : 9;
        uint8 rightEyeX = headType == 3 ? 14 : 13;

        if (eyeType == 0) {
            // Dot eyes - simple 1px dots
            return string(abi.encodePacked(
                _px(leftEyeX, eyeY, eyeColor, "1"),
                _px(rightEyeX, eyeY, eyeColor, "1")
            ));
        }
        if (eyeType == 1) {
            // Visor - horizontal bar
            string memory visor = "";
            for (uint8 x = leftEyeX; x <= rightEyeX; x++) {
                visor = string(abi.encodePacked(visor, _px(x, eyeY, eyeColor, "1")));
            }
            return visor;
        }
        if (eyeType == 2) {
            // Laser red - 2px each eye with trailing laser line
            return string(abi.encodePacked(
                _px(leftEyeX, eyeY, eyeColor, "1"), _px(leftEyeX + 1, eyeY, eyeColor, "1"),
                _px(rightEyeX - 1, eyeY, eyeColor, "1"), _px(rightEyeX, eyeY, eyeColor, "1"),
                _px(leftEyeX - 1, eyeY, eyeColor, "0.4"), _px(rightEyeX + 1, eyeY, eyeColor, "0.4")
            ));
        }
        if (eyeType == 3) {
            // Glowing green - 2x2 eyes with glow
            return string(abi.encodePacked(
                _px(leftEyeX, eyeY, eyeColor, "1"), _px(leftEyeX + 1, eyeY, eyeColor, "1"),
                _px(leftEyeX, eyeY + 1, eyeColor, "0.5"), _px(leftEyeX + 1, eyeY + 1, eyeColor, "0.5"),
                _px(rightEyeX - 1, eyeY, eyeColor, "1"), _px(rightEyeX, eyeY, eyeColor, "1"),
                _px(rightEyeX - 1, eyeY + 1, eyeColor, "0.5"), _px(rightEyeX, eyeY + 1, eyeColor, "0.5")
            ));
        }
        if (eyeType == 4) {
            // Cyclops - single large centered eye
            uint8 cx = (leftEyeX + rightEyeX) / 2;
            return string(abi.encodePacked(
                _px(cx, eyeY - 1, "#ffffff", "0.5"),
                _px(cx - 1, eyeY, "#ffffff", "0.8"), _px(cx, eyeY, eyeColor, "1"), _px(cx + 1, eyeY, "#ffffff", "0.8"),
                _px(cx, eyeY + 1, "#ffffff", "0.5")
            ));
        }
        if (eyeType == 5) {
            // Matrix code - vertical dots
            return string(abi.encodePacked(
                _px(leftEyeX, eyeY - 1, eyeColor, "0.4"), _px(leftEyeX, eyeY, eyeColor, "1"), _px(leftEyeX, eyeY + 1, eyeColor, "0.6"),
                _px(rightEyeX, eyeY - 1, eyeColor, "0.4"), _px(rightEyeX, eyeY, eyeColor, "1"), _px(rightEyeX, eyeY + 1, eyeColor, "0.6")
            ));
        }
        if (eyeType == 6) {
            // X eyes
            return string(abi.encodePacked(
                _px(leftEyeX - 1, eyeY - 1, eyeColor, "1"), _px(leftEyeX + 1, eyeY - 1, eyeColor, "1"),
                _px(leftEyeX, eyeY, eyeColor, "1"),
                _px(leftEyeX - 1, eyeY + 1, eyeColor, "1"), _px(leftEyeX + 1, eyeY + 1, eyeColor, "1"),
                _px(rightEyeX - 1, eyeY - 1, eyeColor, "1"), _px(rightEyeX + 1, eyeY - 1, eyeColor, "1"),
                _px(rightEyeX, eyeY, eyeColor, "1"),
                _px(rightEyeX - 1, eyeY + 1, eyeColor, "1"), _px(rightEyeX + 1, eyeY + 1, eyeColor, "1")
            ));
        }
        if (eyeType == 7) {
            // Heart eyes
            return string(abi.encodePacked(
                _px(leftEyeX - 1, eyeY, eyeColor, "1"), _px(leftEyeX + 1, eyeY, eyeColor, "1"),
                _px(leftEyeX - 1, eyeY + 1, eyeColor, "0.7"), _px(leftEyeX, eyeY + 1, eyeColor, "1"), _px(leftEyeX + 1, eyeY + 1, eyeColor, "0.7"),
                _px(leftEyeX, eyeY + 2, eyeColor, "0.5"),
                _px(rightEyeX - 1, eyeY, eyeColor, "1"), _px(rightEyeX + 1, eyeY, eyeColor, "1"),
                _px(rightEyeX - 1, eyeY + 1, eyeColor, "0.7"), _px(rightEyeX, eyeY + 1, eyeColor, "1"), _px(rightEyeX + 1, eyeY + 1, eyeColor, "0.7"),
                _px(rightEyeX, eyeY + 2, eyeColor, "0.5")
            ));
        }
        if (eyeType == 8) {
            // Diamond eyes
            return string(abi.encodePacked(
                _px(leftEyeX, eyeY - 1, eyeColor, "0.6"),
                _px(leftEyeX - 1, eyeY, eyeColor, "0.8"), _px(leftEyeX, eyeY, "#ffffff", "1"), _px(leftEyeX + 1, eyeY, eyeColor, "0.8"),
                _px(leftEyeX, eyeY + 1, eyeColor, "0.6"),
                _px(rightEyeX, eyeY - 1, eyeColor, "0.6"),
                _px(rightEyeX - 1, eyeY, eyeColor, "0.8"), _px(rightEyeX, eyeY, "#ffffff", "1"), _px(rightEyeX + 1, eyeY, eyeColor, "0.8"),
                _px(rightEyeX, eyeY + 1, eyeColor, "0.6")
            ));
        }
        // eyeType == 9: Fire eyes
        return string(abi.encodePacked(
            _px(leftEyeX, eyeY - 2, eyeColor, "0.3"), _px(leftEyeX, eyeY - 1, eyeColor, "0.6"),
            _px(leftEyeX, eyeY, eyeColor, "1"), _px(leftEyeX + 1, eyeY, "#ffff00", "0.8"),
            _px(leftEyeX, eyeY + 1, "#ffff00", "0.4"),
            _px(rightEyeX, eyeY - 2, eyeColor, "0.3"), _px(rightEyeX, eyeY - 1, eyeColor, "0.6"),
            _px(rightEyeX, eyeY, eyeColor, "1"), _px(rightEyeX - 1, eyeY, "#ffff00", "0.8"),
            _px(rightEyeX, eyeY + 1, "#ffff00", "0.4")
        ));
    }

    // ============================================================
    //                        MOUTHS
    // ============================================================

    function _renderMouth(uint8 mouthType, uint8 headType) internal pure returns (string memory) {
        string memory mColor = _mouthColor(mouthType);
        uint8 mouthY = headType == 2 ? 13 : (headType == 3 ? 12 : 12);
        uint8 mLeftX = headType == 3 ? 9 : 9;

        if (mouthType == 0) {
            // LED smile - curved line
            return string(abi.encodePacked(
                _px(mLeftX + 1, mouthY, mColor, "1"), _px(mLeftX + 2, mouthY + 1, mColor, "1"),
                _px(mLeftX + 3, mouthY + 1, mColor, "1"), _px(mLeftX + 4, mouthY, mColor, "1")
            ));
        }
        if (mouthType == 1) {
            // Speaker grille - dots
            return string(abi.encodePacked(
                _px(mLeftX + 1, mouthY, mColor, "1"), _px(mLeftX + 3, mouthY, mColor, "1"),
                _px(mLeftX + 2, mouthY + 1, mColor, "1"), _px(mLeftX + 4, mouthY + 1, mColor, "1")
            ));
        }
        if (mouthType == 2) {
            // Antenna nub
            return string(abi.encodePacked(
                _px(mLeftX + 2, mouthY, mColor, "1"), _px(mLeftX + 3, mouthY, mColor, "1"),
                _px(mLeftX + 2, mouthY + 1, mColor, "0.6")
            ));
        }
        if (mouthType == 3) {
            // Gas mask
            return string(abi.encodePacked(
                _px(mLeftX, mouthY, mColor, "0.6"), _px(mLeftX + 1, mouthY, mColor, "1"),
                _px(mLeftX + 2, mouthY, mColor, "1"), _px(mLeftX + 3, mouthY, mColor, "1"),
                _px(mLeftX + 4, mouthY, mColor, "1"), _px(mLeftX + 5, mouthY, mColor, "0.6"),
                _px(mLeftX + 1, mouthY + 1, mColor, "0.8"), _px(mLeftX + 2, mouthY + 1, "#333", "1"),
                _px(mLeftX + 3, mouthY + 1, "#333", "1"), _px(mLeftX + 4, mouthY + 1, mColor, "0.8")
            ));
        }
        if (mouthType == 4) {
            // Fangs
            return string(abi.encodePacked(
                _px(mLeftX + 1, mouthY, mColor, "1"), _px(mLeftX + 2, mouthY, "#333", "1"),
                _px(mLeftX + 3, mouthY, "#333", "1"), _px(mLeftX + 4, mouthY, mColor, "1"),
                _px(mLeftX + 1, mouthY + 1, mColor, "0.8"), _px(mLeftX + 4, mouthY + 1, mColor, "0.8")
            ));
        }
        if (mouthType == 5) {
            // Flat line
            return string(abi.encodePacked(
                _px(mLeftX + 1, mouthY, mColor, "1"), _px(mLeftX + 2, mouthY, mColor, "1"),
                _px(mLeftX + 3, mouthY, mColor, "1"), _px(mLeftX + 4, mouthY, mColor, "1")
            ));
        }
        if (mouthType == 6) {
            // Pixel smile
            return string(abi.encodePacked(
                _px(mLeftX, mouthY, mColor, "0.7"),
                _px(mLeftX + 1, mouthY + 1, mColor, "1"), _px(mLeftX + 2, mouthY + 1, mColor, "1"),
                _px(mLeftX + 3, mouthY + 1, mColor, "1"),
                _px(mLeftX + 4, mouthY, mColor, "0.7")
            ));
        }
        // mouthType == 7: Zigzag
        return string(abi.encodePacked(
            _px(mLeftX + 1, mouthY, mColor, "1"), _px(mLeftX + 2, mouthY + 1, mColor, "1"),
            _px(mLeftX + 3, mouthY, mColor, "1"), _px(mLeftX + 4, mouthY + 1, mColor, "1")
        ));
    }

    // ============================================================
    //                      HEADWEAR
    // ============================================================

    function _renderHeadwear(uint8 hwType) internal pure returns (string memory) {
        if (hwType == 0) return ""; // None

        string memory c = _headwearColor(hwType);

        if (hwType == 1) {
            // Mohawk - vertical line on top center
            return string(abi.encodePacked(
                _px(11, 1, c, "1"), _px(12, 1, c, "1"),
                _px(11, 2, c, "1"), _px(12, 2, c, "1"),
                _px(11, 3, c, "1"), _px(12, 3, c, "1"),
                _px(11, 4, c, "0.8"), _px(12, 4, c, "0.8")
            ));
        }
        if (hwType == 2) {
            // Antenna array - 3 thin antennas
            return string(abi.encodePacked(
                _px(9, 2, c, "1"), _px(9, 3, c, "1"),
                _px(11, 1, c, "1"), _px(11, 2, c, "1"), _px(11, 3, c, "1"),
                _px(14, 2, c, "1"), _px(14, 3, c, "1"),
                _px(9, 1, "#ff0000", "0.8"), _px(11, 0, "#00ff00", "0.8"), _px(14, 1, "#ff0000", "0.8")
            ));
        }
        if (hwType == 3) {
            // Halo - arc above head
            return string(abi.encodePacked(
                _px(9, 2, c, "1"), _px(10, 1, c, "1"), _px(11, 1, c, "1"),
                _px(12, 1, c, "1"), _px(13, 1, c, "1"), _px(14, 2, c, "1"),
                _px(10, 2, c, "0.4"), _px(11, 2, c, "0.3"), _px(12, 2, c, "0.3"), _px(13, 2, c, "0.4")
            ));
        }
        if (hwType == 4) {
            // Brain jar - dome above head
            return string(abi.encodePacked(
                _px(9, 3, "#88cccc", "0.5"), _px(10, 2, "#88cccc", "0.5"), _px(11, 2, "#88cccc", "0.5"),
                _px(12, 2, "#88cccc", "0.5"), _px(13, 2, "#88cccc", "0.5"), _px(14, 3, "#88cccc", "0.5"),
                _px(10, 3, c, "0.7"), _px(11, 3, c, "0.9"), _px(12, 3, c, "0.9"), _px(13, 3, c, "0.7")
            ));
        }
        if (hwType == 5) {
            // Horns - two diagonal horns
            return string(abi.encodePacked(
                _px(7, 3, c, "1"), _px(8, 4, c, "1"), _px(7, 2, c, "0.8"), _px(6, 1, c, "0.6"),
                _px(16, 3, c, "1"), _px(15, 4, c, "1"), _px(16, 2, c, "0.8"), _px(17, 1, c, "0.6")
            ));
        }
        if (hwType == 6) {
            // Beanie - cap on top
            return string(abi.encodePacked(
                _px(11, 3, "#ff4444", "1"),  // pom pom
                _px(8, 4, c, "1"), _px(9, 4, c, "1"), _px(10, 4, c, "1"), _px(11, 4, c, "1"),
                _px(12, 4, c, "1"), _px(13, 4, c, "1"), _px(14, 4, c, "1"), _px(15, 4, c, "1"),
                _px(8, 5, "#ffffff", "0.4"), _px(9, 5, c, "0.6"), _px(14, 5, c, "0.6"), _px(15, 5, "#ffffff", "0.4")
            ));
        }
        if (hwType == 7) {
            // Crown
            return string(abi.encodePacked(
                _px(8, 2, c, "1"), _px(11, 1, c, "1"), _px(14, 2, c, "1"),
                _px(8, 3, c, "1"), _px(9, 3, c, "1"), _px(10, 3, c, "1"), _px(11, 3, c, "1"),
                _px(12, 3, c, "1"), _px(13, 3, c, "1"), _px(14, 3, c, "1"),
                _px(8, 4, c, "0.8"), _px(9, 4, c, "0.8"), _px(10, 4, c, "0.8"), _px(11, 4, c, "0.8"),
                _px(12, 4, c, "0.8"), _px(13, 4, c, "0.8"), _px(14, 4, c, "0.8"),
                _px(9, 2, "#ff0000", "0.8"), _px(13, 2, "#00ccff", "0.8")
            ));
        }
        if (hwType == 8) {
            // Lightning bolt
            return string(abi.encodePacked(
                _px(12, 0, c, "1"), _px(11, 1, c, "1"), _px(12, 1, c, "1"),
                _px(10, 2, c, "1"), _px(11, 2, c, "1"),
                _px(11, 3, c, "1"), _px(12, 3, c, "1"), _px(13, 3, c, "1"),
                _px(12, 4, c, "0.8"), _px(13, 4, c, "0.8")
            ));
        }
        // hwType == 9: Satellite dish
        return string(abi.encodePacked(
            _px(8, 2, c, "1"), _px(9, 1, c, "1"), _px(10, 1, c, "1"), _px(11, 1, c, "1"),
            _px(12, 2, c, "0.8"), _px(10, 2, c, "0.6"),
            _px(11, 2, c, "0.6"), _px(8, 3, c, "0.5"), _px(8, 4, c, "0.3")
        ));
    }

    // ============================================================
    //                     ACCESSORIES
    // ============================================================

    function _renderAccessory(uint8 accType) internal pure returns (string memory) {
        if (accType == 0) return ""; // None

        string memory c = _accessoryColor(accType);

        if (accType == 1) {
            // Earpiece
            return string(abi.encodePacked(
                _px(6, 9, c, "1"), _px(6, 10, c, "1"), _px(6, 11, c, "0.7")
            ));
        }
        if (accType == 2) {
            // Scar across cheek
            return string(abi.encodePacked(
                _px(14, 8, c, "0.6"), _px(15, 9, c, "0.8"), _px(15, 10, c, "0.8"), _px(14, 11, c, "0.6")
            ));
        }
        if (accType == 3) {
            // VR glasses - wide band
            return string(abi.encodePacked(
                _px(7, 8, c, "1"), _px(8, 8, c, "1"), _px(9, 8, c, "1"), _px(10, 8, c, "1"),
                _px(11, 8, c, "1"), _px(12, 8, c, "1"), _px(13, 8, c, "1"), _px(14, 8, c, "1"),
                _px(15, 8, c, "1"), _px(16, 8, c, "1"),
                _px(9, 9, "#00aaff", "0.6"), _px(10, 9, "#00aaff", "0.6"),
                _px(13, 9, "#00aaff", "0.6"), _px(14, 9, "#00aaff", "0.6")
            ));
        }
        if (accType == 4) {
            // Eye patch
            return string(abi.encodePacked(
                _px(7, 7, c, "1"),
                _px(8, 8, c, "1"), _px(9, 8, c, "1"), _px(10, 8, c, "1"),
                _px(8, 9, c, "1"), _px(9, 9, c, "1"), _px(10, 9, c, "1"),
                _px(8, 10, c, "1"), _px(9, 10, c, "0.7"), _px(10, 10, c, "1"),
                _px(7, 11, c, "1")
            ));
        }
        if (accType == 5) {
            // Neck bolts
            return string(abi.encodePacked(
                _px(7, 16, c, "1"), _px(7, 17, c, "0.7"),
                _px(16, 16, c, "1"), _px(16, 17, c, "0.7")
            ));
        }
        if (accType == 6) {
            // Chain necklace
            return string(abi.encodePacked(
                _px(9, 17, c, "1"), _px(10, 17, c, "0.6"), _px(11, 18, c, "1"),
                _px(12, 18, c, "1"), _px(13, 17, c, "0.6"), _px(14, 17, c, "1"),
                _px(11, 19, "#ffffff", "0.8")  // pendant
            ));
        }
        // accType == 7: Laser sight
        return string(abi.encodePacked(
            _px(7, 9, "#ff0000", "1"),
            _px(6, 9, "#ff0000", "0.8"), _px(5, 9, "#ff0000", "0.6"),
            _px(4, 9, "#ff0000", "0.4"), _px(3, 9, "#ff0000", "0.2"),
            _px(2, 9, "#ff0000", "0.1")
        ));
    }

    // ============================================================
    //                    NAME LABEL
    // ============================================================

    function _renderNameLabel(string memory name, uint8 phase) internal pure returns (string memory) {
        string memory labelColor = phase >= 4 ? "#ffd700" : (phase >= 3 ? "#aaffaa" : "#aaaacc");
        string memory bgOpacity = phase >= 4 ? "0.5" : "0.4";

        return string(abi.encodePacked(
            '<rect x="1" y="21" width="22" height="3" rx="0.5" fill="#000000" opacity="', bgOpacity, '"/>',
            '<text x="12" y="23.2" text-anchor="middle" fill="', labelColor, '" font-family="monospace" font-size="2" font-weight="bold">',
            name, '.claw</text>'
        ));
    }

    // ============================================================
    //                    PIXEL HELPER
    // ============================================================

    /// @dev Create a single pixel rect
    function _px(uint8 x, uint8 y, string memory fill, string memory opacity) internal pure returns (string memory) {
        if (keccak256(bytes(opacity)) == keccak256(bytes("1"))) {
            return string(abi.encodePacked(
                '<rect x="', _u(x), '" y="', _u(y), '" width="1" height="1" fill="', fill, '"/>'
            ));
        }
        return string(abi.encodePacked(
            '<rect x="', _u(x), '" y="', _u(y), '" width="1" height="1" fill="', fill, '" opacity="', opacity, '"/>'
        ));
    }

    /// @dev uint8 to string helper (0-24 range, no library needed for small nums)
    function _u(uint8 v) internal pure returns (string memory) {
        if (v < 10) return string(abi.encodePacked(bytes1(uint8(48 + v))));
        return string(abi.encodePacked(bytes1(uint8(48 + v / 10)), bytes1(uint8(48 + v % 10))));
    }

    // ============================================================
    //                   COLOR LOOKUPS
    // ============================================================

    function _skinColor(uint8 idx) internal pure returns (string memory) {
        if (idx == 0) return "#8a9199";
        if (idx == 1) return "#b87333";
        if (idx == 2) return "#d4a017";
        if (idx == 3) return "#6b8ea8";
        if (idx == 4) return "#2c2c2c";
        if (idx == 5) return "#e0e0e0";
        if (idx == 6) return "#9370db";
        return "#4a8c5c";
    }

    function _skinDark(uint8 idx) internal pure returns (string memory) {
        if (idx == 0) return "#5e666d";
        if (idx == 1) return "#8c5620";
        if (idx == 2) return "#a07810";
        if (idx == 3) return "#4a6e85";
        if (idx == 4) return "#1a1a1a";
        if (idx == 5) return "#b0b0b0";
        if (idx == 6) return "#6a4eb0";
        return "#2e6340";
    }

    function _skinLight(uint8 idx) internal pure returns (string memory) {
        if (idx == 0) return "#aeb5bc";
        if (idx == 1) return "#d49050";
        if (idx == 2) return "#e8c040";
        if (idx == 3) return "#8eb0cc";
        if (idx == 4) return "#454545";
        if (idx == 5) return "#ffffff";
        if (idx == 6) return "#b090f0";
        return "#6ab878";
    }

    function _eyeColor(uint8 t) internal pure returns (string memory) {
        if (t == 0) return "#00ffff";
        if (t == 1) return "#ff4444";
        if (t == 2) return "#ff0000";
        if (t == 3) return "#00ff00";
        if (t == 4) return "#ff6600";
        if (t == 5) return "#00ff41";
        if (t == 6) return "#ff0055";
        if (t == 7) return "#ff1493";
        if (t == 8) return "#00ccff";
        return "#ff4400";
    }

    function _mouthColor(uint8 t) internal pure returns (string memory) {
        if (t == 0) return "#00ffcc";
        if (t == 1) return "#888888";
        if (t == 2) return "#aaaaaa";
        if (t == 3) return "#444444";
        if (t == 4) return "#ffffff";
        if (t == 5) return "#ff6600";
        if (t == 6) return "#ffcc00";
        return "#00aaff";
    }

    function _headwearColor(uint8 t) internal pure returns (string memory) {
        if (t == 1) return "#ff0044";
        if (t == 2) return "#aaaaaa";
        if (t == 3) return "#ffdd00";
        if (t == 4) return "#44ddaa";
        if (t == 5) return "#880000";
        if (t == 6) return "#3366cc";
        if (t == 7) return "#ffd700";
        if (t == 8) return "#ffff00";
        return "#8888aa";
    }

    function _accessoryColor(uint8 t) internal pure returns (string memory) {
        if (t == 1) return "#333333";
        if (t == 2) return "#cc4444";
        if (t == 3) return "#222233";
        if (t == 4) return "#222222";
        if (t == 5) return "#999999";
        if (t == 6) return "#ccaa00";
        return "#ff0000";
    }

    // ============================================================
    //                    ATTRIBUTES JSON
    // ============================================================

    function _buildAttributes(Traits memory t, uint8 phase, uint256 activityCount, string memory name) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '{"trait_type":"Head","value":"', _headName(t.headType), '"},',
            '{"trait_type":"Skin","value":"', _skinName(t.skinColor), '"},',
            '{"trait_type":"Eyes","value":"', _eyeName(t.eyeType), '"},',
            '{"trait_type":"Mouth","value":"', _mouthName(t.mouthType), '"},',
            '{"trait_type":"Headwear","value":"', _headwearName(t.headwear), '"},',
            '{"trait_type":"Accessory","value":"', _accessoryName(t.accessory), '"},',
            '{"trait_type":"Phase","value":"', _phaseName(phase), '"},',
            '{"trait_type":"Activities","value":', activityCount.toString(), '},',
            '{"trait_type":"Domain","value":"', name, '.claw"}'
        ));
    }

    function _headName(uint8 t) internal pure returns (string memory) {
        if (t == 0) return "Round Robot";
        if (t == 1) return "Square Android";
        if (t == 2) return "Tall Cyborg";
        return "Wide Tank";
    }

    function _skinName(uint8 t) internal pure returns (string memory) {
        if (t == 0) return "Steel Gray";
        if (t == 1) return "Copper";
        if (t == 2) return "Gold";
        if (t == 3) return "Chrome Blue";
        if (t == 4) return "Matte Black";
        if (t == 5) return "White";
        if (t == 6) return "Purple Chrome";
        return "Green Circuit";
    }

    function _eyeName(uint8 t) internal pure returns (string memory) {
        if (t == 0) return "Dot";
        if (t == 1) return "Visor";
        if (t == 2) return "Laser Red";
        if (t == 3) return "Glowing Green";
        if (t == 4) return "Cyclops";
        if (t == 5) return "Matrix Code";
        if (t == 6) return "X Eyes";
        if (t == 7) return "Heart Eyes";
        if (t == 8) return "Diamond Eyes";
        return "Fire Eyes";
    }

    function _mouthName(uint8 t) internal pure returns (string memory) {
        if (t == 0) return "LED Smile";
        if (t == 1) return "Speaker Grille";
        if (t == 2) return "Antenna";
        if (t == 3) return "Gas Mask";
        if (t == 4) return "Fangs";
        if (t == 5) return "Flat Line";
        if (t == 6) return "Pixel Smile";
        return "Zigzag";
    }

    function _headwearName(uint8 t) internal pure returns (string memory) {
        if (t == 0) return "None";
        if (t == 1) return "Mohawk";
        if (t == 2) return "Antenna Array";
        if (t == 3) return "Halo";
        if (t == 4) return "Brain Jar";
        if (t == 5) return "Horns";
        if (t == 6) return "Beanie";
        if (t == 7) return "Crown";
        if (t == 8) return "Lightning Bolt";
        return "Satellite Dish";
    }

    function _accessoryName(uint8 t) internal pure returns (string memory) {
        if (t == 0) return "None";
        if (t == 1) return "Earpiece";
        if (t == 2) return "Scar";
        if (t == 3) return "VR Glasses";
        if (t == 4) return "Eye Patch";
        if (t == 5) return "Neck Bolts";
        if (t == 6) return "Chain";
        return "Laser Sight";
    }

    function _phaseName(uint8 p) internal pure returns (string memory) {
        if (p == 0) return "Genesis";
        if (p == 1) return "Awakening";
        if (p == 2) return "Growth";
        if (p == 3) return "Maturity";
        return "Transcendence";
    }

    // ============================================================
    //                    SVG ENCODING
    // ============================================================

    function _svgToDataURI(string memory svg) internal pure returns (string memory) {
        return string(abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(bytes(svg))
        ));
    }
}
