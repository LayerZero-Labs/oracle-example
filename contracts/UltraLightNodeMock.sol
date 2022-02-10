// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interfaces/ILayerZeroUltraLightNodeV1.sol";

// this is a mocked LayerZero UltraLightNodeMock that receives the blockHash and receiptsRoot
contract UltraLightNodeMock is ILayerZeroUltraLightNodeV1, ReentrancyGuard {

    // oracle fees will accumulate in the LayerZero contract
    mapping(address => uint) public oracleQuotedFees;

    struct BlockData {
        uint          confirmations;
        bytes         data;
    }

    event HeaderReceived(uint16 srcChainId, address oracle, uint confirmations, bytes blockhash);
    event WithdrawNative(address _owner, address _to, uint _amount);

    mapping(address => mapping(uint16 => mapping(bytes => BlockData))) public blockHeaderLookup;

    // _srcChainId - the source layerzero chainId the data is coming from
    // _blockHash - the source blockHash (for EVM: 32 bytes in length)
    // _confirmations - the number of confirmations the oracle waited before delivering the data
    // _data - for EVM, this is the receiptsRoot for the blockHash being delivered (for EVM: 32 bytes in length)
    // Can be called by any address to update a block header
    function updateBlockHeader(uint16 _srcChainId, bytes calldata _blockHash, uint _confirmations, bytes calldata _data ) override external {
        // this function may revert with a default message if the oracle address is not an ILayerZeroOracle
        BlockData storage bd = blockHeaderLookup[msg.sender][_srcChainId][_blockHash];
        require(bd.data.length == 0 || bd.confirmations < _confirmations, "LayerZero: oracle data can only update if it has more confirmations");

        // set the new information into storage
        bd.confirmations = _confirmations;
        bd.data = _data;

        emit HeaderReceived(_srcChainId, msg.sender, _confirmations, _blockHash );
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
