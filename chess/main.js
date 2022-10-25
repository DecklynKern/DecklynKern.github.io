var current_turn = "w";
var castling_rights = [true, true, true, true];
var en_passant_chance = null;
var board_fen;
var possible_moves = [];

var player_is_computer = [false, true];
var selected_square = null;
var selected_piece_possible_moves = [];

var white_square_colour = "wheat";
var black_square_colour = "darkblue";
var selected_square_colour = "red";
var possible_move_square_colour = "lightblue";

var getPossibleMoves;
var playEngineMove;
var playHumanMove;

function colourSquare(square, row, col) {
    if ((row + col) % 2 == 0) {
        square.style.backgroundColor = white_square_colour;

    } else {
        square.style.backgroundColor = black_square_colour;
    }
}

function clearPossibleMoveSquares() {

    var board = document.getElementById("chess-board");

    for (var p = 0; p < selected_piece_possible_moves.length; p++) {
        [_, row, col] = selected_piece_possible_moves[p];
        colourSquare(board.children[row].children[col], row, col);
    }

    selected_piece_possible_moves = [];
}

function clearSelectedSquare() {

    var board = document.getElementById("chess-board");

    if (selected_square != null) {
        colourSquare(board.children[selected_square[0]].children[selected_square[1]], ...selected_square);
    }
}

function setupBoard() {

    var board = document.getElementById("chess-board");

    function getOnClick(row, col) {

        return function(ev) {

            for (var p = 0; p < selected_piece_possible_moves.length; p++) {
                var possible_move = selected_piece_possible_moves[p];
                if (row == possible_move[1] && col == possible_move[2]) {
                    clearSelectedSquare();
                    selected_square = null;
                    clearPossibleMoveSquares();
                    setToFen(playHumanMove(board_fen, possible_move[0]));
                    return;
                }
            }

            if (ev.target.className == "board-square") {
                ev.target.style.backgroundColor = selected_square_colour;

            } else {
                ev.target.parentElement.style.backgroundColor = selected_square_colour;
            }

            clearSelectedSquare();
            clearPossibleMoveSquares();

            if (selected_square != null && (selected_square[0] == row && selected_square[1] == col)) {
                selected_square = null;

            } else {

                selected_square = [row, col];
            
                for (var p = 0; p < possible_moves.length; p++) {

                    var possible_move = possible_moves[p];

                    if (rowColToLongAn(row, col) == possible_move.slice(0, 2)) {

                        [endRow, endCol] = longAnToRowCol(possible_move.slice(2, 4));
                        var possible_square = board.children[endRow].children[endCol];
                        selected_piece_possible_moves.push([possible_move, endRow, endCol]);
                        possible_square.style.backgroundColor = possible_move_square_colour;

                    }
                }
            }
        }
    }

    for (var row = 0; row < 8; row++) {
    
        var rank = document.createElement("div");
        rank.className = "rank";
        board.appendChild(rank);
    
        for (var col = 0; col < 8; col++) {
    
            var square = document.createElement("div");
            square.className = "board-square";
    
            colourSquare(square, row, col);
            square.onmousedown = getOnClick(row, col);
            rank.appendChild(square);
    
        }
    }
}

function setToFen(fen) {
    
    var board = document.getElementById("chess-board");
    board_fen = fen;

    for (var row = 0; row < 8; row++) {
        for (var col = 0; col < 8; col++) {
            board.children[row].children[col].innerHTML = "";
        }
    }

    var row = 0;
    var col = 0;
    
    var addPiece = function(row, col, src, pieceName) {
        var img = document.createElement("img");
        img.classList.add("chess-piece")
        img.classList.add(pieceName);
        img.src = "images/" + src + ".png";
        board.children[row].children[col].appendChild(img);   
    }
    
    var done = false;
    
    for (var char = 0; char < fen.length; char++) {
    
        if (done) {
            break;
        }
    
        switch (fen[char]) {
            case "P":
                addPiece(row, col, "white_pawn", "P");
                break;
            case "p":
                addPiece(row, col, "black_pawn", "p");
                break;
            case "N":
                addPiece(row, col, "white_knight", "N");
                break;
            case "n":
                addPiece(row, col, "black_knight", "n");
                break;
            case "B":
                addPiece(row, col, "white_bishop", "B");
                break;
            case "b":
                addPiece(row, col, "black_bishop", "b");
                break;
            case "R":
                addPiece(row, col, "white_rook", "R");
                break;
            case "r":
                addPiece(row, col, "black_rook", "r");
                break;
            case "Q":
                addPiece(row, col, "white_queen", "Q");
                break;
            case "q":
                addPiece(row, col, "black_queen", "q");
                break;
            case "K":
                addPiece(row, col, "white_king", "K");
                break;
            case "k":
                addPiece(row, col, "black_king", "k");
                break;
            case "/":
                row += 1;
                col = -1;
                break;
            case " ":
                done = true;
                break;
            default:
                col += fen[char] - 1;
        }
        
        col += 1;
    
    }

    current_turn = fen[char];
    
    if (current_turn == "w") {

        if (player_is_computer[0]) {
            playEngineMove(board_fen);

        } else {
            possible_moves = getPossibleMoves(board_fen);
        }

    } else {

        if (player_is_computer[1]) {
            playEngineMove(board_fen);

        } else {
            possible_moves = getPossibleMoves(board_fen);
        }

    }

}

function longAnToRowCol(pos) {
    return [8 - pos[1], pos.charCodeAt(0) - 97];
}

function rowColToLongAn(row, col) {
    return String.fromCharCode(97 + col) + (8 - row)
}

/*
function getBoardFen() {

    var board = document.getElementById("chess-board");
    var fen = "";

    for (var row = 0; row < 8; row++) {

        if (row != 0) {
            fen += "/";
        }

        var spaces = 0;

        for (var col = 0; col < 8; col++) {

            var children = board.children[row].children[col].children;

            if (children.length == 0) {
                spaces += 1;
                continue;
            }

            if (spaces > 0) {
                fen += spaces;
                spaces = 0;
            }

            fen += children[0].classList[1];

        }

        if (spaces != 0) {
            fen += spaces;
        }

    }

    return fen + " " + current_turn + " " + castling_rights + " - 0 1";

}

function playMove(move) {

    [row1, col1] = longAnToRowCol(move);
    [row2, col2] = longAnToRowCol(move.slice(2, 4));

    var board = document.getElementById("chess-board");

    [board.children[row1].children[col1].innerHTML, board.children[row2].children[col2].innerHTML] = ["", board.children[row1].children[col1].innerHTML];

    if (current_turn == "w") {
        current_turn = "b";
    } else {
        current_turn = "w";
    }

    board_fen = getBoardFen();
    possible_moves = getPossibleMoves(board_fen);

}*/