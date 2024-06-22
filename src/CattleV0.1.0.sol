// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { ILivestockNFT } from "src/interfaces/ILivestockNFT.sol";
import { INFTStorage } from "src/interfaces/INFTStorage.sol";

contract Cattle is INFTStorage {
    /**
     * Error for when the sender is not the NFT contract
     */
    error SenderIsNotNFT(address sender, address expected);

    /**
     * Error for when the sender is not the NFT contract
     */
    error SenderIsNotNFTOwner(address sender, uint256 nftId);

    /**
     * Error for when the length of two arrays mismatch
     */
    error ArrayLengthMismatch(uint256 typesLength, uint256 weightLength);

    /**
     * Error for when the animal has already have its cuts defined
     */
    error AlreadyCut(uint256 nftId);

    /**
     * Error for when the animal has not been slaughtered yet
     */
    error AnimalIsAlive(uint256 nftId);

    /**
     * Error for when the animal has already been slaughtered
     */
    error AnimalNotAlive(uint256 nftId);

    /**
     * Error for when there's a mismatch of the animal's weight
     */
    error WrongWeight(address sender, uint256 nftId, uint32 oldWeight, uint32 newWeight);

    event AnimalSlaughtered(uint256 nftId, uint64 slaughterDate);

    event WeightUpdated(
        uint256 nftId, uint32 oldWeight, uint32 newWeight, uint64 oldWeightTimestamp, uint64 newWeightTimestamp
    );

    struct CattleInfo {
        // birth of the animal
        uint64 birthDate;
        // slaughter date of the animal
        uint64 slaughterDate;
        // last timestamp when weight was updated, used to check growth
        uint64 lastWeightUpdate;
        // current weight of the animal
        uint32 weight;
        // animal cuts can only be created once
        bool hasBeenCut;
        // the slaughter house that slaughtered the animal
        uint256 slaughterHouse;
        // female progenitor
        uint256 damNftId;
        // male progenitor
        uint256 sireNftId;
        // ID used by the rancher or governmental institutions
        string offchainId;
    }

    /// Version of this implementation
    bytes32 public version = "v0.1.0";
    /// Address of the NFT contract that uses this
    ILivestockNFT public nftImplementation;
    mapping(uint256 nftId => CattleInfo info) private _animalInfo;

    /**
     * Allow only calls from the NFT contract
     */
    modifier onlyNftCalls() {
        if (msg.sender != address(nftImplementation)) {
            revert SenderIsNotNFT(msg.sender, address(nftImplementation));
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

    /**
     * Allow only calls while animal is alive
     */
    modifier animalIsAlive(uint256 nftId) {
        if (_animalInfo[nftId].slaughterDate > 0) {
            revert AnimalNotAlive(nftId);
        }
        _;
    }

    /**
     * Allow only calls while animal is alive
     */
    modifier animalIsNotAlive(uint256 nftId) {
        if (_animalInfo[nftId].slaughterDate == 0) {
            revert AnimalIsAlive(nftId);
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
     *  - uint64 birthDate - Timestamp when the animal was born
     *  - uint32 weight - Current weight of the animal
     *  - uint256 damNftId - NFT ID of the animal's Dam
     *  - uint256 sireNftId - NFT ID of the animal's Sire
     *  - string offchainId - An external ID use to identify the animal
     */
    function mint(uint256 nftId, bytes calldata nftInfo) external onlyNftCalls {
        (uint64 birthDate, uint32 weight, uint256 damNftId, uint256 sireNftId, string memory offchainId) =
            abi.decode(nftInfo, (uint64, uint32, uint256, uint256, string));

        if (weight > 4_000_000) {
            revert WrongWeight(msg.sender, nftId, 0, weight);
        }

        CattleInfo storage c = _animalInfo[nftId];
        c.birthDate = birthDate;
        c.lastWeightUpdate = uint64(block.timestamp);
        c.weight = weight;
        c.damNftId = damNftId;
        c.sireNftId = sireNftId;
        c.offchainId = offchainId;
        emit WeightUpdated(nftId, 0, weight, birthDate, c.lastWeightUpdate);
    }

    /**
     * Get info about the animal
     *
     * @param nftId - ID of the NFT that tracks the animal you want information about
     *
     * @return cattleInfo - CattleInfo struct with information about the animal
     */
    function getInfo(uint256 nftId) external view returns (CattleInfo memory cattleInfo) {
        return _animalInfo[nftId];
    }

    function getWeight(uint256 nftId) external view returns (uint32 weight) {
        return _animalInfo[nftId].weight;
    }

    /**
     * Update the weight of the animal
     *
     * @param nftId - Id of the NFT that tracks this animal
     * @param newWeight - New weight of the animal in grams
     */
    function updateAnimalWeight(uint256 nftId, uint32 newWeight) external onlyNftOwner(nftId) animalIsAlive(nftId) {
        if (newWeight > 4_000_000) {
            revert WrongWeight(msg.sender, nftId, _animalInfo[nftId].weight, newWeight);
        }

        uint64 updateTimestamp = uint64(block.timestamp);
        emit WeightUpdated(
            nftId, _animalInfo[nftId].weight, newWeight, _animalInfo[nftId].lastWeightUpdate, updateTimestamp
        );
        _animalInfo[nftId].weight = newWeight;
        _animalInfo[nftId].lastWeightUpdate = updateTimestamp;
    }

    /**
     * Set the animal as slaughtered
     *
     * Note: This will prevent some info from being updated as the animal is dead
     *
     * @param nftId - Id of the NFT that tracks this animal
     * @param slaughterDate - Timestamp
     */
    function setSlaughterDate(uint256 nftId, uint64 slaughterDate, uint256 slaughterHouse)
        external
        onlyNftOwner(nftId)
        animalIsAlive(nftId)
    {
        _animalInfo[nftId].slaughterDate = slaughterDate;
        _animalInfo[nftId].slaughterHouse = slaughterHouse;
        emit AnimalSlaughtered(nftId, slaughterDate);
    }

    function createCuts(uint256 nftId, uint256 subNFTsType, bytes32[] calldata cutTypes, uint32[] calldata cutWeights)
        external
        onlyNftOwner(nftId)
        animalIsNotAlive(nftId)
        returns (uint256[] memory nftIds)
    {
        if (_animalInfo[nftId].hasBeenCut) {
            revert AlreadyCut(nftId);
        }

        if (cutTypes.length != cutWeights.length) {
            revert ArrayLengthMismatch(cutTypes.length, cutWeights.length);
        }

        return nftImplementation.createSubNFTs(msg.sender, nftId, subNFTsType, cutTypes, cutWeights);
    }
}
