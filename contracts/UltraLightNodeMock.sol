// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interfaces/ILayerZeroUltraLightNodeV1.sol";

// this is a mocked LayerZero UltraLightNodeMock that receives the blockHash and receiptsRoot
contract UltraLightNodeMock is ILayerZeroUltraLightNodeV1, ReentrancyGuard {

    // oracle fees will accumulate in the LayerZero contract
    mapping(address => uint) public oracleQuotedFees;
    mapping(address => mapping(uint16 => mapping(bytes32 => BlockData))) public hashLookup;


    struct BlockData {
        uint          confirmations;
        bytes32        data;
    }

    event HashReceived(uint16 srcChainId, address oracle, uint confirmations, bytes32 blockhash);
    event WithdrawNative(address _owner, address _to, uint _amount);

    mapping(address => mapping(uint16 => mapping(bytes32 => BlockData))) public blockHeaderLookup;

    // Can be called by any address to update a block header
    // can only upload new block data or the same block data with more confirmations
    function updateHash(uint16 _remoteChainId, bytes32 _lookupHash, uint _confirmations, bytes32 _data) external override {
        // this function may revert with a default message if the oracle address is not an ILayerZeroOracle
        BlockData storage bd = hashLookup[msg.sender][_remoteChainId][_lookupHash];
        // if it has a record, requires a larger confirmation.
        require(bd.confirmations < _confirmations, "LayerZero: oracle data can only update if it has more confirmations");

        // set the new information into storage
        bd.confirmations = _confirmations;
        bd.data = _data;

        emit HashReceived(_remoteChainId, msg.sender, _confirmations, _lookupHash);
    }

    function withdrawOracleFee(address _to, uint _amount) override nonReentrant external {
        oracleQuotedFees[msg.sender] = oracleQuotedFees[msg.sender] - _amount;
        _withdrawNative(msg.sender, _to, _amount);
    }

    //---------------------------------------------------------------------------
    // Claim Fees
    function _withdrawNative(address _from, address _to, uint _amount) internal {
        (bool success, ) = _to.call{value: _amount}('');
        require(success, "LayerZero: withdraw failed");
        emit WithdrawNative(_from, _to, _amount);
    }
}
