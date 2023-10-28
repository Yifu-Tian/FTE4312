// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract GuessGame {
    struct Player {
        address addr;
        bytes32 commit;
        uint8 revealedNumber;
        uint8 announcedNumber;
        bool ifChallenge;
        bool hasCommitted;
        bool hasChallenged;
        bool hasRevealed;
        uint8 score;   
    }

    Player public player1;
    Player public player2;
    uint8 public round = 1;  // Initialized during contract creation

    constructor(address _player1_addr,address _player2_addr) {
        player1.addr = _player1_addr; 
        player2.addr = _player2_addr;
    }
    // Ensure that the game is not over
    modifier gameNotOver() {
        require(round <= 3, "Game over");
        _;
    }
    // Ensure that the sender is a valid player
    modifier validPlayer() {
        require(msg.sender == player1.addr || msg.sender == player2.addr, "Invalid player address");
        _;
    }
    function commitNumber(uint8 _chosenNumber, uint8 _announcedNumber) external gameNotOver validPlayer{
        require(_chosenNumber >= 1 && _chosenNumber <= 10, "Invalid chosenNumber");
        require(_announcedNumber >= 1 && _announcedNumber <= 10, "Invalid announcedNumber");
        Player storage currentPlayer = (msg.sender == player1.addr) ? player1 : player2;
        require(!currentPlayer.hasCommitted, "You already have committed");
        currentPlayer.commit = keccak256(abi.encodePacked(_chosenNumber));
        currentPlayer.announcedNumber = _announcedNumber;
        currentPlayer.hasCommitted = true;
    }

    function challenge(bool _ifChanllge) external gameNotOver validPlayer{
        require(player1.hasCommitted && player2.hasCommitted, "Both players should finish committing numbers");// you should commit numbers first
        Player storage currentPlayer = (msg.sender == player1.addr) ? player1 : player2;
        require(!currentPlayer.hasCommitted, "You already have committed");
        currentPlayer.ifChallenge = _ifChanllge;
        currentPlayer.hasChallenged = true;
    }

    function revealNumber_and_calculateScores(uint8 _number) external gameNotOver validPlayer{
        require(_number >= 1 && _number <= 10, "Invalid number");
        require(player1.hasChallenged && player2.hasChallenged, "Both players should finish challenging");
        Player storage currentPlayer = (msg.sender == player1.addr) ? player1 : player2;
        require(!currentPlayer.hasRevealed, "You already have revealed");
        require(keccak256(abi.encodePacked(_number)) == currentPlayer.commit, "Invalid reveal");
        currentPlayer.hasRevealed = true;
        currentPlayer.revealedNumber = _number;

        // Score calculation logic
        calculateScores();

        // Refresh the game state for next round if both players have revealed their numbers
        if (player1.hasRevealed && player2.hasRevealed) {
            resetForNextRound();
        }
    }
    function calculateScores() private {
        Player storage challengingPlayer = player1.ifChallenge ? player1 : player2;
        Player storage otherPlayer = player1.ifChallenge ? player2 : player1;

        if (challengingPlayer.revealedNumber == challengingPlayer.announcedNumber) {
            if(otherPlayer.ifChallenge){challengingPlayer.score += 1;}
            else {otherPlayer.score += 1;}
        } else {
            if (otherPlayer.ifChallenge){otherPlayer.score += 2;}
            else {challengingPlayer.score += 2}
        }
    }
    function resetForNextRound() private {
        round++;
        resetPlayer(player1);
        resetPlayer(player2);
    }
    function resetPlayer(Player storage player) private {
        player.hasCommitted = false;
        player.hasChallenged = false;
        player.hasRevealed = false;
        player.ifChallenge = false;
        player.revealedNumber = 0;
        player.announcedNumber = 0;
        player.commit = 0;
    }
    function getWinner() external view returns (address) {
        require(round > 3, "Game is not over yet");
        if (player1.score > player2.score) {
            return player1.addr;
        } else if (player1.score < player2.score) {
            return player2.addr;
        } else {
            return address(0);  // It's a tie
        }
    }
}