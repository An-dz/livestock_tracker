// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { AccessControlDefaultAdminRules } from
    "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";
import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import { INFTStorage } from "src/interfaces/INFTStorage.sol";
import { IMeat } from "src/interfaces/IMeat.sol";

contract LivestockTracker is ERC1155, AccessControlDefaultAdminRules {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // nftId => nftType
    uint256[] private _nftType;
    // nftType => implementation
    INFTStorage[] private _nftTypeImplementation;

    /**
     * Code run on deployment
     *
     * @param initialAdmin - First admin of the contract
     */
    constructor(address initialAdmin)
        ERC1155("https://livestock.example/api/item/{id}.json")
        AccessControlDefaultAdminRules(3 days, initialAdmin)
    {
        _grantRole(MINTER_ROLE, initialAdmin);
        _nftType.push(0); // skip first NFT
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlDefaultAdminRules, ERC1155)
        returns (bool)
    {
        return AccessControlDefaultAdminRules.supportsInterface(interfaceId) || ERC1155.supportsInterface(interfaceId);
    }

    /**
     * Get the implementation contract for an NFT type
     *
     * @param nftType - NFT Type to get the implementation address
     *
     * @return implementation - Implementation contract address
     */
    function getNftTypeImplementation(uint256 nftType) external view returns (INFTStorage implementation) {
        return _nftTypeImplementation[nftType];
    }

    /**
     * Get the NFT type and implementation contract for a specific NFT
     *
     * @param nftId - ID of the NFT to get the implementation address
     *
     * @return nftType - NFT type ID for the requested NFT
     * @return implementation - Implementation contract address
     */
    function getNftImplementation(uint256 nftId) external view returns (uint256 nftType, INFTStorage implementation) {
        nftType = _nftType[nftId];
        implementation = _nftTypeImplementation[nftType];
    }

    /**
     * Update the URI of the NFT
     *
     * @param newuri - New URI for the NFT metadata
     */
    function updateURI(string calldata newuri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(newuri);
    }

    /**
     * Create a new NFT type, pointing to its implementation address
     *
     * @param implementation - Address of the implementation contract
     *
     * @return typeId - ID of the new NFT type
     */
    function createNewType(INFTStorage implementation) external onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256 typeId) {
        _nftTypeImplementation.push(implementation);
        return _nftTypeImplementation.length - 1;
    }

    /**
     * Mints a new NFT
     *
     * @param to - Owner of the new NFT
     * @param nftType - Type of the NFT being created, which will point to where its data is stored
     * @param nftInfo - ABI encoded data for the implementation contract
     *
     * @return nftId - ID of the newly minted NFT
     */
    function mint(address to, uint256 nftType, bytes calldata nftInfo)
        external
        onlyRole(MINTER_ROLE)
        returns (uint256 nftId)
    {
        nftId = _nftType.length;
        _nftTypeImplementation[nftType].mint(nftId, nftInfo);
        _nftType.push(nftType);
        _mint(to, nftId, 1, "");
    }

    function createSubNFTs(
        address to,
        uint256 nftId,
        uint256 subNFTsType,
        bytes32[] calldata cutTypes,
        uint32[] calldata cutWeights
    ) external onlyRole(MINTER_ROLE) returns (uint256[] memory nftIds) {
        INFTStorage subNFTimplementation = _nftTypeImplementation[subNFTsType];
        INFTStorage superNFTimplementation = _nftTypeImplementation[_nftType[nftId]];
        return IMeat(address(subNFTimplementation)).createCuts(
            to, superNFTimplementation, nftId, subNFTsType, cutTypes, cutWeights
        );
    }

    function batchMint(
        address to,
        uint256 nftType,
        uint256 nftIdParent,
        bytes32[] calldata cutTypes,
        uint32[] calldata cutWeights
    ) external onlyRole(MINTER_ROLE) returns (uint256[] memory nftIds) {
        nftIds = new uint256[](cutTypes.length);
        uint256[] memory values = new uint256[](cutTypes.length);

        for (uint256 i = 0; i < cutTypes.length; i++) {
            bytes memory nftInfo = abi.encode(cutWeights[i], nftIdParent, cutTypes[i]);
            uint256 nftId = _nftType.length;
            _nftTypeImplementation[nftType].mint(nftId, nftInfo);
            _nftType.push(nftType);
            nftIds[i] = nftId;
            values[i] = 1;
        }

        _mintBatch(to, nftIds, values, "");
    }
}
