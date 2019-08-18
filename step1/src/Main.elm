module Main exposing (main)

import AnaQRam.QRCode as QRCode
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


main : Program Config Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Config =
    { ids : { video : String }, size : { width : Int, height : Int } }


type alias Model =
    { config : Config }


init : Config -> ( Model, Cmd Msg )
init config =
    ( Model config, Cmd.none )


type Msg
    = EnableCamera


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnableCamera ->
            ( model, QRCode.startCamera () )


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
        ]
