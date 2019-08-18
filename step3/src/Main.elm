module Main exposing (main)

import AnaQRam.Puzzle as Puzzle exposing (Piece, Puzzle)
import AnaQRam.QRCode as QRCode exposing (QRCode)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode exposing (Error, errorToString)


main : Program Config Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Config =
    { ids : { video : String, capture : String }
    , size : { width : Int, height : Int }
    }


type alias Model =
    { config : Config
    , error : String -- JSONのデコード失敗結果
    , puzzle : Puzzle
    , click : Maybe Int
    }


init : Config -> ( Model, Cmd Msg )
init config =
    ( Model config "" Puzzle.empty Nothing
    , Puzzle.shuffle ShufflePuzzle (Puzzle.init "あなくらむ！" Puzzle.empty)
    )


type Msg
    = EnableCamera
    | CaptureImage
    | UpdateQRCode (Result Error (Maybe QRCode))
    | ClickPiece Int
    | ShufflePuzzle Puzzle


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnableCamera ->
            ( model, QRCode.startCamera () )

        CaptureImage ->
            ( model, QRCode.captureImage () )

        UpdateQRCode (Ok Nothing) ->
            ( { model | error = "QR code is not found" }, Cmd.none )

        UpdateQRCode (Ok (Just qrcode)) ->
            let
                updated =
                    String.toInt qrcode.data
                        |> Maybe.map (\idx -> Puzzle.display idx model.puzzle)
                        |> Maybe.withDefault model.puzzle
            in
            ( { model | error = "", puzzle = updated }, Cmd.none )

        UpdateQRCode (Err message) ->
            ( { model | error = errorToString message }, Cmd.none )

        ClickPiece idx ->
            updatePiece idx model

        ShufflePuzzle puzzle ->
            ( { model | puzzle = puzzle }, Cmd.none )


updatePiece : Int -> Model -> ( Model, Cmd Msg )
updatePiece idx model =
    case model.click of
        Nothing ->
            ( { model | click = Just idx }, Cmd.none )

        Just oldIdx ->
            let
                updated =
                    Puzzle.swapPiece idx oldIdx model.puzzle
            in
            ( { model | click = Nothing, puzzle = updated }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ video
            [ id model.config.ids.video
            , style "background-color" "#000"
            , autoplay True
            , width model.config.size.width
            , height model.config.size.height
            , attribute "playsinline" "" -- iOS のために必要
            ]
            []
        , p [] [ button [ onClick EnableCamera ] [ text "Enable Camera" ] ]
        , p [] [ button [ onClick CaptureImage ] [ text "Decode QR" ] ]
        , canvas [ id model.config.ids.capture, hidden True ] [] -- カメラ画像退避用
        , viewPuzzle model
        , viewResult model
        ]


viewPuzzle : Model -> Html Msg
viewPuzzle model =
    p [] (Puzzle.map (viewPiece model) model.puzzle)


viewPiece : Model -> Int -> Piece -> Html Msg
viewPiece model viewIdx piece =
    button [ onClick (ClickPiece viewIdx) ] [ text (Puzzle.pieceToString piece) ]


viewResult : Model -> Html Msg
viewResult model =
    case ( Puzzle.success model.puzzle, model.error ) of
        ( True, _ ) ->
            p [] [ text "Success!" ]

        ( _, "" ) ->
            p [] []

        _ ->
            p [] [ text model.error ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    QRCode.updateQRCodeWithDecode UpdateQRCode
