// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleNFT {
    string public name;
    string public symbol;
    address public owner;
    uint256 public nextTokenId;
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public mintPrice = 0.01 ether;
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public approvals;
    bool private locked;
    event Minted(address indexed to, uint256 indexed tokenId);
    event TransferNFT(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approved(address indexed spender, uint256 indexed tokenId);
    event PaymentsWithdrawn(address indexed to, uint256 amount);

    modifier onlyOwner() { require(msg.sender == owner, "Not the owner"); _; }

    constructor(string memory _name, string memory _symbol) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
    }

    function mint() external payable returns (uint256) {
        require(msg.value == mintPrice, "Incorrect mint price");
        require(nextTokenId < MAX_SUPPLY, "Max supply reached");
        uint256 tokenId = nextTokenId++;
        ownerOf[tokenId] = msg.sender;
        balances[msg.sender] += 1;
        emit Minted(msg.sender, tokenId);
        emit TransferNFT(address(0), msg.sender, tokenId);
        return tokenId;
    }

    function transferNFT(address to, uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "Not the token owner");
        _transfer(msg.sender, to, tokenId);
    }

    function approve(address spender, uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "Not the token owner");
        approvals[tokenId] = spender;
        emit Approved(spender, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        require(from != address(0) && ownerOf[tokenId] == from, "Incorrect token owner");
        require(approvals[tokenId] == msg.sender, "Not the approved spender");
        _transfer(from, to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) private {
        require(to != address(0), "Zero recipient");
        delete approvals[tokenId];
        ownerOf[tokenId] = to;
        balances[from] -= 1;
        balances[to] += 1;
        emit TransferNFT(from, to, tokenId);
    }

    function withdrawPayments() external onlyOwner {
        require(!locked, "Reentrant call");
        uint256 amount = address(this).balance;
        require(amount > 0, "No payments");
        locked = true;
        emit PaymentsWithdrawn(owner, amount);
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "ETH transfer failed");
        locked = false;
    }
}
