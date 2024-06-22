// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface ILivestockNFT is IERC1155 {
    function batchMint(
        address to,
        uint256 nftType,
        uint256 nftIdParent,
        bytes32[] calldata cutTypes,
        uint32[] calldata cutWeights
    ) external returns (uint256[] memory nftIds);

    function createSubNFTs(
        address to,
        uint256 nftId,
        uint256 subNFTsType,
        bytes32[] calldata cutTypes,
        uint32[] calldata cutWeights
    ) external returns (uint256[] memory nftIds);
}
