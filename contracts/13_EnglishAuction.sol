// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EnglishAuction {
    address payable public seller;
    uint256 public auctionEnd;
    address public highestBidder;
    uint256 public highestBid;
    uint256 public constant MIN_INCREMENT = 5;
    mapping(address => uint256) public pendingReturns;
    bool public ended;
    bool private locked;
    event NewBid(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event PendingWithdrawn(address indexed bidder, uint256 amount);

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor(uint256 _biddingSeconds, uint256 _startPrice) {
        require(_biddingSeconds > 0 && _startPrice > 0, "Invalid auction");
        seller = payable(msg.sender);
        auctionEnd = block.timestamp + _biddingSeconds;
        highestBid = _startPrice;
    }

    function bid() external payable nonReentrant {
        require(!ended && block.timestamp < auctionEnd, "Auction ended");
        
        uint256 increment = highestBid / 100 * MIN_INCREMENT;
        increment += ((highestBid % 100) * MIN_INCREMENT + 99) / 100;
        require(msg.value >= highestBid + increment, "Bid increment below 5 percent");
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit NewBid(msg.sender, msg.value);
    }

    function withdrawPending() external nonReentrant returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "Nothing to withdraw");
        pendingReturns[msg.sender] = 0;
        emit PendingWithdrawn(msg.sender, amount);
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Refund transfer failed");
        return true;
    }

    function endAuction() external nonReentrant {
        require(block.timestamp >= auctionEnd, "Auction still active");
        require(!ended, "Already ended");
        ended = true;
        uint256 amount = highestBidder == address(0) ? 0 : highestBid;
        emit AuctionEnded(highestBidder, amount);
        if (amount > 0) {
            (bool success, ) = seller.call{value: amount}("");
            require(success, "Seller payment failed");
        }
    }
}
