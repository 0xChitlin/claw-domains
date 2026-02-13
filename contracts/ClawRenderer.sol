// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./libraries/SVGLib.sol";
import "./libraries/ColorLib.sol";
import "./libraries/MathLib.sol";

/// @title ClawRenderer - On-chain generative SVG art engine for .claw domains
/// @notice Produces deterministic, beautiful generative art from wallet address + tokenId + block number
/// @dev All art is computed on-chain with no external dependencies. Supports evolution phases 0-4.
contract ClawRenderer {
    using Strings for uint256;
    using ColorLib for ColorLib.HSL;

    // Shape types derived from address bytes
    enum ShapeType { HEXAGONAL, SPIRAL, CRYSTALLINE, ORGANIC }

    /// @notice Generate the full SVG for a .claw domain (base version, phase 0)
    function renderSVG(
        address wallet,
        uint256 tokenId,
        uint256 mintBlock,
        string memory name
    ) external pure returns (string memory) {
        return renderEvolvedSVG(wallet, tokenId, mintBlock, name, 0, 0);
    }

    /// @notice Generate evolution-aware SVG
    function renderEvolvedSVG(
        address wallet,
        uint256 tokenId,
        uint256 mintBlock,
        string memory name,
        uint256 phase,
        uint256 activityCount
    ) public pure returns (string memory) {
        bytes20 addr = bytes20(wallet);
        ShapeType shapeType = ShapeType(uint8(addr[0]) % 4);
        ColorLib.HSL[5] memory palette = ColorLib.generatePalette(wallet);

        string memory svg = SVGLib.svgRoot(
            string(abi.encodePacked(
                _buildDefs(addr, palette, mintBlock, phase),
                _buildBackground(palette, phase),
                _buildCoreGeometry(addr, palette, shapeType, tokenId),
                phase >= 2 ? _buildExtraLayers(addr, palette, tokenId, phase) : "",
                _buildDetailPatterns(addr, palette, tokenId),
                _buildGlowLayer(palette, addr, phase),
                phase >= 4 ? _buildParticles(addr, palette, tokenId) : "",
                _buildBorder(palette, phase),
                phase >= 4 ? _buildAnimations(palette) : "",
                _buildNameLabel(name, palette, phase, activityCount)
            ))
        );

        return svg;
    }

    /// @notice Generate complete tokenURI JSON with embedded SVG (base version)
    function renderTokenURI(
        address wallet,
        uint256 tokenId,
        uint256 mintBlock,
        string memory name,
        string memory description
    ) external pure returns (string memory) {
        return renderEvolvedTokenURI(wallet, tokenId, mintBlock, name, description, 0, 0);
    }

    /// @notice Generate evolution-aware tokenURI JSON
    function renderEvolvedTokenURI(
        address wallet,
        uint256 tokenId,
        uint256 mintBlock,
        string memory name,
        string memory description,
        uint256 phase,
        uint256 activityCount
    ) public pure returns (string memory) {
        bytes20 addr = bytes20(wallet);
        ShapeType shapeType = ShapeType(uint8(addr[0]) % 4);

        string memory svg = renderEvolvedSVG(wallet, tokenId, mintBlock, name, phase, activityCount);
        string memory imageURI = SVGLib.svgToDataURI(svg);

        string memory shapeStr;
        if (shapeType == ShapeType.HEXAGONAL) shapeStr = "Hexagonal";
        else if (shapeType == ShapeType.SPIRAL) shapeStr = "Spiral";
        else if (shapeType == ShapeType.CRYSTALLINE) shapeStr = "Crystalline";
        else shapeStr = "Organic";

        string memory phaseStr;
        if (phase == 0) phaseStr = "Genesis";
        else if (phase == 1) phaseStr = "Awakening";
        else if (phase == 2) phaseStr = "Growth";
        else if (phase == 3) phaseStr = "Maturity";
        else phaseStr = "Transcendence";

        ColorLib.HSL[5] memory palette = ColorLib.generatePalette(wallet);

        string memory json = string(abi.encodePacked(
            '{"name":"', name, '.claw",',
            '"description":"', bytes(description).length > 0 ? description : "A living .claw agent identity", '",',
            '"image":"', imageURI, '",',
            '"attributes":[',
            '{"trait_type":"Shape","value":"', shapeStr, '"},',
            '{"trait_type":"Hue","value":"', palette[0].h.toString(), '"},',
            '{"trait_type":"Phase","value":"', phaseStr, '"},',
            '{"trait_type":"Activities","value":', activityCount.toString(), '},',
            '{"trait_type":"Domain","value":"', name, '.claw"}',
            ']}'
        ));

        return SVGLib.jsonToDataURI(json);
    }

    // ============================================================
    //                    INTERNAL LAYER BUILDERS
    // ============================================================

    /// @dev Build SVG <defs>
    function _buildDefs(
        bytes20 addr,
        ColorLib.HSL[5] memory palette,
        uint256 mintBlock,
        uint256 phase
    ) internal pure returns (string memory) {
        uint256 turbSeed = uint8(addr[3]) * 256 + uint8(addr[4]);

        string memory turbFreq = phase >= 3 ? "0.025" : "0.015";
        uint256 turbOctaves = phase >= 3 ? 5 : 3;
        uint256 dispScale = phase >= 3 ? 14 : 8;

        string memory organicFilter = SVGLib.filter("organic",
            string(abi.encodePacked(
                SVGLib.feTurbulence("fractalNoise", turbFreq, turbOctaves, turbSeed),
                SVGLib.feDisplacementMap(dispScale)
            ))
        );

        string memory glowBlur = phase == 0 ? "6" : (phase == 1 ? "10" : (phase == 2 ? "14" : (phase == 3 ? "18" : "24")));
        string memory glowFilter = SVGLib.filter("glow",
            SVGLib.feGaussianBlur(glowBlur, "blur")
        );

        string memory softFilter = SVGLib.filter("soft",
            SVGLib.feGaussianBlur("3", "blur")
        );

        string memory auraFilter = "";
        if (phase >= 1) {
            string memory auraBlur = phase == 1 ? "12" : (phase == 2 ? "20" : (phase == 3 ? "28" : "35"));
            auraFilter = SVGLib.filter("aura",
                SVGLib.feGaussianBlur(auraBlur, "blur")
            );
        }

        string memory complexFilter = "";
        if (phase >= 3) {
            complexFilter = SVGLib.filter("complex",
                string(abi.encodePacked(
                    SVGLib.feTurbulence("turbulence", "0.04", 6, turbSeed + 42),
                    SVGLib.feDisplacementMap(20)
                ))
            );
        }

        string memory bgGrad = SVGLib.linearGradient(
            "bgGrad",
            "0%", "0%", "100%", "100%",
            string(abi.encodePacked(
                SVGLib.stop(0, ColorLib.toHSLString(ColorLib.darken(palette[0], 25)), "1"),
                SVGLib.stop(50, ColorLib.toHSLString(ColorLib.darken(palette[1], 20)), "1"),
                SVGLib.stop(100, ColorLib.toHSLString(ColorLib.darken(palette[2], 22)), "1")
            ))
        );

        string memory innerOpacity = phase <= 1 ? "0.4" : (phase == 2 ? "0.5" : (phase == 3 ? "0.6" : "0.8"));
        string memory glowGrad = SVGLib.radialGradient(
            "glowGrad", 200, 200, 180,
            string(abi.encodePacked(
                SVGLib.stop(0, ColorLib.toHSLString(ColorLib.lighten(palette[0], 15)), innerOpacity),
                SVGLib.stop(40, ColorLib.toHSLString(palette[1]), "0.2"),
                SVGLib.stop(100, ColorLib.toHSLString(ColorLib.darken(palette[2], 15)), "0")
            ))
        );

        string memory coreGrad = SVGLib.radialGradient(
            "coreGrad", 200, 200, 120,
            string(abi.encodePacked(
                SVGLib.stop(0, ColorLib.toHSLString(ColorLib.lighten(palette[0], 10)), "0.9"),
                SVGLib.stop(60, ColorLib.toHSLString(palette[1]), "0.6"),
                SVGLib.stop(100, ColorLib.toHSLString(ColorLib.darken(palette[0], 5)), "0.3")
            ))
        );

        string memory pulseGrad = "";
        if (phase >= 4) {
            pulseGrad = SVGLib.radialGradient(
                "pulseGrad", 200, 200, 150,
                string(abi.encodePacked(
                    SVGLib.stop(0, ColorLib.toHSLString(ColorLib.lighten(palette[3], 20)), "0.7"),
                    SVGLib.stop(50, ColorLib.toHSLString(ColorLib.lighten(palette[0], 15)), "0.3"),
                    SVGLib.stop(100, ColorLib.toHSLString(palette[2]), "0")
                ))
            );
        }

        return SVGLib.defs(string(abi.encodePacked(
            organicFilter, glowFilter, softFilter, auraFilter, complexFilter,
            bgGrad, glowGrad, coreGrad, pulseGrad
        )));
    }

    /// @dev Background
    function _buildBackground(
        ColorLib.HSL[5] memory palette,
        uint256 phase
    ) internal pure returns (string memory) {
        string memory bg = string(abi.encodePacked(
            SVGLib.rect(0, 0, 400, 400, "url(#bgGrad)", ""),
            SVGLib.rect(0, 0, 400, 400, ColorLib.toHSLString(ColorLib.darken(palette[0], 30)),
                'filter="url(#organic)" opacity="0.3"')
        ));

        if (phase >= 3) {
            bg = string(abi.encodePacked(
                bg,
                SVGLib.circle(100, 100, 200,
                    ColorLib.toHSLString(ColorLib.lighten(palette[3], 10)),
                    'opacity="0.08" filter="url(#glow)"'),
                SVGLib.circle(300, 300, 180,
                    ColorLib.toHSLString(ColorLib.lighten(palette[4], 10)),
                    'opacity="0.06" filter="url(#glow)"')
            ));
        }

        return bg;
    }

    /// @dev Core geometry
    function _buildCoreGeometry(
        bytes20 addr,
        ColorLib.HSL[5] memory palette,
        ShapeType shapeType,
        uint256 tokenId
    ) internal pure returns (string memory) {
        if (shapeType == ShapeType.HEXAGONAL) {
            return _buildHexagonal(addr, palette);
        } else if (shapeType == ShapeType.SPIRAL) {
            return _buildSpiral(addr, palette);
        } else if (shapeType == ShapeType.CRYSTALLINE) {
            return _buildCrystalline(addr, palette);
        } else {
            return _buildOrganic(addr, palette);
        }
    }

    /// @dev Phase 2+ extra shape layers
    function _buildExtraLayers(
        bytes20 addr,
        ColorLib.HSL[5] memory palette,
        uint256 tokenId,
        uint256 phase
    ) internal pure returns (string memory) {
        string memory layers = "";
        uint256 numExtra = phase >= 4 ? 4 : (phase >= 3 ? 3 : 2);

        for (uint256 i = 0; i < numExtra; i++) {
            uint256 seed = uint256(keccak256(abi.encodePacked(addr, tokenId, "extra", i)));
            uint256 rotation = (seed % 360);
            uint256 radius = 60 + (seed >> 8) % 80;
            uint256 cx = 130 + (seed >> 16) % 140;
            uint256 cy = 130 + (seed >> 24) % 140;
            uint256 colorIdx = (seed >> 32) % 5;

            string memory opacity = phase >= 3 ? "0.25" : "0.18";
            string memory filterAttr = phase >= 3 ? ' filter="url(#complex)"' : ' filter="url(#soft)"';

            string memory points = _hexPoints(cx, cy, radius, rotation);
            layers = string(abi.encodePacked(
                layers,
                '<polygon points="', points,
                '" fill="', ColorLib.toHSLString(ColorLib.lighten(palette[colorIdx], 10)),
                '" opacity="', opacity,
                '" stroke="', ColorLib.toHSLString(ColorLib.lighten(palette[colorIdx], 25)),
                '" stroke-width="0.5"', filterAttr, '/>'
            ));
        }

        if (phase >= 3) {
            layers = string(abi.encodePacked(
                layers,
                SVGLib.circle(200, 200, 130, "none",
                    string(abi.encodePacked(
                        'stroke="', ColorLib.toHSLString(ColorLib.lighten(palette[2], 20)),
                        '" stroke-width="1" opacity="0.3"'
                    ))
                ),
                SVGLib.circle(200, 200, 155, "none",
                    string(abi.encodePacked(
                        'stroke="', ColorLib.toHSLString(ColorLib.lighten(palette[3], 15)),
                        '" stroke-width="0.5" opacity="0.2"'
                    ))
                )
            ));
        }

        return SVGLib.group("", layers);
    }

    /// @dev Hexagonal
    function _buildHexagonal(
        bytes20 addr,
        ColorLib.HSL[5] memory palette
    ) internal pure returns (string memory) {
        string memory shapes = "";
        uint256 layers = 3 + (uint8(addr[5]) % 3);
        uint256 baseRotation = uint8(addr[6]) % 60;

        for (uint256 i = 0; i < layers; i++) {
            uint256 radius = 140 - (i * 28);
            uint256 rotation = baseRotation + (i * 30);
            uint256 colorIdx = i % 5;

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

        shapes = string(abi.encodePacked(
            shapes,
            SVGLib.circle(200, 200, 20, "url(#coreGrad)", 'filter="url(#glow)"')
        ));

        return SVGLib.group("", shapes);
    }

    /// @dev Spiral
    function _buildSpiral(
        bytes20 addr,
        ColorLib.HSL[5] memory palette
    ) internal pure returns (string memory) {
        string memory shapes = "";
        uint256 numDots = 12 + (uint8(addr[5]) % 12);
        uint256 spiralTight = 5 + (uint8(addr[6]) % 4);

        for (uint256 i = 0; i < numDots; i++) {
            uint256 angle = (i * 137) % 360;
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

        shapes = string(abi.encodePacked(
            shapes,
            SVGLib.circle(200, 200, 30, "url(#coreGrad)", 'filter="url(#glow)" opacity="0.8"')
        ));

        return SVGLib.group("", shapes);
    }

    /// @dev Crystalline
    function _buildCrystalline(
        bytes20 addr,
        ColorLib.HSL[5] memory palette
    ) internal pure returns (string memory) {
        string memory shapes = "";
        uint256 numFacets = 4 + (uint8(addr[5]) % 4);
        uint256 baseAngle = uint8(addr[6]) % 90;

        for (uint256 i = 0; i < numFacets; i++) {
            uint256 angle = baseAngle + (i * (360 / numFacets));
            uint256 len = 80 + (uint8(addr[7 + (i % 6)]) % 60);
            uint256 colorIdx = i % 5;

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

    /// @dev Organic
    function _buildOrganic(
        bytes20 addr,
        ColorLib.HSL[5] memory palette
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

        shapes = string(abi.encodePacked(
            shapes,
            '<ellipse cx="200" cy="200" rx="50" ry="45" fill="url(#coreGrad)" filter="url(#organic)" opacity="0.7"/>'
        ));

        return SVGLib.group("", shapes);
    }

    /// @dev Detail patterns
    function _buildDetailPatterns(
        bytes20 addr,
        ColorLib.HSL[5] memory palette,
        uint256 tokenId
    ) internal pure returns (string memory) {
        string memory shapes = "";
        uint256 numDetails = 6 + (uint8(addr[15]) % 8);

        for (uint256 i = 0; i < numDetails; i++) {
            uint256 seed = uint256(keccak256(abi.encodePacked(addr, tokenId, i)));

            uint256 x = 40 + (seed % 320);
            uint256 y = 40 + ((seed >> 8) % 320);
            uint256 size = 2 + ((seed >> 16) % 6);
            uint256 colorIdx = (seed >> 24) % 5;

            if (i % 3 == 0) {
                shapes = string(abi.encodePacked(
                    shapes,
                    SVGLib.circle(x, y, size,
                        ColorLib.toHSLString(ColorLib.lighten(palette[colorIdx], 20)),
                        'opacity="0.6"')
                ));
            } else if (i % 3 == 1) {
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

    /// @dev Glow layer — scales with phase
    function _buildGlowLayer(
        ColorLib.HSL[5] memory palette,
        bytes20 addr,
        uint256 phase
    ) internal pure returns (string memory) {
        string memory glow = SVGLib.circle(200, 200, 160, "url(#glowGrad)", "");

        uint256 gx = 150 + (uint8(addr[16]) % 100);
        uint256 gy = 150 + (uint8(addr[17]) % 100);

        glow = string(abi.encodePacked(
            glow,
            SVGLib.circle(gx, gy, 80,
                ColorLib.toHSLString(ColorLib.lighten(palette[3], 10)),
                'opacity="0.15" filter="url(#glow)"')
        ));

        if (phase >= 1) {
            string memory auraOpacity = phase == 1 ? "0.15" : (phase == 2 ? "0.2" : (phase == 3 ? "0.3" : "0.4"));
            uint256 auraRadius = 80 + (phase * 20);
            glow = string(abi.encodePacked(
                glow,
                SVGLib.circle(200, 200, auraRadius,
                    ColorLib.toHSLString(ColorLib.lighten(palette[0], 20)),
                    string(abi.encodePacked('opacity="', auraOpacity, '" filter="url(#aura)"'))
                )
            ));
        }

        if (phase >= 4) {
            glow = string(abi.encodePacked(
                glow,
                SVGLib.circle(200, 200, 170, "url(#pulseGrad)", 'opacity="0.3" filter="url(#glow)"')
            ));
        }

        return glow;
    }

    /// @dev Phase 4: Particle dots
    function _buildParticles(
        bytes20 addr,
        ColorLib.HSL[5] memory palette,
        uint256 tokenId
    ) internal pure returns (string memory) {
        string memory particles = "";
        uint256 numParticles = 12;

        for (uint256 i = 0; i < numParticles; i++) {
            uint256 seed = uint256(keccak256(abi.encodePacked(addr, tokenId, "particle", i)));
            uint256 angle = (i * 30) + (seed % 15);
            uint256 dist = 100 + (seed >> 8) % 70;
            uint256 px = MathLib.circleX(200, dist, angle);
            uint256 py = MathLib.circleY(200, dist, angle);
            uint256 colorIdx = i % 5;
            uint256 pSize = 2 + (seed >> 16) % 4;

            particles = string(abi.encodePacked(
                particles,
                SVGLib.circle(px, py, pSize,
                    ColorLib.toHSLString(ColorLib.lighten(palette[colorIdx], 30)),
                    'opacity="0.8" filter="url(#glow)"'
                )
            ));
        }

        return SVGLib.group("", particles);
    }

    /// @dev Border — evolves with phase
    function _buildBorder(
        ColorLib.HSL[5] memory palette,
        uint256 phase
    ) internal pure returns (string memory) {
        string memory borderOpacity = phase >= 3 ? "0.7" : "0.5";
        string memory borderWidth = phase >= 4 ? "2.5" : "1.5";

        string memory border = string(abi.encodePacked(
            '<rect x="4" y="4" width="392" height="392" rx="12" ry="12" fill="none" stroke="',
            ColorLib.toHSLString(ColorLib.lighten(palette[4], 10)),
            '" stroke-width="', borderWidth, '" opacity="', borderOpacity, '"/>',
            '<rect x="12" y="12" width="376" height="376" rx="8" ry="8" fill="none" stroke="',
            ColorLib.toHSLString(ColorLib.lighten(palette[4], 15)),
            '" stroke-width="0.5" opacity="0.3"/>'
        ));

        if (phase >= 4) {
            border = string(abi.encodePacked(
                border,
                '<rect x="2" y="2" width="396" height="396" rx="14" ry="14" fill="none" stroke="',
                ColorLib.toHSLString(ColorLib.lighten(palette[0], 25)),
                '" stroke-width="1" opacity="0.5" filter="url(#glow)"/>'
            ));
        }

        return border;
    }

    /// @dev Phase 4: Animations
    function _buildAnimations(
        ColorLib.HSL[5] memory palette
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<circle cx="200" cy="200" r="90" fill="none" stroke="',
            ColorLib.toHSLString(ColorLib.lighten(palette[1], 20)),
            '" stroke-width="0.8" opacity="0.4" stroke-dasharray="8 12">',
            '<animateTransform attributeName="transform" type="rotate" from="0 200 200" to="360 200 200" dur="30s" repeatCount="indefinite"/>',
            '</circle>',
            '<circle cx="200" cy="200" r="40" fill="',
            ColorLib.toHSLString(ColorLib.lighten(palette[0], 25)),
            '" opacity="0.15" filter="url(#glow)">',
            '<animate attributeName="r" values="35;50;35" dur="4s" repeatCount="indefinite"/>',
            '<animate attributeName="opacity" values="0.1;0.25;0.1" dur="4s" repeatCount="indefinite"/>',
            '</circle>',
            '<circle cx="200" cy="200" r="160" fill="none" stroke="',
            ColorLib.toHSLString(ColorLib.lighten(palette[3], 15)),
            '" stroke-width="0.5" opacity="0.3" stroke-dasharray="4 20">',
            '<animateTransform attributeName="transform" type="rotate" from="360 200 200" to="0 200 200" dur="45s" repeatCount="indefinite"/>',
            '</circle>'
        ));
    }

    /// @dev Name label with phase dots
    function _buildNameLabel(
        string memory name,
        ColorLib.HSL[5] memory palette,
        uint256 phase,
        uint256 activityCount
    ) internal pure returns (string memory) {
        string memory phaseDots = "";
        for (uint256 i = 0; i < 5; i++) {
            string memory dotFill;
            if (i <= phase) {
                dotFill = ColorLib.toHSLString(ColorLib.lighten(palette[0], 25));
            } else {
                dotFill = ColorLib.toHSLString(ColorLib.darken(palette[4], 15));
            }
            uint256 dotX = 175 + (i * 12);
            phaseDots = string(abi.encodePacked(
                phaseDots,
                SVGLib.circle(dotX, 358, 3, dotFill,
                    i <= phase ? 'opacity="0.9"' : 'opacity="0.3"')
            ));
        }

        return string(abi.encodePacked(
            phaseDots,
            '<rect x="120" y="365" width="160" height="24" rx="12" fill="',
            ColorLib.toHSLString(ColorLib.darken(palette[0], 25)),
            '" opacity="0.7"/>',
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
