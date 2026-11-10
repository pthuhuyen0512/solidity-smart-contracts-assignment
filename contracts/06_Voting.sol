// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    struct Candidate { string name; uint256 voteCount; }
    struct Voter { bool authorized; bool voted; uint256 voteIndex; }
    Candidate[] public candidates;
    mapping(address => Voter) public voters;
    address public chairperson;
    event Authorized(address indexed voter);
    event Voted(address indexed voter, uint256 indexed candidateIndex);

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Not the chairperson");
        _;
    }

    constructor(string[] memory candidateNames) {
        require(candidateNames.length > 0, "No candidates");
        chairperson = msg.sender;
        for (uint256 i = 0; i < candidateNames.length; i++) {
            require(bytes(candidateNames[i]).length > 0, "Empty candidate name");
            candidates.push(Candidate(candidateNames[i], 0));
        }
    }

    function authorize(address voter) external onlyChairperson {
        require(voter != address(0), "Zero voter");
        require(!voters[voter].authorized, "Already authorized");
        voters[voter].authorized = true;
        emit Authorized(voter);
    }

    function vote(uint256 candidateIndex) external {
        Voter storage voter = voters[msg.sender];
        require(voter.authorized, "Not authorized");
        require(!voter.voted, "Already voted");
        require(candidateIndex < candidates.length, "Invalid candidate");
        voter.voted = true;
        voter.voteIndex = candidateIndex;
        candidates[candidateIndex].voteCount += 1;
        emit Voted(msg.sender, candidateIndex);
    }

    function totalVotes(uint256 candidateIndex) external view returns (uint256) {
        require(candidateIndex < candidates.length, "Invalid candidate");
        return candidates[candidateIndex].voteCount;
    }

    function winnerName() external view returns (string memory) {
        uint256 winner;
        for (uint256 i = 1; i < candidates.length; i++) {
            if (candidates[i].voteCount > candidates[winner].voteCount) winner = i;
        }
        return candidates[winner].name;
    }
}
