// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { ILivestockNFT } from "src/interfaces/ILivestockNFT.sol";
import { INFTStorage } from "src/interfaces/INFTStorage.sol";
import { LivestockTracker } from "src/LivestockNFT.sol";
import { Cattle } from "src/CattleV0.1.0.sol";
import { CattleMeat } from "src/CattleMeatV0.1.0.sol";

contract LivestockTest is Test {
    LivestockTracker public livestockNFT;
    Cattle public cattle;
    CattleMeat public cattleMeat;

    function setUp() public {
        livestockNFT = new LivestockTracker(msg.sender);
        cattle = new Cattle(ILivestockNFT(address(livestockNFT)));
        cattleMeat = new CattleMeat(ILivestockNFT(address(livestockNFT)));
    }

    function test_fullUse() public {
        vm.startPrank(msg.sender);
        livestockNFT.grantRole(keccak256("MINTER_ROLE"), address(cattle));
        livestockNFT.grantRole(keccak256("MINTER_ROLE"), address(cattleMeat));
        // create NFT types and set their implementation addresses
        uint256 typeId = livestockNFT.createNewType(INFTStorage(address(cattle)));
        assertEq(typeId, 0);
        typeId = livestockNFT.createNewType(INFTStorage(address(cattleMeat)));
        assertEq(typeId, 1);

        // mint a cow to user
        uint64 birthDate = uint64(block.timestamp);
        uint32 weight = 1_300_000; // grams
        uint256 damNftId = 0;
        uint256 sireNftId = 0;
        string memory offchainId = "215-8479.BAF-76";
        bytes memory nftInfo = abi.encode(birthDate, weight, damNftId, sireNftId, offchainId);
        uint256 cowId = livestockNFT.mint(msg.sender, 0, nftInfo);
        assertEq(cowId, 1); // must be the first NFT
        (uint256 nftType, INFTStorage implementation) = livestockNFT.getNftImplementation(cowId);
        assertEq(nftType, 0); // Type is cattle
        assertEq(address(implementation), address(cattle)); // implementation is cattle
        assertEq(cattle.getWeight(cowId), 1_300_000); // check weight is the one we passed

        // kill the animal
        cattle.setSlaughterDate(cowId, uint64(block.timestamp), 123);
        // cut the animal
        bytes32[] memory cutTypes = new bytes32[](10);
        uint32[] memory cutWeights = new uint32[](10);
        cutTypes[0] = keccak256("CUT_ACEM");
        cutTypes[1] = keccak256("CUT_ALCATRA");
        cutTypes[2] = keccak256("CUT_ALCATRA");
        cutTypes[3] = keccak256("CUT_BUCHO");
        cutTypes[4] = keccak256("CUT_CAPA_DO_COXAO_MOLE");
        cutTypes[5] = keccak256("CUT_CONTRAFILE");
        cutTypes[6] = keccak256("CUT_CORACAO_DE_ALCATRA");
        cutTypes[7] = keccak256("CUT_COXAO_DURO");
        cutTypes[8] = keccak256("CUT_COXAO_MOLE");
        cutTypes[9] = keccak256("CUT_DIANTEIRO");
        cutWeights[0] = 15_000;
        cutWeights[1] = 25_000;
        cutWeights[2] = 35_000;
        cutWeights[3] = 45_000;
        cutWeights[4] = 55_000;
        cutWeights[5] = 65_000;
        cutWeights[6] = 75_000;
        cutWeights[7] = 85_000;
        cutWeights[8] = 95_000;
        cutWeights[9] = 105_000;
        uint256[] memory meatNftIds = cattle.createCuts(cowId, 1, cutTypes, cutWeights);

        // all of them are cuts of the same cow
        for (uint256 i = 0; i < meatNftIds.length; i++) {
            uint256 nftId = meatNftIds[i];
            assertEq(nftId, i + 2);
            (nftType, implementation) = livestockNFT.getNftImplementation(nftId);
            assertEq(nftType, 1);
            assertEq(address(implementation), address(cattleMeat));
            CattleMeat.CattleMeatInfo memory cattleMeatInfo = cattleMeat.getInfo(nftId);
            assertEq(cattleMeatInfo.weight, cutWeights[i]);
            assertEq(cattleMeatInfo.cutType, cutTypes[i]);
            assertEq(cattleMeatInfo.nftIdParent, cowId);
        }
    }
}
