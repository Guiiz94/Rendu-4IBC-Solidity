// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Betting.sol";

contract Administration {
    Betting bettingContract;
    address public admin;

    constructor(address _bettingAddress) {
        bettingContract = Betting(_bettingAddress);
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can call this function.");
        _;
    }

    function addMatch(uint _matchId, uint _scoreTeamA, uint _scoreTeamB) external onlyAdmin {
        bettingContract.addMatch(_matchId, _scoreTeamA, _scoreTeamB);
    }

    function updateMatch(uint _matchId, uint _scoreTeamA, uint _scoreTeamB, bool _isFinished) external onlyAdmin {
        bettingContract.updateMatch(_matchId, _scoreTeamA, _scoreTeamB, _isFinished);
    }

    function deleteMatch(uint _matchId) external onlyAdmin {
        bettingContract.deleteMatch(_matchId);
    }

    function distributeWinnings(uint _matchId) external onlyAdmin {
        bettingContract.distributeWinnings(_matchId);
    }

    function updateEntryFee(uint _newEntryFee) external onlyAdmin {
        bettingContract.updateEntryFee(_newEntryFee);
    }

    function finalizeMatch(uint _matchId, uint _scoreTeamA, uint _scoreTeamB) external onlyAdmin {
        bettingContract.finalizeMatch(_matchId, _scoreTeamA, _scoreTeamB);
    }
}
