// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;

// a contract that implements this interface must have access
// to a LayerZero endpoint
interface ILayerZeroUserApplicationConfig {
    // generic config for user Application
    function setConfig(uint16 _version, uint _configType, bytes calldata _config) external;
    function getConfig(uint16 _version, uint16 _chainId, address _userApplication, uint _configType) view external returns(bytes memory);

    // LayerZero versions. Send/Receive can be different versions during migration
    function setSendVersion(uint16 version) external;
    function setReceiveVersion(uint16 version) external;
    function getSendVersion() external view returns (uint16);
    function getReceiveVersion() external view returns (uint16);

    //---------------------------------------------------------------------------
    // Only in extreme cases where the UA needs to resume the message flow
    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external;
}




