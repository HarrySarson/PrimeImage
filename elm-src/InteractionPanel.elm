module InteractionPanel exposing (Props, view)

import Array
import Config
import File
import Html exposing (Html, br, button, div, h1, input, label, li, p, section, strong, text, ul)
import Html.Attributes exposing (attribute, class, id, name, type_)
import Html.Events exposing (on, onClick)
import Json.Decode as Decode
import Resources
import ToNumberConfig.Types
import ToNumberConfig.View
import Types


type alias Props =
    { stage : Int
    , canGoBack : Bool
    , canGoNext : Bool
    , toNumberConfig : ToNumberConfig.Types.Model
    , primeError : Maybe String
    , fetchingPrime : Bool
    , primeFoundLog2Prob : Maybe Float
    }


view : Props -> Html.Html Types.Msg
view props =
    let
        instruction =
            Array.get props.stage (instructions props)
                |> Maybe.withDefault (default_instructions props.stage)

        interaction =
            Array.get props.stage (interactions props)
                |> Maybe.withDefault []
    in
    div [ class "interaction-panel" ]
        [ section
            [ class "interaction-instructions stage-selecting" ]
            instruction
        , div
            [ class "interaction-interface stage-selecting" ]
            interaction
        , div [ class "interaction-control" ]
            [ stageButton -1 props [ text "Back" ]
            , stageButton 1 props [ text "Next" ]
            ]
        ]


stageButton : Int -> Props -> List (Html Types.Msg) -> Html.Html Types.Msg
stageButton change props =
    let
        enabled =
            if change > 0 then
                props.canGoNext

            else if change < 0 then
                props.canGoBack

            else
                False
    in
    button
        [ attribute "data-stage-change" (String.fromInt change)
        , onClick (Types.ChangeStage change)
        , class
            (if enabled then
                ""

             else
                "disabled"
            )
        ]


instructions : Props -> Array.Array (List (Html Types.Msg))
instructions props =
    let
        makeErrorP : ( String, String ) -> Html msg
        makeErrorP ( name, errorDescription ) =
            p
                [ class "error-in-field" ]
                [ text <| "Error setting " ++ name ++ ":"
                , br [] []
                , text <| "  " ++ errorDescription
                ]
    in
    Array.fromList
        [ [ h1 [] [ text "Welcome to Prime Image" ]
          , p []
                [ text "Click "
                , stageButton 1 props [ text "Next" ]
                , text " to begin."
                ]
          ]
        , [ h1 [] [ text "Select Image" ]
          , p [] [ text "First you must select an image to turn into a prime number." ]
          , p []
                [ text "Either use the box below to upload an image from your computer or select one of the following examples:"
                , ul []
                    [ li [ onClick (Types.SelectExampleImage Types.Archer) ] [ button [] [ text "English cricketer Jofra Archer" ] ]
                    , li [ onClick (Types.SelectExampleImage Types.Sunflower) ] [ button [] [ text "A sunflower" ] ]
                    , li [ onClick (Types.SelectExampleImage Types.Corpus) ] [ button [] [ text "Corpus Christi College Cambridge" ] ]
                    ]
                ]
          , p []
                [ text "Once you have opened an image, click "
                , stageButton 1 props [ text "Next" ]
                , text " to convert the image to a number"
                ]
          ]
        , h1 [] [ text "Convert Image To Number" ]
            :: p
                []
                [ text """
                Set the number of digits to use for your image using width.
                Be warned that images with a large number of digits may take a very long time to convert to a prime.
                """
                ]
            :: p
                []
                [ text ("The " ++ String.fromInt (Array.length props.toNumberConfig.levels) ++ """
                levels determine the which pixel values map to each number.
                Play around with these to get the clearest number image.
                """)
                ]
            :: (ToNumberConfig.Types.errorsInModel props.toNumberConfig
                    |> List.map makeErrorP
               )
        , [ Just <| h1 [] [ text "Create a Prime Number" ]
          , Just <| p [] [ text "Click below to find a prime number similar to the current number." ]
          , Just <| p [] [ text "Please be aware that if the width is much more than 20, then this could take a very long time." ]
          , props.primeError
                |> Maybe.map
                    (\error ->
                        p
                            [ class "error-in-field" ]
                            [ text <| "Error finding a prime:"
                            , br [] []
                            , text <| error
                            ]
                    )
          , if props.fetchingPrime then
                Just
                    (p []
                        [ text "Calculating prime number ..."
                        , div
                            [ class "prime-progress"
                            ]
                            []
                        ]
                    )

            else
                Nothing
          , props.primeFoundLog2Prob
                |> Maybe.map
                    (\prob ->
                        p []
                            [ text "Found a prime number!"
                            , text "(The probability that the number is not prime is less than 1/10^"
                            , text (String.fromInt (round (-1 * logBase 10 e * prob)))
                            , text ".)"
                            ]
                    )
          ]
            |> List.filterMap identity
        ]


interactions : Props -> Array.Array (List (Html Types.Msg))
interactions props =
    Array.fromList
        [ []
        , [ Html.form
                [ class "image-pick" ]
                [ label
                    []
                    [ div
                        [ class "content" ]
                        [ Resources.fileUploadIcon
                        , input
                            [ type_ "file"
                            , name "files[]"
                            , id Config.imageInputId
                            , on "change" decodeFile
                            ]
                            []
                        , div [ class "file-label" ]
                            [ strong [] [ text "Click here to choose a file" ]
                            ]
                        ]
                    ]
                ]
          ]
        , [ Html.map
                Types.UpdateNumberConfig
                (ToNumberConfig.View.view props.toNumberConfig)
          ]
        , [ label
                [ class "prime-generate" ]
                [ button
                    [ onClick Types.RequestPrime ]
                    [ text "Generate Prime" ]
                ]
          ]
        ]


default_instructions : Int -> List (Html Types.Msg)
default_instructions stage =
    [ h1 [] [ text "Unknown stage" ]
    , p [] [ text ("Stage " ++ String.fromInt stage ++ " could not be found") ]
    ]


decodeFile : Decode.Decoder Types.Msg
decodeFile =
    Decode.at [ "target", "files" ] (Decode.list File.decoder)
        |> Decode.map
            (List.head
                >> Maybe.map Types.ImageSelected
                >> Maybe.withDefault Types.Noop
            )
