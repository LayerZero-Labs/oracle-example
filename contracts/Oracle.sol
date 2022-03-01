// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interfaces/ILayerZeroOracle.sol";
import "./interfaces/ILayerZeroUltraLightNodeV1.sol";

// Oracle template
contract Oracle is ILayerZeroOracle, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address immutable ultraLightNode;

    mapping(address => bool) public approvedAddresses;
    mapping(uint16 => mapping(uint16 => uint)) public chainPriceLookup;

    event WithdrawTokens(address token, address to, uint amount);
    event Withdraw(address to, uint amount);

    constructor(address _ultraLightNode) {
        ultraLightNode = _ultraLightNode;
    }

    // Oracle.updateHash() internally calls UltraLightNode.updateHash()
    // This method wraps the ULN call in order that the same msg.sender
    // is always the same deliverer of the oracle data for LayerZero in the ULN.
    function updateHash(uint16 _srcChainId, bytes32 _blockHash, uint _confirmations, bytes32 _data ) external {
        require(isApproved(msg.sender), "Oracle: signer is not approved");

        ILayerZeroUltraLightNodeV1(ultraLightNode).updateHash(
            _srcChainId,
            _blockHash,
            _confirmations,
            _data
        );
    }

    // owner can approve a token spender
    function approveToken(address _token, address _spender, uint _amount) external onlyOwner {
        IERC20 token = IERC20(_token);
        token.safeApprove(_spender, _amount);
    }

    // owner can withdraw native
    function withdraw(address payable _to, uint _amount) public nonReentrant onlyOwner {
        (bool success, ) = _to.call{value: _amount}('');
        require(success, "OracleClient: failed to withdraw");
        emit Withdraw(_to, _amount);
    }

    // owner can withdraw tokens
    function withdrawTokens(address _token, address _to, uint _amount) public onlyOwner {
        IERC20(_token).safeTransfer(_to, _amount);
        emit WithdrawTokens(_token, _to, _amount);
    }

    // initiate the Oracle to perform its job
    function notifyOracle(uint16 _dstChainId, uint16 _outboundProofType, bytes32 _remoteUlnAddress, uint64 _outboundBlockConfirmations, bytes32 _payloadHash) external override {
        // TODO initiate Oracle on source from the the LayerZero contract,
        //       indicating the blockheader/receipts root should be moved to destination
    }

    function getPrice(uint16 destinationChainId, uint16 outboundProofType) external view override returns(uint price){
        return chainPriceLookup[destinationChainId][outboundProofType];
    }

    function setPrice(uint16 _destinationChainId, uint16 outboundProofType, uint price) external onlyOwner {
        chainPriceLookup[_destinationChainId][outboundProofType] = price;
    }

    // return whether this signing address is whitelisted
    function isApproved(address oracleAddress) public view override returns (bool approved){
        return approvedAddresses[oracleAddress];
    }

    // owner can approve a signer
    function setApprovedAddress(address _oracleAddress, bool _approve) external onlyOwner {
        approvedAddresses[_oracleAddress] = _approve;
    }

    // allow this contract to receive ether
    fallback () external payable {}
    receive () external payable  {}

}