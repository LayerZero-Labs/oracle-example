// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.11;

interface ILayerZeroOracle {

    function getPrice(uint16 dstChainId) view external returns (uint priceInWei);

    function notifyOracleOfBlock(uint16 dstChainId, bytes calldata dstNetworkAddress, uint blockConfirmations) external;

    function isApproved(address oracleSigner) view external returns (bool approved);

}

