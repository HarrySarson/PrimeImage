module ToNumberConfig.View exposing (view)

import Array
import Html exposing (Html, div, form, input, label, text)
import Html.Attributes exposing (attribute, class, classList, name, type_)
import Html.Events exposing (on)
import Json.Decode as Decode
import List
import ToNumberConfig.Types as Types


view : Types.Model -> Html Types.Msg
view model =
    let
        levelInputs =
            List.indexedMap
                (\level -> inputBox { msg = Types.SetLevel level, name = "level " ++ String.fromInt (level + 1) })
                (Array.toList model.levels)

        children =
            inputBox { msg = Types.SetWidth, name = "width" } model.width
                :: inputBox { msg = Types.SetHeight, name = "height" } model.height
                :: levelInputs
    in
    form
        [ class "to-number-config" ]
        children


inputBox : { msg : String -> msg, name : String } -> Types.Errorable -> Html msg
inputBox { msg, name } errorable =
    let
        isError =
            case errorable.error of
                Just _ ->
                    True

                Nothing ->
                    False
    in
    label
        [ classList
            [ ( "error-in-field", isError )
            ]
        ]
        [ text name
        , input
            [ type_ "text"
            , class "to-number-config-input"
            , attribute "data-input-name" name
            , on
                "input"
                (Decode.map msg (Decode.at [ "target", "value" ] Decode.string))
            ]
            []
        ]
