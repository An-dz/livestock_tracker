// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import { ILivestockNFT } from "src/interfaces/ILivestockNFT.sol";

interface INFTStorage {
    function mint(uint256 nftId, bytes calldata nftInfo) external;
    function version() external returns (bytes32);
    function nftImplementation() external returns (ILivestockNFT);
    function getWeight(uint256 nftId) external returns (uint32 weight);
}
