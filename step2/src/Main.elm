module Main exposing (main)

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
    , qrcode : Maybe QRCode -- QRコードのデコード結果
    , error : String -- JSONのデコード失敗結果
    }


init : Config -> ( Model, Cmd Msg )
init config =
    ( Model config Nothing "", Cmd.none )


type Msg
    = EnableCamera
    | CaptureImage
    | UpdateQRCode (Result Error (Maybe QRCode))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnableCamera ->
            ( model, QRCode.startCamera () )

        CaptureImage ->
            ( model, QRCode.captureImage () )

        -- QRコードがなかった場合(null が返ってくるので)
        UpdateQRCode (Ok Nothing) ->
            ( { model | error = "QR code is not found" }, Cmd.none )

        -- QRコードのデコード成功
        UpdateQRCode (Ok qrcode) ->
            ( { model | qrcode = qrcode, error = "" }, Cmd.none )

        -- JSONのデコード失敗
        UpdateQRCode (Err message) ->
            ( { model | error = errorToString message }, Cmd.none )


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
        , viewResult model
        ]


viewResult : Model -> Html Msg
viewResult model =
    if String.isEmpty model.error then
        p [] [ text ("QR code: " ++ Maybe.withDefault "" (Maybe.map .data model.qrcode)) ]

    else
        p [] [ text model.error ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    QRCode.updateQRCodeWithDecode UpdateQRCode
