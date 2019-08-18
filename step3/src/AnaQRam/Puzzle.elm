module AnaQRam.Puzzle exposing (Piece, Puzzle, display, displayPiece, empty, init, map, pieceToString, shuffle, size, success, swapPiece)

import Array exposing (Array)
import Random
import Random.Array as Array


type alias Puzzle =
    { pieces : Array Piece
    , answer : String
    }


type alias Piece =
    { hidden : Bool -- 伏字のオンオフ
    , index : Int -- 元の位置
    , char : Char
    }


success : Puzzle -> Bool
success puzzle =
    if String.isEmpty puzzle.answer then
        False

    else
        Array.map pieceToString puzzle.pieces
            |> Array.toList
            |> String.concat
            |> (==) puzzle.answer


pieceToString : Piece -> String
pieceToString piece =
    if piece.hidden then
        "？"

    else
        String.fromChar piece.char


display : Int -> Puzzle -> Puzzle
display idx puzzle =
    let
        pIdx =
            modBy (size puzzle) idx

        updated =
            Array.map (displayPiece pIdx) puzzle.pieces
    in
    { puzzle | pieces = updated }


displayPiece : Int -> Piece -> Piece
displayPiece idx piece =
    if piece.index == idx then
        { piece | hidden = False }

    else
        piece


size : Puzzle -> Int
size puzzle =
    Array.length puzzle.pieces


empty : Puzzle
empty =
    Puzzle Array.empty ""


map : (Int -> Piece -> a) -> Puzzle -> List a
map f puzzle =
    puzzle.pieces
        |> Array.indexedMap f
        |> Array.toList


swapPiece : Int -> Int -> Puzzle -> Puzzle
swapPiece idxA idxB puzzle =
    case ( Array.get idxA puzzle.pieces, Array.get idxB puzzle.pieces ) of
        ( Just pieceA, Just pieceB ) ->
            let
                updated =
                    puzzle.pieces
                        |> Array.set idxB pieceA
                        |> Array.set idxA pieceB
            in
            { puzzle | pieces = updated }

        _ ->
            puzzle


init : String -> Puzzle -> Puzzle
init answer puzzle =
    let
        pieces =
            String.toList answer
                |> Array.fromList
                |> Array.indexedMap (Piece True)
    in
    { puzzle | pieces = pieces, answer = answer }


shuffle : (Puzzle -> msg) -> Puzzle -> Cmd msg
shuffle toMsg puzzle =
    Random.generate
        (\updated -> toMsg { puzzle | pieces = updated })
        (Array.shuffle puzzle.pieces)
