//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RPS {
    ERC20 private dai = ERC20(0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa);
    address public lastWinner;

    struct PlayerInfo {
        uint8 move;
        uint amount;
        address addr;
    }
    mapping (address => PlayerInfo) private move;

    event TheWinnerIs(address winner);
    event MoveSet(address player);

    function setMove (uint8 _move, uint _amount) public {
        require(_move == 0 || _move == 1 || _move == 2, "Invalid move");
        move[msg.sender] = PlayerInfo(_move, _amount, msg.sender);
        emit MoveSet(msg.sender);
    }

    function seeMove() public view returns (PlayerInfo memory) {
        return move[msg.sender];
    }

    function deleteMoves(address p1, address p2) private {
        delete move[p1];
        delete move[p2];
    }

    function play(address opponent) public {
        require(move[msg.sender].move < 4, "Player 1 move not declared");
        require(move[opponent].move < 4, "Player 2 move not declared");
        PlayerInfo memory playerOne = move[msg.sender];
        PlayerInfo memory playerTwo = move[opponent];
        if ((playerOne.move + 1) % 3 == playerTwo.move) {
            lastWinner = playerTwo.addr;
            emit TheWinnerIs(playerTwo.addr);
        } else if (playerOne.move == playerTwo.move) {
            lastWinner = address(0);
            emit TheWinnerIs(address(0));
        } else {
            lastWinner = playerOne.addr;
            emit TheWinnerIs(playerOne.addr);
        }
        deleteMoves(playerOne.addr, playerTwo.addr);
    }
}
