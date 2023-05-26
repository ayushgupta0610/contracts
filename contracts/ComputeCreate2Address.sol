pragma solidity ^0.8.12;

contract Vault {

    mapping(address => uint256) public depositor_balance;

    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function deposit() external payable {
        depositor_balance[msg.sender] += msg.value;
    }

    function withdraw() external {
        depositor_balance[msg.sender] = 0;
        uint256 balance = depositor_balance[msg.sender];
        msg.sender.call{ value: balance }("");
    }

}

contract VaultFactory {

    event Deployed(address addr, uint salt);

    function getBytecode(address _owner) external pure returns (bytes memory) {
        bytes memory bytecode = type(Vault).creationCode;

        return abi.encodePacked(bytecode, abi.encode(_owner));
    }

    function getAddress(uint256 _salt, bytes calldata _bytecode) external view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(_bytecode)));
        // Note: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }

    function deploy(bytes memory bytecode, uint _salt) public payable {
        address addr;
        /*
        NOTE: How to call create2

        create2(v, p, n, s)
        create new contract with code at memory p to p + n
        and send v wei
        and return the new address
        where new address = first 20 bytes of keccak256(0xff + address(this) + s + keccak256(mem[pâ¦(p+n)))
              s = big-endian 256-bit value
        */
        assembly {
            addr := create2(
                callvalue(), // wei sent with current call
                // Actual code starts after skipping the first 32 bytes
                add(bytecode, 0x20),
                mload(bytecode), // Load the size of code contained in the first 32 bytes
                _salt // Salt from function arguments
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
        emit Deployed(addr, _salt);
    }

}
