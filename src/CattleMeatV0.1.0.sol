// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { ICutsBrazil } from "src/interfaces/ICutsBrazil.sol";
import { ILivestockNFT } from "src/interfaces/ILivestockNFT.sol";
import { INFTStorage } from "src/interfaces/INFTStorage.sol";

contract CattleMeat is INFTStorage, ICutsBrazil {
    /**
     * Error for when the function is expected to exist but this version doesn't implement it
     */
    error NotImplemented();

    /**
     * Error for when the sender is not the NFT contract
     */
    error SenderIsNotNFT(address sender);

    /**
     * Error for when the sender is not the NFT contract
     */
    error SenderIsNotNFTOwner(address sender, uint256 nftId);

    /**
     * Error for when the weight of the cuts goes above the expected cattle weight
     */
    error WeightOfByproductsMismatch(uint256 nftId, uint256 cattleWeight, uint256 byproductsWeight);

    struct CattleMeatInfo {
        // weight of the cut
        uint32 weight;
        // NFT ID of the parent NFT that created this cut
        // primal cuts come from cattle, but further cuts come from other cuts
        uint256 nftIdParent;
        // type of cut, allows only certain cuts from it
        bytes32 cutType;
    }

    /// Version of this implementation
    bytes32 public version = "v0.1.0";
    /// Address of the NFT contract that uses this
    ILivestockNFT public nftImplementation;
    mapping(uint256 nftId => CattleMeatInfo info) private _cutInfo;

    /**
     * Allow only calls from the NFT contract
     */
    modifier onlyNftCalls() {
        if (msg.sender != address(nftImplementation)) {
            revert SenderIsNotNFT(msg.sender);
        }
        _;
    }

    /**
     * Allow only calls from the NFT owner
     */
    modifier onlyNftOwner(uint256 nftId) {
        if (nftImplementation.balanceOf(msg.sender, nftId) == 0) {
            revert SenderIsNotNFTOwner(msg.sender, nftId);
        }
        _;
    }

    constructor(ILivestockNFT nftContract) {
        nftImplementation = nftContract;
    }

    /**
     * Save cattle information in contract
     *
     * @param nftId - ID of the NFT on the Livestock Tracker NFT
     * @param nftInfo - ABI encoded data following this format:
     *  - uint32 weight - Weight of the cut
     *  - uint256 nftIdParent - Parent NFT ID, cattle or previous cut this cut comes from
     *  - bytes32 cutType - Type of cut this NFT represents
     */
    function mint(uint256 nftId, bytes calldata nftInfo) external onlyNftCalls {
        (uint32 weight, uint256 nftIdParent, bytes32 cutType) = abi.decode(nftInfo, (uint32, uint256, bytes32));
        CattleMeatInfo storage c = _cutInfo[nftId];
        c.weight = weight;
        c.cutType = cutType;
        c.nftIdParent = nftIdParent;
    }

    /**
     * Get info about the cut
     *
     * @param nftId - ID of the NFT that tracks the cut you want information about
     *
     * @return cattleMeatInfo - CattleMeatInfo struct with information about the cut
     */
    function getInfo(uint256 nftId) external view returns (CattleMeatInfo memory cattleMeatInfo) {
        return _cutInfo[nftId];
    }

    function getWeight(uint256 nftId) external view returns (uint32 weight) {
        return _cutInfo[nftId].weight;
    }

    function createCuts(
        address to,
        INFTStorage implementation,
        uint256 nftId,
        uint256 subNFTsType,
        bytes32[] calldata cutTypes,
        uint32[] calldata cutWeights
    ) external onlyNftCalls returns (uint256[] memory nftIds) {
        // cattle have around 35-40% of their weight as meat, we use 50%
        uint256 cattleWeight = implementation.getWeight(nftId) / 2;
        uint256 byproductsWeight = 0;

        for (uint256 i = 0; i < cutTypes.length; i++) {
            byproductsWeight += cutWeights[i];

            if (cattleWeight < byproductsWeight) {
                revert WeightOfByproductsMismatch(nftId, cattleWeight, byproductsWeight);
            }
        }

        return nftImplementation.batchMint(to, subNFTsType, nftId, cutTypes, cutWeights);
    }

    function createSubCuts(uint256) external pure {
        revert NotImplemented();
    }
}
