use chess;
use chess::player::Player;

use wasm_bindgen::prelude::*;
use wasm_bindgen::JsValue;
use web_sys::console;

#[wasm_bindgen]
extern {
    // javascript functions we might need to call in here
}

fn log(string: &str) {
    console::log_1(&JsValue::from_str(string));
}

#[wasm_bindgen]
pub fn get_possible_moves(fen: &str) -> Vec<JsValue> {

    let board = chess::game::Board::from_fen(String::from(fen));
    let possible_moves = chess::game::get_possible_moves(&board);

    return possible_moves.iter().map(|m| JsValue::from_str(m.to_long_an().as_str())).collect();

}

#[wasm_bindgen]
pub fn calc_engine_move(fen: &str) -> String {

    let mut board = chess::game::Board::from_fen(String::from(fen));
    let mut player: chess::player::AlphaBetaSearchPlayer = chess::player::AlphaBetaSearchPlayer::new(5, &chess::player::advanced_eval);
    
    let possible_moves = chess::game::get_possible_moves(&board);

    if let Some(legal_move) = player.get_move(&mut board, &possible_moves) {
        board.make_move(legal_move);
    }

    return board.to_fen();

}

#[wasm_bindgen]
pub fn play_human_move(start_fen: &str, human_move: &str) -> String {
    
    let move_string = String::from(human_move);

    let mut board = chess::game::Board::from_fen(String::from(start_fen));
    let possible_moves = chess::game::get_possible_moves(&board);

    for possible_move in possible_moves {
        if possible_move.to_long_an() == human_move {
            board.make_move(&possible_move);
            return board.to_fen();
        }
    }

    return board.to_fen();

}