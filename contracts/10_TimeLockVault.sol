// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TimeLockVault {
    address payable public beneficiary;
    uint256 public unlockTime;
    bool private locked;
    event Deposited(address indexed from, uint256 amount, uint256 newUnlockTime);
    event Withdrawn(address indexed to, uint256 amount);
    event LockExtended(uint256 newUnlockTime);

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Not the beneficiary");
        _;
    }

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor(address payable _beneficiary, uint256 _lockSeconds) {
        require(_beneficiary != address(0), "Zero beneficiary");
        beneficiary = _beneficiary;
        unlockTime = block.timestamp + _lockSeconds;
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit is zero");
        emit Deposited(msg.sender, msg.value, unlockTime);
    }

    function extendLock(uint256 _extraSeconds) external onlyBeneficiary {
        require(_extraSeconds > 0, "Extension is zero");
        unlockTime += _extraSeconds;
        emit LockExtended(unlockTime);
    }

    function withdraw() external onlyBeneficiary nonReentrant {
        require(block.timestamp >= unlockTime, "Vault is still locked");
        uint256 amount = address(this).balance;
        require(amount > 0, "Vault is empty");
        emit Withdrawn(beneficiary, amount);
        (bool success, ) = beneficiary.call{value: amount}("");
        require(success, "ETH transfer failed");
    }

    function timeRemaining() external view returns (uint256) {
        return block.timestamp >= unlockTime ? 0 : unlockTime - block.timestamp;
    }
}
