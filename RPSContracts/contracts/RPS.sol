//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RPS {
    using SafeMath for uint;

    ERC20 private token;
    address public lastWinner;
    uint public gamePlayed;
    
    struct PlayerInfo {
        uint8 move;
        uint amount;
        address addr;
        bool exist;
    }
    mapping (address => PlayerInfo) private move;

    event TheWinnerIs(address winner);
    event MoveSet(address player);

    constructor (address coin) {
        token = ERC20(coin);
    }

    function setMove (uint8 _move, uint _amount) public {
        require(_move == 0 || _move == 1 || _move == 2, "Invalid move");
        require(_amount >= 0, "Minimun 0 token to bet");
        require(move[msg.sender].exist == false, "Move already given");
        move[msg.sender] = PlayerInfo(_move, _amount, msg.sender, true);
        token.transferFrom(msg.sender, address(this), _amount);
        emit MoveSet(msg.sender);
    }

    function withdraw() public {
        token.transfer(msg.sender, move[msg.sender].amount);
        delete move[msg.sender];
    }

    function seeMove() public view returns (PlayerInfo memory) {
        return move[msg.sender];
    }

    function deleteMoves(address p1, address p2) private {
        delete move[p1];
        delete move[p2];
    }

    function payRewards(address winner, address loser) private {
        PlayerInfo memory playerOne = move[winner];
        PlayerInfo memory playerTwo = move[loser];
        move[winner].amount = 0;
        move[loser].amount = 0;
        token.transfer(winner, (playerOne.amount.add(playerTwo.amount)));
    }

    function draw(address p1, address p2) private {
        PlayerInfo memory playerOne = move[p1];
        PlayerInfo memory playerTwo = move[p2];
        move[p1].amount = 0;
        move[p2].amount = 0;
        token.transfer(p1, (playerOne.amount));
        token.transfer(p2, (playerTwo.amount));
        
    }

    function play(address opponent) public {
        require(move[msg.sender].exist == true, "msg.sender didnt set a move");
        require(move[opponent].exist == true, "opponent didnt set a move");
        require(msg.sender != opponent, "You cannot play against yourself");
        PlayerInfo memory playerOne = move[msg.sender];
        PlayerInfo memory playerTwo = move[opponent];
        if ((playerOne.move + 1) % 3 == playerTwo.move) {
            lastWinner = playerTwo.addr;
            payRewards(playerTwo.addr, playerOne.addr);
        } else if (playerOne.move == playerTwo.move) {
            lastWinner = address(0);
            draw(playerOne.addr, playerTwo.addr);
        } else {
            lastWinner = playerOne.addr;
            payRewards(playerOne.addr, playerTwo.addr);
            
        }
        deleteMoves(playerOne.addr, playerTwo.addr);
        emit TheWinnerIs(lastWinner);
    }
}
