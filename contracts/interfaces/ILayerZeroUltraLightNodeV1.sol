// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.7.0;

interface ILayerZeroUltraLightNodeV1 {

    /// an Oracle delivers the block data using updateBlockHeader()
    function updateHash(uint16 _remoteChainId, bytes calldata _blockHash, uint _confirmations, bytes calldata _data) external;

    /// oracle can withdraw their fee from the ULN which accumulates native tokens per call
    function withdrawOracleFee(address _to, uint _amount) external;

    //    /// un-used by Oracle
    //    function validateTransactionProof(uint16 _srcChainId, address _dstAddress, uint _gasLimit, bytes calldata _blockHash, bytes calldata _transactionProof) external;
    //    function withdrawTreasuryFee(address _to, uint _amount, bool _inNative) external;
    //    function withdrawRelayerFee(address _owner, address _to, uint _amount, bool _inNative, bool _quoted) external;

}
