// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UserManagement.sol";

contract Betting {
    address public admin;
    uint public entryFee;
    UserManagement public userManager;

    struct Bet {
        uint matchId;
        address bettor;
        uint predictedScoreTeamA;
        uint predictedScoreTeamB;
        uint amount;
    }

    struct Match {
        uint matchId;
        uint scoreTeamA;
        uint scoreTeamB;
        bool isFinished;
    }

    struct WinnerInfo {
        address bettor;
        uint accuracy; 
    }


    mapping(uint => Bet[]) public betsByMatch;
    mapping(uint => Match) public matches;
    mapping(uint => WinnerInfo[]) public matchWinners;
    mapping(uint => mapping(address => bool)) public hasUserBetOnMatch;

    event BetPlaced(uint matchId, address bettor, uint predictedScoreTeamA, uint predictedScoreTeamB, uint amount);
    event MatchAdded(uint matchId, uint scoreTeamA, uint scoreTeamB);
    event MatchUpdated(uint matchId, uint scoreTeamA, uint scoreTeamB);
    event MatchDeleted(uint matchId);
    event MatchResultDeclared(uint matchId, uint scoreTeamA, uint scoreTeamB);
    event WinnerDeclared(uint matchId, address winner, uint accuracy);
    event PotentialWinnersUpdated(uint matchId);
    event WinningsDistributed(uint matchId, uint prizePerWinner);
    event EntryFeeUpdated(uint newEntryFee);

    constructor(address _userManagerAddress, uint _entryFee) {
        admin = msg.sender;
        userManager = UserManagement(_userManagerAddress);
        entryFee = _entryFee;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    function addMatch(uint _matchId, uint _scoreTeamA, uint _scoreTeamB) external onlyAdmin {
        require(matches[_matchId].matchId == 0, "Match already exists.");
        
        matches[_matchId] = Match({
            matchId: _matchId,
            scoreTeamA: _scoreTeamA,
            scoreTeamB: _scoreTeamB,
            isFinished: false
        });

        emit MatchAdded(_matchId, _scoreTeamA, _scoreTeamB);
    }

    function updateMatch(uint _matchId, uint _scoreTeamA, uint _scoreTeamB, bool _isFinished) external onlyAdmin {
        require(matches[_matchId].matchId != 0, "Match does not exist.");
        
        matches[_matchId].scoreTeamA = _scoreTeamA;
        matches[_matchId].scoreTeamB = _scoreTeamB;
        matches[_matchId].isFinished = _isFinished;

        emit MatchUpdated(_matchId, _scoreTeamA, _scoreTeamB);
    }

    function deleteMatch(uint _matchId) external onlyAdmin {
        require(matches[_matchId].matchId != 0, "Match does not exist.");
        
        delete matches[_matchId];

        emit MatchDeleted(_matchId);
    }

    function placeBet(uint _matchId, uint _predictedScoreTeamA, uint _predictedScoreTeamB) external payable {
        require(msg.value == entryFee, "Incorrect entry fee.");
        require(matches[_matchId].matchId != 0, "Match does not exist.");
        require(!matches[_matchId].isFinished, "Betting for this match has ended.");
        require(!hasUserBetOnMatch[_matchId][msg.sender], "User has already placed a bet on this match.");

        Bet memory newBet = Bet({
            matchId: _matchId,
            bettor: msg.sender,
            predictedScoreTeamA: _predictedScoreTeamA,
            predictedScoreTeamB: _predictedScoreTeamB,
            amount: msg.value
        });

        betsByMatch[_matchId].push(newBet);
        hasUserBetOnMatch[_matchId][msg.sender] = true;

        emit BetPlaced(_matchId, msg.sender, _predictedScoreTeamA, _predictedScoreTeamB, msg.value);
    }

    function updateEntryFee(uint _newEntryFee) external onlyAdmin {
        entryFee = _newEntryFee;

        emit EntryFeeUpdated(_newEntryFee);
    }

    function checkUserBet(uint _matchId, address _user) public view returns (bool) {
        return hasUserBetOnMatch[_matchId][_user];
    }

    function finalizeMatch(uint _matchId, uint _scoreTeamA, uint _scoreTeamB) external onlyAdmin {
        require(matches[_matchId].matchId != 0, "Match does not exist.");
        require(!matches[_matchId].isFinished, "Match is already finished.");

        matches[_matchId].scoreTeamA = _scoreTeamA;
        matches[_matchId].scoreTeamB = _scoreTeamB;
        matches[_matchId].isFinished = true;

        emit MatchResultDeclared(_matchId, _scoreTeamA, _scoreTeamB);
    }

    function selectWinners(uint _matchId) internal {
        require(matches[_matchId].isFinished, "Match not finished.");
        WinnerInfo[] memory sortedWinners = new WinnerInfo[](matchWinners[_matchId].length);
        uint winnersCount = 0;

        winnersCount = sortedWinners.length < 5 ? sortedWinners.length : 5;

        for (uint i = 0; i < winnersCount; i++) {
            emit WinnerDeclared(_matchId, sortedWinners[i].bettor, sortedWinners[i].accuracy);
        }
    }

function distributeWinnings(uint _matchId) public onlyAdmin {
    require(matches[_matchId].isFinished, "Match not finished.");
    uint totalPrize = address(this).balance;
    
    // Assumant que selectWinners a déjà trié et sélectionné les gagnants
    uint winnersToPay = matchWinners[_matchId].length < 5 ? matchWinners[_matchId].length : 5;
    uint prizePerWinner = totalPrize / winnersToPay;

    for (uint i = 0; i < winnersToPay; i++) {
        address payable winnerAddress = payable(matchWinners[_matchId][i].bettor);
        (bool sent, ) = winnerAddress.call{value: prizePerWinner}("");
        require(sent, "Failed to send Ether");
    }

    emit WinningsDistributed(_matchId, prizePerWinner);
}

}