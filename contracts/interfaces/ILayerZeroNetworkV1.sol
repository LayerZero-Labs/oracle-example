// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;

interface ILayerZeroNetworkV1 {
    function updateBlockHeader(uint16 _srcChainId, address _oracle, bytes calldata _blockHash, uint _confirmations, bytes calldata _data ) external;
}


