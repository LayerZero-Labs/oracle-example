// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;

// LayerZero oracle interface.
interface ILayerZeroOracle {

    // the qty of native gas token (on source) for initiating the oracle with notifyOracleOfBlock()
    function getPrice(uint16 dstChainId) view external returns (uint priceInWei);

    // initiates the oracle to do its job
    function notifyOracle(uint16 _dstChainId, uint16 _outboundProofType, bytes32 _remoteUlnAddress, uint64 _outboundBlockConfirmations, bytes32 _payloadHash) external;

    // return true if the address is allowed to call updateBlockHeader()
    function isApproved(address oracleSigner) view external returns (bool approved);

}


