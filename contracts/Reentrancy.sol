// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;



contract ETHBank {
    mapping(address => uint) public balances;
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external payable {
        (bool sent, ) = msg.sender.call{value: balances[msg.sender]}("");
        require(sent, "failed to send ETH");

        balances[msg.sender] = 0;
    }
}