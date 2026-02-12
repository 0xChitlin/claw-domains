// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./libraries/SVGLib.sol";
import "./libraries/ColorLib.sol";
import "./libraries/MathLib.sol";

/// @title ClawRenderer - On-chain generative SVG art engine for .claw domains
/// @notice Produces deterministic, beautiful generative art from wallet address + tokenId + block number
/// @dev All art is computed on-chain with no external dependencies
contract ClawRenderer {
    using Strings for uint256;
    using ColorLib for ColorLib.HSL;

    // Shape types derived from address bytes
    enum ShapeType { HEXAGONAL, SPIRAL, CRYSTALLINE, ORGANIC }

    /// @notice Generate the full SVG for a .claw domain
    /// @param wallet The minter's wallet address
    /// @param tokenId The token ID
    /// @param mintBlock The block number at mint time
    /// @param name The domain name (e.g. "mojochitlin")
    function renderSVG(
        address wallet,
        uint256 tokenId,
        uint256 mintBlock,
        string memory name
    ) external pure returns (string memory) {
        bytes20 addr = bytes20(wallet);

        // Derive shape type from first 4 bytes
        ShapeType shapeType = ShapeType(uint8(addr[0]) % 4);

        // Generate color palette
        ColorLib.HSL[5] memory palette = ColorLib.generatePalette(wallet);

        // Build SVG layers
        string memory svg = SVGLib.svgRoot(
            string(abi.encodePacked(
                _buildDefs(addr, palette, mintBlock),
                _buildBackground(palette, mintBlock),
                _buildCoreGeometry(addr, palette, shapeType, tokenId),
                _buildDetailPatterns(addr, palette, tokenId),
                _buildGlowLayer(palette, addr),
                _buildBorder(palette),
                _buildNameLabel(name, palette)
            ))
        );

        return svg;
    }

    /// @notice Generate complete tokenURI JSON with embedded SVG
    function renderTokenURI(
        address wallet,
        uint256 tokenId,
        uint256 mintBlock,
        string memory name,
        string memory description
    ) external pure returns (string memory) {
        // We call this contract's own renderSVG via internal logic
        bytes20 addr = bytes20(wallet);
        ShapeType shapeType = ShapeType(uint8(addr[0]) % 4);
        ColorLib.HSL[5] memory palette = ColorLib.generatePalette(wallet);

        string memory svg = SVGLib.svgRoot(
            string(abi.encodePacked(
                _buildDefs(addr, palette, mintBlock),
                _buildBackground(palette, mintBlock),
                _buildCoreGeometry(addr, palette, shapeType, tokenId),
                _buildDetailPatterns(addr, palette, tokenId),
                _buildGlowLayer(palette, addr),
                _buildBorder(palette),
                _buildNameLabel(name, palette)
            ))
        );

        string memory imageURI = SVGLib.svgToDataURI(svg);

        string memory shapeStr;
        if (shapeType == ShapeType.HEXAGONAL) shapeStr = "Hexagonal";
        else if (shapeType == ShapeType.SPIRAL) shapeStr = "Spiral";
        else if (shapeType == ShapeType.CRYSTALLINE) shapeStr = "Crystalline";
        else shapeStr = "Organic";

        string memory json = string(abi.encodePacked(
            '{"name":"', name, '.claw",',
            '"description":"', bytes(description).length > 0 ? description : "A living .claw agent identity", '",',
            '"image":"', imageURI, '",',
            '"attributes":[',
            '{"trait_type":"Shape","value":"', shapeStr, '"},',
            '{"trait_type":"Hue","value":"', palette[0].h.toString(), '"},',
            '{"trait_type":"Domain","value":"', name, '.claw"}',
            ']}'
        ));

        return SVGLib.jsonToDataURI(json);
    }

    // ============================================================
    //                    INTERNAL LAYER BUILDERS
    // ============================================================

    /// @dev Build SVG <defs> — filters, gradients, clip paths
    function _buildDefs(
        bytes20 addr,
        ColorLib.HSL[5] memory palette,
        uint256 mintBlock
    ) internal pure returns (string memory) {
        uint256 turbSeed = uint8(addr[3]) * 256 + uint8(addr[4]);
        // Organic distortion filter
        string memory organicFilter = SVGLib.filter("organic",
            string(abi.encodePacked(
                SVGLib.feTurbulence("fractalNoise", "0.015", 3, turbSeed),
                SVGLib.feDisplacementMap(8)
            ))
        );

        // Glow filter
        string memory glowFilter = SVGLib.filter("glow",
            SVGLib.feGaussianBlur("6", "blur")
        );

        // Soft blur filter
        string memory softFilter = SVGLib.filter("soft",
            SVGLib.feGaussianBlur("3", "blur")
        );

        // Background gradient
        uint256 angle = mintBlock % 360;
        string memory bgGrad = SVGLib.linearGradient(
            "bgGrad",
            "0%", "0%", "100%", "100%",
            string(abi.encodePacked(
                SVGLib.stop(0, ColorLib.toHSLString(ColorLib.darken(palette[0], 25)), "1"),
                SVGLib.stop(50, ColorLib.toHSLString(ColorLib.darken(palette[1], 20)), "1"),
                SVGLib.stop(100, ColorLib.toHSLString(ColorLib.darken(palette[2], 22)), "1")
            ))
        );

        // Radial glow gradient
        string memory glowGrad = SVGLib.radialGradient(
            "glowGrad", 200, 200, 180,
            string(abi.encodePacked(
                SVGLib.stop(0, ColorLib.toHSLString(ColorLib.lighten(palette[0], 15)), "0.4"),
                SVGLib.stop(40, ColorLib.toHSLString(palette[1]), "0.2"),
                SVGLib.stop(100, ColorLib.toHSLString(ColorLib.darken(palette[2], 15)), "0")
            ))
        );

        // Core shape gradient
        string memory coreGrad = SVGLib.radialGradient(
            "coreGrad", 200, 200, 120,
            string(abi.encodePacked(
                SVGLib.stop(0, ColorLib.toHSLString(ColorLib.lighten(palette[0], 10)), "0.9"),
                SVGLib.stop(60, ColorLib.toHSLString(palette[1]), "0.6"),
                SVGLib.stop(100, ColorLib.toHSLString(ColorLib.darken(palette[0], 5)), "0.3")
            ))
        );

        return SVGLib.defs(string(abi.encodePacked(
            organicFilter, glowFilter, softFilter, bgGrad, glowGrad, coreGrad
        )));
    }

    /// @dev Layer 1: Background gradient
    function _buildBackground(
        ColorLib.HSL[5] memory palette,
        uint256 mintBlock
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            SVGLib.rect(0, 0, 400, 400, "url(#bgGrad)", ""),
            // Subtle noise overlay
            SVGLib.rect(0, 0, 400, 400, ColorLib.toHSLString(ColorLib.darken(palette[0], 30)),
                'filter="url(#organic)" opacity="0.3"')
        ));
    }

    /// @dev Layer 2: Core geometry — the "seed crystal"
    function _buildCoreGeometry(
        bytes20 addr,
        ColorLib.HSL[5] memory palette,
        ShapeType shapeType,
        uint256 tokenId
    ) internal pure returns (string memory) {
        if (shapeType == ShapeType.HEXAGONAL) {
            return _buildHexagonal(addr, palette, tokenId);
        } else if (shapeType == ShapeType.SPIRAL) {
            return _buildSpiral(addr, palette, tokenId);
        } else if (shapeType == ShapeType.CRYSTALLINE) {
            return _buildCrystalline(addr, palette, tokenId);
        } else {
            return _buildOrganic(addr, palette, tokenId);
        }
    }

    /// @dev Hexagonal geometry — nested hexagons with rotation
    function _buildHexagonal(
        bytes20 addr,
        ColorLib.HSL[5] memory palette,
        uint256 tokenId
    ) internal pure returns (string memory) {
        string memory shapes = "";
        uint256 layers = 3 + (uint8(addr[5]) % 3); // 3-5 layers
        uint256 baseRotation = uint8(addr[6]) % 60;

        for (uint256 i = 0; i < layers; i++) {
            uint256 radius = 140 - (i * 28);
            uint256 rotation = baseRotation + (i * 30);
            uint256 colorIdx = i % 5;

            // Build hexagon points
            string memory points = _hexPoints(200, 200, radius, rotation);

            string memory opacity = i == 0 ? "0.4" : (i == 1 ? "0.5" : "0.6");

            shapes = string(abi.encodePacked(
                shapes,
                '<polygon points="', points,
                '" fill="', ColorLib.toHSLString(palette[colorIdx]),
                '" opacity="', opacity,
                '" stroke="', ColorLib.toHSLString(ColorLib.lighten(palette[colorIdx], 15)),
                '" stroke-width="1"/>'
            ));
        }

        // Central circle
        shapes = string(abi.encodePacked(
            shapes,
            SVGLib.circle(200, 200, 20, "url(#coreGrad)", 'filter="url(#glow)"')
        ));

        return SVGLib.group("", shapes);
    }

    /// @dev Spiral geometry — Fibonacci-like spiral of circles
    function _buildSpiral(
        bytes20 addr,
        ColorLib.HSL[5] memory palette,
        uint256 tokenId
    ) internal pure returns (string memory) {
        string memory shapes = "";
        uint256 numDots = 12 + (uint8(addr[5]) % 12); // 12-23 dots
        uint256 spiralTight = 5 + (uint8(addr[6]) % 4); // tightness

        for (uint256 i = 0; i < numDots; i++) {
            uint256 angle = (i * 137) % 360; // golden angle approximation
            uint256 dist = 20 + (i * spiralTight);
            if (dist > 160) dist = 160;

            uint256 cx = MathLib.circleX(200, dist, angle);
            uint256 cy = MathLib.circleY(200, dist, angle);
            uint256 r = 8 + (uint8(addr[7 + (i % 6)]) % 12);
            uint256 colorIdx = i % 5;

            string memory opacity;
            if (i < numDots / 3) opacity = "0.7";
            else if (i < 2 * numDots / 3) opacity = "0.5";
            else opacity = "0.35";

            shapes = string(abi.encodePacked(
                shapes,
                SVGLib.circle(cx, cy, r,
                    ColorLib.toHSLString(palette[colorIdx]),
                    string(abi.encodePacked('opacity="', opacity, '" filter="url(#soft)"'))
                )
            ));
        }

        // Central glow
        shapes = string(abi.encodePacked(
            shapes,
            SVGLib.circle(200, 200, 30, "url(#coreGrad)", 'filter="url(#glow)" opacity="0.8"')
        ));

        return SVGLib.group("", shapes);
    }

    /// @dev Crystalline geometry — angular faceted shapes
    function _buildCrystalline(
        bytes20 addr,
        ColorLib.HSL[5] memory palette,
        uint256 tokenId
    ) internal pure returns (string memory) {
        string memory shapes = "";
        uint256 numFacets = 4 + (uint8(addr[5]) % 4);
        uint256 baseAngle = uint8(addr[6]) % 90;

        for (uint256 i = 0; i < numFacets; i++) {
            uint256 angle = baseAngle + (i * (360 / numFacets));
            uint256 len = 80 + (uint8(addr[7 + (i % 6)]) % 60);
            uint256 colorIdx = i % 5;

            // Triangle from center to two outer points
            uint256 x1 = MathLib.circleX(200, len, angle);
            uint256 y1 = MathLib.circleY(200, len, angle);
            uint256 x2 = MathLib.circleX(200, len - 20, (angle + 15) % 360);
            uint256 y2 = MathLib.circleY(200, len - 20, (angle + 15) % 360);

            string memory points = string(abi.encodePacked(
                "200,200 ",
                x1.toString(), ",", y1.toString(), " ",
                x2.toString(), ",", y2.toString()
            ));

            shapes = string(abi.encodePacked(
                shapes,
                SVGLib.polygon(points,
                    ColorLib.toHSLString(palette[colorIdx]),
                    string(abi.encodePacked(
                        'opacity="0.5" stroke="',
                        ColorLib.toHSLString(ColorLib.lighten(palette[colorIdx], 20)),
                        '" stroke-width="0.5"'
                    ))
                )
            ));
        }

        // Inner diamond
        shapes = string(abi.encodePacked(
            shapes,
            SVGLib.polygon(
                "200,165 235,200 200,235 165,200",
                "url(#coreGrad)",
                'filter="url(#glow)" opacity="0.8"'
            )
        ));

        return SVGLib.group("", shapes);
    }

    /// @dev Organic geometry — flowing curves and blobs
    function _buildOrganic(
        bytes20 addr,
        ColorLib.HSL[5] memory palette,
        uint256 tokenId
    ) internal pure returns (string memory) {
        string memory shapes = "";
        uint256 numBlobs = 3 + (uint8(addr[5]) % 3);

        for (uint256 i = 0; i < numBlobs; i++) {
            uint256 blobSeed = uint8(addr[6 + i]);
            uint256 cx = 140 + (blobSeed % 120);
            uint256 cy = 140 + (uint8(addr[9 + i]) % 120);
            uint256 rx = 40 + (blobSeed % 50);
            uint256 ry = 40 + (uint8(addr[12 + (i % 4)]) % 50);
            uint256 colorIdx = i % 5;

            shapes = string(abi.encodePacked(
                shapes,
                '<ellipse cx="', cx.toString(),
                '" cy="', cy.toString(),
                '" rx="', rx.toString(),
                '" ry="', ry.toString(),
                '" fill="', ColorLib.toHSLString(palette[colorIdx]),
                '" opacity="0.4" filter="url(#organic)"/>'
            ));
        }

        // Organic center blob
        shapes = string(abi.encodePacked(
            shapes,
            '<ellipse cx="200" cy="200" rx="50" ry="45" fill="url(#coreGrad)" filter="url(#organic)" opacity="0.7"/>'
        ));

        return SVGLib.group("", shapes);
    }

    /// @dev Layer 3: Detail patterns — small repeating elements
    function _buildDetailPatterns(
        bytes20 addr,
        ColorLib.HSL[5] memory palette,
        uint256 tokenId
    ) internal pure returns (string memory) {
        string memory shapes = "";
        uint256 numDetails = 6 + (uint8(addr[15]) % 8); // 6-13 detail elements

        for (uint256 i = 0; i < numDetails; i++) {
            uint256 seed = uint256(keccak256(abi.encodePacked(addr, tokenId, i)));

            uint256 x = 40 + (seed % 320);
            uint256 y = 40 + ((seed >> 8) % 320);
            uint256 size = 2 + ((seed >> 16) % 6);
            uint256 colorIdx = (seed >> 24) % 5;

            // Alternate between tiny circles and diamonds
            if (i % 3 == 0) {
                shapes = string(abi.encodePacked(
                    shapes,
                    SVGLib.circle(x, y, size,
                        ColorLib.toHSLString(ColorLib.lighten(palette[colorIdx], 20)),
                        'opacity="0.6"')
                ));
            } else if (i % 3 == 1) {
                // Tiny diamond
                string memory points = string(abi.encodePacked(
                    x.toString(), ",", (y > size ? y - size : 0).toString(), " ",
                    (x + size).toString(), ",", y.toString(), " ",
                    x.toString(), ",", (y + size).toString(), " ",
                    (x > size ? x - size : 0).toString(), ",", y.toString()
                ));
                shapes = string(abi.encodePacked(
                    shapes,
                    SVGLib.polygon(points,
                        ColorLib.toHSLString(ColorLib.lighten(palette[colorIdx], 25)),
                        'opacity="0.5"')
                ));
            } else {
                // Tiny ring
                shapes = string(abi.encodePacked(
                    shapes,
                    SVGLib.circle(x, y, size,
                        "none",
                        string(abi.encodePacked(
                            'stroke="',
                            ColorLib.toHSLString(ColorLib.lighten(palette[colorIdx], 15)),
                            '" stroke-width="1" opacity="0.4"'
                        )))
                ));
            }
        }

        return SVGLib.group("", shapes);
    }

    /// @dev Layer 4: Glow / energy effect
    function _buildGlowLayer(
        ColorLib.HSL[5] memory palette,
        bytes20 addr
    ) internal pure returns (string memory) {
        // Central radial glow
        string memory glow = SVGLib.circle(200, 200, 160, "url(#glowGrad)", "");

        // Secondary glow offset based on address
        uint256 gx = 150 + (uint8(addr[16]) % 100);
        uint256 gy = 150 + (uint8(addr[17]) % 100);

        glow = string(abi.encodePacked(
            glow,
            SVGLib.circle(gx, gy, 80,
                ColorLib.toHSLString(ColorLib.lighten(palette[3], 10)),
                'opacity="0.15" filter="url(#glow)"')
        ));

        return glow;
    }

    /// @dev Layer 5: Border / frame
    function _buildBorder(
        ColorLib.HSL[5] memory palette
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            // Outer frame
            '<rect x="4" y="4" width="392" height="392" rx="12" ry="12" fill="none" stroke="',
            ColorLib.toHSLString(ColorLib.lighten(palette[4], 10)),
            '" stroke-width="1.5" opacity="0.5"/>',
            // Inner subtle frame
            '<rect x="12" y="12" width="376" height="376" rx="8" ry="8" fill="none" stroke="',
            ColorLib.toHSLString(ColorLib.lighten(palette[4], 15)),
            '" stroke-width="0.5" opacity="0.3"/>'
        ));
    }

    /// @dev Name label at the bottom
    function _buildNameLabel(
        string memory name,
        ColorLib.HSL[5] memory palette
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            // Background pill for text
            '<rect x="120" y="365" width="160" height="24" rx="12" fill="',
            ColorLib.toHSLString(ColorLib.darken(palette[0], 25)),
            '" opacity="0.7"/>',
            // Domain name text
            SVGLib.text(200, 382, string(abi.encodePacked(name, ".claw")),
                string(abi.encodePacked(
                    'fill="', ColorLib.toHSLString(ColorLib.lighten(palette[4], 25)),
                    '" font-family="monospace" font-size="11" text-anchor="middle"'
                ))
            )
        ));
    }

    // ============================================================
    //                       GEOMETRY HELPERS
    // ============================================================

    /// @dev Generate hexagon vertex points string
    function _hexPoints(uint256 cx, uint256 cy, uint256 radius, uint256 startAngle)
        internal pure returns (string memory)
    {
        string memory points = "";
        for (uint256 i = 0; i < 6; i++) {
            uint256 angle = startAngle + (i * 60);
            uint256 px = MathLib.circleX(cx, radius, angle);
            uint256 py = MathLib.circleY(cy, radius, angle);
            if (i > 0) {
                points = string(abi.encodePacked(points, " "));
            }
            points = string(abi.encodePacked(points, px.toString(), ",", py.toString()));
        }
        return points;
    }
}
