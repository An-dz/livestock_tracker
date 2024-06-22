// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { INFTStorage } from "src/interfaces/INFTStorage.sol";

interface IMeat {
    function createCuts(
        address to,
        INFTStorage implementation,
        uint256 nftId,
        uint256 subNFTsType,
        bytes32[] calldata cutTypes,
        uint32[] calldata cutWeights
    ) external returns (uint256[] memory nftIds);
}
