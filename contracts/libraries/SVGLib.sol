// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/// @title SVGLib - SVG string building utilities
/// @notice Helpers for constructing valid SVG markup on-chain
library SVGLib {
    using Strings for uint256;

    /// @dev Wrap content in an SVG root element (400x400 viewBox)
    function svgRoot(string memory content) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400" width="400" height="400">',
            content,
            '</svg>'
        ));
    }

    /// @dev Create a <defs> block
    function defs(string memory content) internal pure returns (string memory) {
        return string(abi.encodePacked('<defs>', content, '</defs>'));
    }

    /// @dev Create a <g> group with optional transform
    function group(string memory transform, string memory content) internal pure returns (string memory) {
        if (bytes(transform).length == 0) {
            return string(abi.encodePacked('<g>', content, '</g>'));
        }
        return string(abi.encodePacked('<g transform="', transform, '">', content, '</g>'));
    }

    /// @dev Create a circle element
    function circle(
        uint256 cx, uint256 cy, uint256 r,
        string memory fill, string memory extra
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<circle cx="', cx.toString(),
            '" cy="', cy.toString(),
            '" r="', r.toString(),
            '" fill="', fill, '" ', extra, '/>'
        ));
    }

    /// @dev Create a rect element
    function rect(
        uint256 x, uint256 y, uint256 w, uint256 h,
        string memory fill, string memory extra
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<rect x="', x.toString(),
            '" y="', y.toString(),
            '" width="', w.toString(),
            '" height="', h.toString(),
            '" fill="', fill, '" ', extra, '/>'
        ));
    }

    /// @dev Create a linear gradient definition
    function linearGradient(
        string memory id,
        string memory x1, string memory y1,
        string memory x2, string memory y2,
        string memory stops
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<linearGradient id="', id,
            '" x1="', x1, '" y1="', y1,
            '" x2="', x2, '" y2="', y2, '">',
            stops,
            '</linearGradient>'
        ));
    }

    /// @dev Create a radial gradient definition
    function radialGradient(
        string memory id,
        uint256 cx, uint256 cy, uint256 r,
        string memory stops
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<radialGradient id="', id,
            '" cx="', cx.toString(),
            '" cy="', cy.toString(),
            '" r="', r.toString(),
            '" gradientUnits="userSpaceOnUse">',
            stops,
            '</radialGradient>'
        ));
    }

    /// @dev Create a gradient stop
    function stop(uint256 offset, string memory color, string memory opacity) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<stop offset="', offset.toString(),
            '%" stop-color="', color,
            '" stop-opacity="', opacity, '"/>'
        ));
    }

    /// @dev Create a path element
    function path(string memory d, string memory fill, string memory extra) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<path d="', d, '" fill="', fill, '" ', extra, '/>'
        ));
    }

    /// @dev Create a polygon element
    function polygon(string memory points, string memory fill, string memory extra) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<polygon points="', points, '" fill="', fill, '" ', extra, '/>'
        ));
    }

    /// @dev Create an SVG filter element
    function filter(string memory id, string memory content) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<filter id="', id, '">', content, '</filter>'
        ));
    }

    /// @dev feTurbulence element
    function feTurbulence(
        string memory turbType,
        string memory baseFreq,
        uint256 numOctaves,
        uint256 seed
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<feTurbulence type="', turbType,
            '" baseFrequency="', baseFreq,
            '" numOctaves="', numOctaves.toString(),
            '" seed="', seed.toString(),
            '" result="turb"/>'
        ));
    }

    /// @dev feDisplacementMap element
    function feDisplacementMap(uint256 scale) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<feDisplacementMap in="SourceGraphic" in2="turb" scale="',
            scale.toString(),
            '" xChannelSelector="R" yChannelSelector="G"/>'
        ));
    }

    /// @dev feGaussianBlur element
    function feGaussianBlur(string memory stdDev, string memory result) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<feGaussianBlur stdDeviation="', stdDev, '" result="', result, '"/>'
        ));
    }

    /// @dev Text element
    function text(
        uint256 x, uint256 y,
        string memory content,
        string memory style
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<text x="', x.toString(),
            '" y="', y.toString(),
            '" ', style, '>',
            content,
            '</text>'
        ));
    }

    /// @dev Encode SVG as base64 data URI
    function svgToDataURI(string memory svg) internal pure returns (string memory) {
        return string(abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(bytes(svg))
        ));
    }

    /// @dev Encode JSON metadata as base64 data URI
    function jsonToDataURI(string memory json) internal pure returns (string memory) {
        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        ));
    }

    /// @dev uint to signed string (for SVG coordinates that might be negative)
    function intToString(int256 value) internal pure returns (string memory) {
        if (value >= 0) {
            return uint256(value).toString();
        }
        return string(abi.encodePacked("-", uint256(-value).toString()));
    }
}
