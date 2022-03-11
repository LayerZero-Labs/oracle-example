// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;

import "./ILayerZeroUserApplicationConfig.sol";

interface ILayerZeroEndpoint is ILayerZeroUserApplicationConfig {

    // the starting point of LayerZero message protocol
    function send(uint16 _chainId, bytes calldata _destination, bytes calldata _payload, address payable refundAddress, address _zroPaymentAddress,  bytes calldata txParameters ) external payable;

    // estimate the fee requirement for message passing
    function estimateNativeFees(uint16 _chainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _txParameters)  view external returns(uint totalFee);

    // LayerZero uses nonce to enforce message ordering.
    function getInboundNonce(uint16 _chainID, bytes calldata _srcAddress) external view returns (uint64);

    function getOutboundNonce(uint16 _chainID, address _srcAddress) external view returns (uint64);

    // @notice get this Endpoint's immutable source identifier
    function getChainId() external view returns (uint16);

    // LayerZero catch all error/exception from the receiver contract and store them for retry.
    function retryPayload(uint16 _srcChainId, bytes calldata _srcAddress, address _dstAddress, uint _gasLimit) external returns(bool);
}
