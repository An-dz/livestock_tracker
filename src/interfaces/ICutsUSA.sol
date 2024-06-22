// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

abstract contract ICutsUSA {
    bytes32 private constant CUT_PRIMAL_CHUCK = keccak256("CUT_PRIMAL_CHUCK");
    bytes32 private constant CUT_PRIMAL_RIB = keccak256("CUT_PRIMAL_RIB");
    bytes32 private constant CUT_PRIMAL_LOIN = keccak256("CUT_PRIMAL_LOIN");
    bytes32 private constant CUT_PRIMAL_ROUND = keccak256("CUT_PRIMAL_ROUND");
    bytes32 private constant CUT_PRIMAL_FLANK = keccak256("CUT_PRIMAL_FLANK");
    bytes32 private constant CUT_PRIMAL_SHORT_PLATE = keccak256("CUT_PRIMAL_SHORT_PLATE");
    bytes32 private constant CUT_PRIMAL_SHANK = keccak256("CUT_PRIMAL_SHANK");
    bytes32 private constant CUT_PRIMAL_BRISKET = keccak256("CUT_PRIMAL_BRISKET");

    bytes32 private constant CUT_CHUCK_NECK = keccak256("CUT_CHUCK_NECK");
    bytes32 private constant CUT_CHUCK_SHOULDERS = keccak256("CUT_CHUCK_SHOULDERS");
    bytes32 private constant CUT_CHUCK_TOP_BLADE = keccak256("CUT_CHUCK_TOP_BLADE");
    bytes32 private constant CUT_CHUCK_BOTTOM_BLADE = keccak256("CUT_CHUCK_BOTTOM_BLADE");
    bytes32 private constant CUT_CHUCK_GROUND_BEEF = keccak256("CUT_CHUCK_GROUND_BEEF");
    bytes32 private constant CUT_CHUCK_STEAK = keccak256("CUT_CHUCK_STEAK");
    bytes32 private constant CUT_CHUCK_FILET = keccak256("CUT_CHUCK_FILET");

    bytes32 private constant CUT_RIB_STEAK = keccak256("CUT_RIB_STEAK");
    bytes32 private constant CUT_RIB_RIBEYE_STEAK = keccak256("CUT_RIB_RIBEYE_STEAK");
    bytes32 private constant CUT_RIB_PRIME_RIB = keccak256("CUT_RIB_PRIME_RIB");
    bytes32 private constant CUT_RIB_SHORT_RIB = keccak256("CUT_RIB_SHORT_RIB");
    bytes32 private constant CUT_RIB_BACK_RIBS = keccak256("CUT_RIB_BACK_RIBS");

    bytes32 private constant CUT_LOIN_TBONE = keccak256("CUT_LOIN_TBONE");
    bytes32 private constant CUT_LOIN_CLUB_STEAK = keccak256("CUT_LOIN_CLUB_STEAK");
    bytes32 private constant CUT_LOIN_FILET_MIGNON = keccak256("CUT_LOIN_FILET_MIGNON");
    bytes32 private constant CUT_LOIN_NEW_YORK_STRIP = keccak256("CUT_LOIN_NEW_YORK_STRIP");
    bytes32 private constant CUT_LOIN_SIRLOIN_CAP = keccak256("CUT_LOIN_SIRLOIN_CAP");
    bytes32 private constant CUT_LOIN_SIRLOIN_STEAK = keccak256("CUT_LOIN_SIRLOIN_STEAK");
    bytes32 private constant CUT_LOIN_TRITIP = keccak256("CUT_LOIN_TRITIP");
    bytes32 private constant CUT_LOIN_CHATEAUBRIAND = keccak256("CUT_LOIN_CHATEAUBRIAND");
    bytes32 private constant CUT_LOIN_PORTERHOUSE = keccak256("CUT_LOIN_PORTERHOUSE");

    bytes32 private constant CUT_ROUND_TOP_ROUND = keccak256("CUT_ROUND_TOP_ROUND");
    bytes32 private constant CUT_ROUND_EYE_ROUND = keccak256("CUT_ROUND_EYE_ROUND");
    bytes32 private constant CUT_ROUND_HEEL_ROUND = keccak256("CUT_ROUND_HEEL_ROUND");
    bytes32 private constant CUT_ROUND_SIRLOIN_TIP = keccak256("CUT_ROUND_SIRLOIN_TIP");
    bytes32 private constant CUT_ROUND_BOTTOM_ROUND = keccak256("CUT_ROUND_BOTTOM_ROUND");

    bytes32 private constant CUT_FLANK_GROUND_BEEF = keccak256("CUT_FLANK_GROUND_BEEF");
    bytes32 private constant CUT_FLANK_LONDON_BROIL = keccak256("CUT_FLANK_LONDON_BROIL");
    bytes32 private constant CUT_FLANK_STEAK = keccak256("CUT_FLANK_STEAK");

    bytes32 private constant CUT_SHORT_PLATE_HANGER_STEAK = keccak256("CUT_SHORT_PLATE_HANGER_STEAK");
    bytes32 private constant CUT_SHORT_PLATE_GROUND_BEEF = keccak256("CUT_SHORT_PLATE_GROUND_BEEF");
    bytes32 private constant CUT_SHORT_PLATE_BRISKET = keccak256("CUT_SHORT_PLATE_BRISKET");
    bytes32 private constant CUT_SHORT_PLATE_SKIRT_STEAK = keccak256("CUT_SHORT_PLATE_SKIRT_STEAK");

    bytes32 private constant CUT_SHANK_FORE_SHANK = keccak256("CUT_SHANK_FORE_SHANK");
    bytes32 private constant CUT_SHANK_HIND_SHANK = keccak256("CUT_SHANK_HIND_SHANK");
    bytes32 private constant CUT_SHANK_GROUND_BEEF = keccak256("CUT_SHANK_GROUND_BEEF");

    bytes32 private constant CUT_BRISKET_POINT = keccak256("CUT_BRISKET_POINT");
    bytes32 private constant CUT_BRISKET_PLATE = keccak256("CUT_BRISKET_PLATE");
}
