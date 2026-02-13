// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title PunkData - Pixel data and trait definitions for CryptoPunks-style characters
/// @notice Provides packed pixel data for head shapes, eyes, mouths, headwear, and accessories
/// @dev Each pixel position is encoded as (x, y, paletteIndex) triplets packed into bytes
library PunkData {
    // ============================================================
    //                    COLOR PALETTES
    // ============================================================

    /// @dev Skin/metal colors (8 options)
    function getSkinColor(uint8 idx) internal pure returns (string memory) {
        if (idx == 0) return "#8a9199"; // Steel gray
        if (idx == 1) return "#b87333"; // Copper
        if (idx == 2) return "#d4a017"; // Gold
        if (idx == 3) return "#6b8ea8"; // Chrome blue
        if (idx == 4) return "#2c2c2c"; // Matte black
        if (idx == 5) return "#e0e0e0"; // White
        if (idx == 6) return "#9370db"; // Purple chrome
        return "#4a8c5c";               // Green circuit (idx == 7)
    }

    /// @dev Darker shade of skin (for outlines/shadows)
    function getSkinDark(uint8 idx) internal pure returns (string memory) {
        if (idx == 0) return "#5e666d";
        if (idx == 1) return "#8c5620";
        if (idx == 2) return "#a07810";
        if (idx == 3) return "#4a6e85";
        if (idx == 4) return "#1a1a1a";
        if (idx == 5) return "#b0b0b0";
        if (idx == 6) return "#6a4eb0";
        return "#2e6340";
    }

    /// @dev Lighter shade of skin (for highlights)
    function getSkinLight(uint8 idx) internal pure returns (string memory) {
        if (idx == 0) return "#aeb5bc";
        if (idx == 1) return "#d49050";
        if (idx == 2) return "#e8c040";
        if (idx == 3) return "#8eb0cc";
        if (idx == 4) return "#454545";
        if (idx == 5) return "#ffffff";
        if (idx == 6) return "#b090f0";
        return "#6ab878";
    }

    /// @dev Background colors per evolution phase
    function getBackground(uint8 phase) internal pure returns (string memory) {
        if (phase == 0) return "#1a1a2e"; // Dark gray - dormant
        if (phase == 1) return "#16213e"; // Deep blue - awakening
        if (phase == 2) return "#1a1a3e"; // Dark purple - growing
        if (phase == 3) return "#0a2e1a"; // Dark green - mature
        return "#2e2a0a";                 // Dark gold - transcendent
    }

    /// @dev Glow colors per evolution phase
    function getGlowColor(uint8 phase) internal pure returns (string memory) {
        if (phase == 0) return "#333355";
        if (phase == 1) return "#2040a0";
        if (phase == 2) return "#6030b0";
        if (phase == 3) return "#20a040";
        return "#d4a017";
    }

    // ============================================================
    //                    HEAD SHAPES (24x24 grid)
    // ============================================================
    // Returns array of (x, y) pairs for filled pixels
    // Head occupies roughly rows 3-19, cols 6-17

    /// @dev Type 0: Round robot head
    /// A rounded head shape - wider in middle, tapers at top and bottom
    function getRoundHead() internal pure returns (bytes memory) {
        // Packed as sequential (x,y) pairs - outline + fill
        // Row by row, the filled region
        return hex"0907090809090910091109120913091409150a060a070a080a090a0a0a0b0a0c0a0d0a0e0a0f0a100a110a120a130a140a150a160b050b060b070b080b090b0a0b0b0b0c0b0d0b0e0b0f0b100b110b120b130b140b150b160b170c050c060c070c080c090c0a0c0b0c0c0c0d0c0e0c0f0c100c110c120c130c140c150c160c170d050d060d070d080d090d0a0d0b0d0c0d0d0d0e0d0f0d100d110d120d130d140d150d160d170e050e060e070e080e090e0a0e0b0e0c0e0d0e0e0e0f0e100e110e120e130e140e150e160e170f050f060f070f080f090f0a0f0b0f0c0f0d0f0e0f0f0f100f110f120f130f140f150f160f1710051006100710081009100a100b100c100d100e100f1010101110121013101410151016101711051106110711081109110a110b110c110d110e110f11101111111211131114111511161117120512061207120812091209120a120b120c120d120e120f12101211121212131214121512161217130613071308130913091309130a130b130c130d130e130f13101311131213131314131513161407140814091409140a140b140c140d140e140f14101411141214131414141515081509150a150b150c150d150e150f15101511151215131514";
    }

    /// @dev Type 1: Square android head
    function getSquareHead() internal pure returns (bytes memory) {
        return hex"0906090709080909090a090b090c090d090e090f09100911091209130914091509160a060a070a080a090a0a0a0b0a0c0a0d0a0e0a0f0a100a110a120a130a140a150a160b060b070b080b090b0a0b0b0b0c0b0d0b0e0b0f0b100b110b120b130b140b150b160c060c070c080c090c0a0c0b0c0c0c0d0c0e0c0f0c100c110c120c130c140c150c160d060d070d080d090d0a0d0b0d0c0d0d0d0e0d0f0d100d110d120d130d140d150d160e060e070e080e090e0a0e0b0e0c0e0d0e0e0e0f0e100e110e120e130e140e150e160f060f070f080f090f0a0f0b0f0c0f0d0f0e0f0f0f100f110f120f130f140f150f161006100710081009100a100b100c100d100e100f10101011101210131014101510161106110711081109110a110b110c110d110e110f11101111111211131114111511161206120712081209120a120b120c120d120e120f12101211121212131214121512161306130713081309130a130b130c130d130e130f13101311131213131314131513161406140714081409140a140b140c140d140e140f1410141114121413141414151415";
    }

    /// @dev Type 2: Tall oval cyborg head
    function getTallHead() internal pure returns (bytes memory) {
        return hex"070a070b070c070d070e070f0710071108090809080a080b080c080d080e080f08100811081209080909090a090b090c090d090e090f09100911091209130a070a080a090a0a0a0b0a0c0a0d0a0e0a0f0a100a110a120a130a140b070b080b090b0a0b0b0b0c0b0d0b0e0b0f0b100b110b120b130b140c060c070c080c090c0a0c0b0c0c0c0d0c0e0c0f0c100c110c120c130c140c150d060d070d080d090d0a0d0b0d0c0d0d0d0e0d0f0d100d110d120d130d140d150e060e070e080e090e0a0e0b0e0c0e0d0e0e0e0f0e100e110e120e130e140e150f060f070f080f090f0a0f0b0f0c0f0d0f0e0f0f0f100f110f120f130f140f151006100710081009100a100b100c100d100e100f10101011101210131014101511061107110811091109110a110b110c110d110e110f111011111112111311141115120712081209120a120b120c120d120e120f12101211121212131214130813091309130a130b130c130d130e130f13101311131213131409140a140b140c140d140e140f141014111412150a150b150c150d150e150f15101511";
    }

    /// @dev Type 3: Wide tank bot head
    function getWideHead() internal pure returns (bytes memory) {
        return hex"0a050a060a070a080a090a0a0a0b0a0c0a0d0a0e0a0f0a100a110a120a130a140a150a160a170a180b040b050b060b070b080b090b0a0b0b0b0c0b0d0b0e0b0f0b100b110b120b130b140b150b160b170b180c040c050c060c070c080c090c0a0c0b0c0c0c0d0c0e0c0f0c100c110c120c130c140c150c160c170c180d040d050d060d070d080d090d0a0d0b0d0c0d0d0d0e0d0f0d100d110d120d130d140d150d160d170d180e040e050e060e070e080e090e0a0e0b0e0c0e0d0e0e0e0f0e100e110e120e130e140e150e160e170e180f040f050f060f070f080f090f0a0f0b0f0c0f0d0f0e0f0f0f100f110f120f130f140f150f160f170f181004100510061007100810091009100a100b100c100d100e100f10101011101210131014101510161017101811041105110611071108110911091109110a110b110c110d110e110f1110111111121113111411151116111711181204120512061207120812091209120a120b120c120d120e120f12101211121212131214121512161217121813051306130713081309130a130b130c130d130e130f131013111312131313141315131613171406140714081409140a140b140c140d140e140f14101411141214131414141514161507150815091509150a150b150c150d150e150f15101511151215131514151515161608160916091609160a160b160c160d160e160f161016111612161316141615";
    }

    // ============================================================
    //                         EYES
    // ============================================================
    // Returns (x, y, colorType) triplets
    // colorType: 0=eye color, 1=white/bright, 2=dark/pupil

    /// @dev Eye type 0: Simple dot eyes
    function getDotEyes() internal pure returns (bytes memory) {
        return hex"080c02080d020811020812020910021011";
    }

    /// @dev Eye type 1: Visor (horizontal bar across face)
    function getVisorEyes() internal pure returns (bytes memory) {
        return hex"080a00080b00080c00080d00080e00080f00081000081100081200081300080b02080c02081100081200";
    }

    /// @dev Eye type 2: Laser red eyes
    function getLaserEyes() internal pure returns (bytes memory) {
        return hex"080c00080d000811000812000910001011";
    }

    /// @dev Eye type 3: Glowing green eyes
    function getGlowingEyes() internal pure returns (bytes memory) {
        return hex"080b01080c00080d01081000081100081200090c020911021010";
    }

    /// @dev Eye type 4: Cyclops (single large eye)
    function getCyclopsEye() internal pure returns (bytes memory) {
        return hex"070e01070f01080d01080e00080f00081001090d01090e00090f00091001";
    }

    /// @dev Eye type 5: Matrix code eyes  
    function getMatrixEyes() internal pure returns (bytes memory) {
        return hex"070c00080c00090c000710000810000910";
    }

    /// @dev Eye type 6: X eyes
    function getXEyes() internal pure returns (bytes memory) {
        return hex"070b02070d02080c02090b02090d020710020712020811021010021012";
    }

    /// @dev Eye type 7: Heart eyes
    function getHeartEyes() internal pure returns (bytes memory) {
        return hex"070b00070d00071000071200080c00080d000811000812000910021011";
    }

    /// @dev Eye type 8: Diamond eyes
    function getDiamondEyes() internal pure returns (bytes memory) {
        return hex"070c01080b01080c00080d01090c010710010810011011010811000812010910";
    }

    /// @dev Eye type 9: Fire eyes
    function getFireEyes() internal pure returns (bytes memory) {
        return hex"060c00060d00061100061200070c00070d000711000712000810000811000910001011";
    }

    // ============================================================
    //                        MOUTHS
    // ============================================================

    /// @dev Mouth type 0: LED smile
    function getLEDSmile() internal pure returns (bytes memory) {
        return hex"0f0b000f0c000f0d000f0e000f0f000f10000f1100100a00100b011012001011";
    }

    /// @dev Mouth type 1: Speaker grille
    function getSpeakerGrille() internal pure returns (bytes memory) {
        return hex"0f0b000f0d000f0f000f1100100c00100e001010";
    }

    /// @dev Mouth type 2: Antenna (small nub)
    function getAntennaMouth() internal pure returns (bytes memory) {
        return hex"0f0e000f0f00100e001010";
    }

    /// @dev Mouth type 3: Gas mask
    function getGasMask() internal pure returns (bytes memory) {
        return hex"0e0a010e0b000e0c000e0d000e0e000e0f000e10000e11000e12010f0a010f0c020f0d000f0e020f0f000f10020f12011009010f0b001011";
    }

    /// @dev Mouth type 4: Fangs
    function getFangs() internal pure returns (bytes memory) {
        return hex"0f0b010f0c000f0d000f0e000f0f000f10000f1101100b01101101";
    }

    /// @dev Mouth type 5: Flat line
    function getFlatLine() internal pure returns (bytes memory) {
        return hex"0f0b000f0c000f0d000f0e000f0f000f10000f1100";
    }

    /// @dev Mouth type 6: Pixel smile (curved)
    function getPixelSmile() internal pure returns (bytes memory) {
        return hex"0e0b000e11000f0c000f0d000f0e000f0f000f1000";
    }

    /// @dev Mouth type 7: Zigzag
    function getZigzag() internal pure returns (bytes memory) {
        return hex"0e0b000e0d000e0f000e11000f0c000f0e000f1000";
    }

    // ============================================================
    //                       HEADWEAR
    // ============================================================

    /// @dev Headwear type 1: Mohawk
    function getMohawk() internal pure returns (bytes memory) {
        return hex"040e00050e00060e00070e00080e00090e00040f00050f00060f00070f00080f00";
    }

    /// @dev Headwear type 2: Antenna array
    function getAntennaArray() internal pure returns (bytes memory) {
        return hex"050900060900070900050e00060e00070e00051300061300071300";
    }

    /// @dev Headwear type 3: Halo
    function getHalo() internal pure returns (bytes memory) {
        return hex"060a00060b00060c00060d00060e00060f00061000061100061200070900071300";
    }

    /// @dev Headwear type 4: Brain jar
    function getBrainJar() internal pure returns (bytes memory) {
        return hex"060a01060b01060c01060d01060e01060f01061001061101061201070a01070b02070c02070d02070e02070f01071001071101071201080a01081201";
    }

    /// @dev Headwear type 5: Horns
    function getHorns() internal pure returns (bytes memory) {
        return hex"050800060800070800080900050e00051400061400071400081300";
    }

    /// @dev Headwear type 6: Beanie
    function getBeanie() internal pure returns (bytes memory) {
        return hex"070e00080a00080b00080c00080d00080e00080f00081000081100081200081300090900091400";
    }

    /// @dev Headwear type 7: Crown
    function getCrown() internal pure returns (bytes memory) {
        return hex"060900060c00060f00061200061500070900070a00070b00070c00070d00070e00070f00071000071100071200071300071400071500080900081500";
    }

    /// @dev Headwear type 8: Lightning bolt
    function getLightningBolt() internal pure returns (bytes memory) {
        return hex"040f00050e00050f00060d00060e00070d00070e00070f00071000080f00081000";
    }

    /// @dev Headwear type 9: Satellite dish
    function getSatelliteDish() internal pure returns (bytes memory) {
        return hex"050b00050c00050d00050e00050f00061000071100071000060f00";
    }

    // ============================================================
    //                      ACCESSORIES
    // ============================================================

    /// @dev Accessory type 1: Earpiece
    function getEarpiece() internal pure returns (bytes memory) {
        return hex"0b0500";
    }

    /// @dev Accessory type 2: Scar
    function getScar() internal pure returns (bytes memory) {
        return hex"0a11000b10000c0f000d0e00";
    }

    /// @dev Accessory type 3: VR glasses
    function getVRGlasses() internal pure returns (bytes memory) {
        return hex"0c0a000c0b000c0c000c0d000c0e000c0f000c10000c11000c12000c1300";
    }

    /// @dev Accessory type 4: Eye patch
    function getEyePatch() internal pure returns (bytes memory) {
        return hex"070900080a00080b00080c00080d00090a00090b00090c00090d00";
    }

    /// @dev Accessory type 5: Neck bolts
    function getNeckBolts() internal pure returns (bytes memory) {
        return hex"110600111600";
    }

    /// @dev Accessory type 6: Chain
    function getChain() internal pure returns (bytes memory) {
        return hex"110a001110001209001211001308001312001407001413";
    }

    /// @dev Accessory type 7: Laser sight
    function getLaserSight() internal pure returns (bytes memory) {
        return hex"080600080700080800080900080a00080b00";
    }

    // ============================================================
    //                    EYE COLOR PALETTES
    // ============================================================

    /// @dev Get eye color based on eye type
    function getEyeColor(uint8 eyeType) internal pure returns (string memory) {
        if (eyeType == 0) return "#00ffff"; // Cyan dots
        if (eyeType == 1) return "#ff4444"; // Red visor
        if (eyeType == 2) return "#ff0000"; // Laser red
        if (eyeType == 3) return "#00ff00"; // Glowing green
        if (eyeType == 4) return "#ff6600"; // Cyclops orange
        if (eyeType == 5) return "#00ff41"; // Matrix green
        if (eyeType == 6) return "#ff0055"; // X red-pink
        if (eyeType == 7) return "#ff1493"; // Heart pink
        if (eyeType == 8) return "#00ccff"; // Diamond blue
        return "#ff4400";                    // Fire orange
    }

    /// @dev Get mouth color based on mouth type
    function getMouthColor(uint8 mouthType) internal pure returns (string memory) {
        if (mouthType == 0) return "#00ffcc"; // LED green
        if (mouthType == 1) return "#888888"; // Speaker gray
        if (mouthType == 2) return "#aaaaaa"; // Antenna silver
        if (mouthType == 3) return "#444444"; // Gas mask dark
        if (mouthType == 4) return "#ffffff"; // Fang white
        if (mouthType == 5) return "#ff6600"; // Flat orange
        if (mouthType == 6) return "#ffcc00"; // Smile gold
        return "#00aaff";                      // Zigzag blue
    }

    /// @dev Get headwear color based on type
    function getHeadwearColor(uint8 hwType) internal pure returns (string memory) {
        if (hwType == 1) return "#ff0044"; // Mohawk red
        if (hwType == 2) return "#aaaaaa"; // Antenna silver
        if (hwType == 3) return "#ffdd00"; // Halo gold
        if (hwType == 4) return "#44ddaa"; // Brain jar cyan
        if (hwType == 5) return "#880000"; // Horns dark red
        if (hwType == 6) return "#3366cc"; // Beanie blue
        if (hwType == 7) return "#ffd700"; // Crown gold
        if (hwType == 8) return "#ffff00"; // Lightning yellow
        return "#8888aa";                   // Satellite gray
    }

    /// @dev Get accessory color based on type
    function getAccessoryColor(uint8 accType) internal pure returns (string memory) {
        if (accType == 1) return "#333333"; // Earpiece black
        if (accType == 2) return "#cc4444"; // Scar red
        if (accType == 3) return "#222233"; // VR dark
        if (accType == 4) return "#222222"; // Eye patch black
        if (accType == 5) return "#999999"; // Neck bolts gray
        if (accType == 6) return "#ccaa00"; // Chain gold
        return "#ff0000";                    // Laser sight red
    }
}
