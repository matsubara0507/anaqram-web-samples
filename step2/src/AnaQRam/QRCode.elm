port module AnaQRam.QRCode exposing (QRCode, captureImage, decoder, startCamera, updateQRCode, updateQRCodeWithDecode)

import Json.Decode as D exposing (Decoder)
import Json.Encode as E


type alias QRCode =
    { data : String }


decoder : Decoder QRCode
decoder =
    D.map QRCode (D.field "data" D.string)


port startCamera : () -> Cmd msg


port captureImage : () -> Cmd msg


port updateQRCode : (E.Value -> msg) -> Sub msg


updateQRCodeWithDecode : (Result D.Error (Maybe QRCode) -> msg) -> Sub msg
updateQRCodeWithDecode msg =
    updateQRCode (msg << D.decodeValue (D.nullable decoder))
