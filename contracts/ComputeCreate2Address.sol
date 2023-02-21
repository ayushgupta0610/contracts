// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DeployWithCreate2 {
    address public owner;
    address public deployer;

    constructor(address _owner, address _deployer) {
        owner = _owner;
        deployer = _deployer;
    }
}

pragma solidity ^0.8.0;

contract ComputeCreate2Address {
    function getContractAddress(
        address _factory,
        address _owner,
        uint _salt
    ) external view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(DeployWithCreate2).creationCode,
            abi.encode(_owner, msg.sender)
        );

        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), _factory, _salt, keccak256(bytecode))
        );

        return address(uint160(uint(hash)));
    }
}
