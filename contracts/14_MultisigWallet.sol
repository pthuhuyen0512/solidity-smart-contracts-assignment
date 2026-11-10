// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultisigWallet {
    address[] public owners;
    uint256 public required;
    struct Transaction { address to; uint256 value; bool executed; }
    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmed;
    mapping(address => bool) public isOwner;
    mapping(uint256 => uint256) private confirmationCounts;
    bool private locked;
    event Submission(uint256 indexed txId);
    event Confirmation(address indexed owner, uint256 indexed txId);
    event Execution(uint256 indexed txId);
    event Deposit(address indexed sender, uint256 amount);

    modifier onlyOwner() { require(isOwner[msg.sender], "Not an owner"); _; }
    modifier validTransaction(uint256 txId) {
        require(txId < transactions.length, "Invalid transaction");
        require(!transactions[txId].executed, "Already executed");
        _;
    }
    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_required > 0 && _required <= _owners.length, "Invalid threshold");
        for (uint256 i = 0; i < _owners.length; i++) {
            address account = _owners[i];
            require(account != address(0), "Zero owner");
            require(!isOwner[account], "Duplicate owner");
            isOwner[account] = true;
            owners.push(account);
        }
        required = _required;
    }

    receive() external payable { emit Deposit(msg.sender, msg.value); }

    function submitTransaction(address to, uint256 value) external onlyOwner nonReentrant {
        require(to != address(0), "Zero recipient");
        require(value > 0, "Value is zero");
        uint256 txId = transactions.length;
        transactions.push(Transaction(to, value, false));
        emit Submission(txId);
        _confirm(txId);
    }

    function confirmTransaction(uint256 txId)
        external onlyOwner nonReentrant validTransaction(txId)
    {
        _confirm(txId);
    }

    function _confirm(uint256 txId) private {
        require(!confirmed[txId][msg.sender], "Already confirmed");
        confirmed[txId][msg.sender] = true;
        confirmationCounts[txId] += 1;
        emit Confirmation(msg.sender, txId);
        if (confirmationCounts[txId] >= required) _execute(txId);
    }

    function executeTransaction(uint256 txId)
        external onlyOwner nonReentrant validTransaction(txId)
    {
        _execute(txId);
    }

    function _execute(uint256 txId) private {
        Transaction storage transaction = transactions[txId];
        require(!transaction.executed, "Already executed");
        require(confirmationCounts[txId] >= required, "Not enough confirmations");
        require(address(this).balance >= transaction.value, "Insufficient wallet balance");
        transaction.executed = true;
        emit Execution(txId);
        (bool success, ) = payable(transaction.to).call{value: transaction.value}("");
        require(success, "ETH transfer failed");
    }

    function getConfirmations(uint256 txId) external view returns (uint256) {
        require(txId < transactions.length, "Invalid transaction");
        return confirmationCounts[txId];
    }
}
