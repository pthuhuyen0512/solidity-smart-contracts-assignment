// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StakingRewards {
    address payable public owner;
    uint256 public rewardRatePerSecond;
    uint256 public totalStaked;
    uint256 public rewardPool;
    struct Stake { uint256 amount; uint256 startTime; uint256 rewardDebt; }
    mapping(address => Stake) public stakes;

    uint256 public accumulatedRewardPerEther;
    uint256 public lastRewardUpdate;
    mapping(address => uint256) private userRewardCheckpoint;
    bool private locked;
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 principal, uint256 reward);
    event RewardClaimed(address indexed user, uint256 reward);
    event RewardsFunded(address indexed from, uint256 amount);
    event RewardRateChanged(uint256 oldRate, uint256 newRate);

    modifier onlyOwner() { require(msg.sender == owner, "Not the owner"); _; }
    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor(uint256 _rate) payable {
        owner = payable(msg.sender);
        rewardRatePerSecond = _rate;
        rewardPool = msg.value;
        lastRewardUpdate = block.timestamp;
        if (msg.value > 0) emit RewardsFunded(msg.sender, msg.value);
    }

    function _currentRewardIndex() private view returns (uint256) {
        return accumulatedRewardPerEther
            + rewardRatePerSecond * (block.timestamp - lastRewardUpdate);
    }

    function _updateGlobal() private {
        accumulatedRewardPerEther = _currentRewardIndex();
        lastRewardUpdate = block.timestamp;
    }

    function _updateUser(address user) private {
        _updateGlobal();
        Stake storage position = stakes[user];
        position.rewardDebt += position.amount
            * (accumulatedRewardPerEther - userRewardCheckpoint[user]) / 1 ether;
        userRewardCheckpoint[user] = accumulatedRewardPerEther;
        position.startTime = block.timestamp;
    }

    function stake() external payable nonReentrant {
        require(msg.value > 0, "Stake is zero");
        _updateUser(msg.sender);
        stakes[msg.sender].amount += msg.value;
        totalStaked += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    function pendingReward(address user) public view returns (uint256) {
        Stake storage position = stakes[user];
        return position.rewardDebt + position.amount
            * (_currentRewardIndex() - userRewardCheckpoint[user]) / 1 ether;
    }

    function unstake() external nonReentrant {
        require(stakes[msg.sender].amount > 0, "No active stake");
        _updateUser(msg.sender);
        uint256 principal = stakes[msg.sender].amount;
        uint256 reward = stakes[msg.sender].rewardDebt;
        require(reward <= rewardPool, "Insufficient reward pool");
        totalStaked -= principal;
        rewardPool -= reward;
        delete stakes[msg.sender];
        delete userRewardCheckpoint[msg.sender];
        emit Unstaked(msg.sender, principal, reward);
        (bool success, ) = payable(msg.sender).call{value: principal + reward}("");
        require(success, "ETH transfer failed");
    }

    function claimReward() external nonReentrant {
        require(stakes[msg.sender].amount > 0, "No active stake");
        _updateUser(msg.sender);
        uint256 reward = stakes[msg.sender].rewardDebt;
        require(reward > 0, "No reward");
        require(reward <= rewardPool, "Insufficient reward pool");
        stakes[msg.sender].rewardDebt = 0;
        rewardPool -= reward;
        emit RewardClaimed(msg.sender, reward);
        (bool success, ) = payable(msg.sender).call{value: reward}("");
        require(success, "ETH transfer failed");
    }

    function fundRewards() external payable onlyOwner nonReentrant {
        require(msg.value > 0, "Funding is zero");
        rewardPool += msg.value;
        emit RewardsFunded(msg.sender, msg.value);
    }

    function setRewardRate(uint256 _newRate) external onlyOwner nonReentrant {
        _updateGlobal();
        emit RewardRateChanged(rewardRatePerSecond, _newRate);
        rewardRatePerSecond = _newRate;
    }
}
