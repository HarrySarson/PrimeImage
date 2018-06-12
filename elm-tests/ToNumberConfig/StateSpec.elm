module ToNumberConfig.StateSpec exposing ( tests )

import Array exposing (Array)
import List
import Random.Pcg as Random

import Test exposing (describe, Test, fuzz, test)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)

import Array
import Json.Decode as Decode

import ToNumberConfig.Types as Types
import ToNumberConfig.State exposing (initialState, update)
import ToNumberConfig.Config as Config
import Fuzzers.ToNumberConfig exposing (model)



tests : Test
tests =
    describe "ToNumberConfig.State"
        [ describe "initialState"
            [ test ".width" <|
                \() -> initialState
                  |> .width
                  |> Expect.all
                      [ .value
                          >> Expect.all
                              [ Expect.greaterThan 0
                              , Expect.atMost Config.maxImageSize
                              ]
                      , \{value, attemptedValue} -> Expect.equal (toString value) attemptedValue
                      , .error
                          >> Expect.equal Nothing

                      ]
            , test ".height" <|
                \() -> initialState
                  |> .height
                  |> .value
                  |> Expect.all
                      [ Expect.greaterThan 0
                      , Expect.atMost Config.maxImageSize
                      ]
            , test ".levels" <|
                \() -> initialState
                  |> .levels
                  |> Array.toList
                  |> Expect.all
                      [ List.map .value
                          >> Expect.all
                              [ expectAscending
                              , expectAllInList (Expect.atLeast 0)
                              , expectAllInList (Expect.atMost Config.maxLevel)
                              ]
                      , expectAllInList <|
                            \{value, attemptedValue} -> Expect.equal (toString value) attemptedValue

                      , expectAllInList <|
                            .error
                              >> Expect.equal Nothing
                      ] --}
            ]
        , describe "update"
            [ describe "SetWidth message" <|
                  [ fuzz (Fuzz.tuple ( model, validImageSizeFuzz )) "valid width" <|
                      \( model, newWidth ) -> update (Types.SetWidth (toString newWidth)) model
                        |> .width
                        |> Expect.all
                            [ .value
                                >> Expect.equal newWidth
                            , .attemptedValue
                                >> Expect.equal (toString newWidth)
                            , .error
                                >> Expect.equal Nothing
                            ]
                  , fuzz (Fuzz.tuple ( model, invalidImageSizeFuzz )) "invalid numeric width" <|
                      \( model, newWidth ) -> update (Types.SetWidth (toString newWidth)) model
                        |> .width
                        |> Expect.all
                            [ .value
                                >> Expect.equal model.width.value
                            , .attemptedValue
                                >> Expect.equal (toString newWidth)
                            , .error
                                >> Expect.notEqual Nothing
                            ]
                  , fuzz model "non numeric width" <|
                      \model -> update (Types.SetWidth "Not a number") model
                        |> .width
                        |> Expect.all
                           [ .value
                               >> Expect.equal model.width.value
                           , .attemptedValue
                               >> Expect.equal "Not a number"
                           , .error
                               >> Expect.notEqual Nothing
                           ]
                  ]
            , describe "SetHeight message" <|
                  [ fuzz (Fuzz.tuple ( model, validImageSizeFuzz )) "valid height" <|
                      \( model, newHeight ) -> update (Types.SetHeight (toString newHeight)) model
                        |> .height
                        |> Expect.all
                            [ .value
                                >> Expect.equal newHeight
                            , .attemptedValue
                                >> Expect.equal (toString newHeight)
                            , .error
                                >> Expect.equal Nothing
                            ]
                  , fuzz (Fuzz.tuple ( model, invalidImageSizeFuzz )) "invalid numeric height" <|
                      \( model, newHeight ) -> update (Types.SetHeight (toString newHeight)) model
                        |> .height
                        |> Expect.all
                            [ .value
                                >> Expect.equal model.height.value
                            , .attemptedValue
                                >> Expect.equal (toString newHeight)
                            , .error
                                >> Expect.notEqual Nothing
                            ]
                  , fuzz model "non numeric height" <|
                      \model -> update (Types.SetHeight "Not a number") model
                        |> .height
                        |> Expect.all
                           [ .value
                               >> Expect.equal model.height.value
                           , .attemptedValue
                               >> Expect.equal "Not a number"
                           , .error
                               >> Expect.notEqual Nothing
                           ]
                  ]
            , describe "SetLevel message" <|
                  [ fuzz
                      (Fuzz.tuple3 ( model, validLevelIndexFuzz, validLevelFuzz ))
                      "valid level and index"
                      <| \( model, index, newLevel ) -> update (Types.SetLevel index (toString newLevel)) model
                        |> .levels
                        |> Expect.all
                            (Array.toList <|
                              Array.indexedMap
                                    (\i lev ->
                                        Array.get i
                                          >> Maybe.map
                                              (if i == index then
                                                  Expect.all
                                                      [ .value
                                                          >> Expect.equal newLevel
                                                      , .attemptedValue
                                                          >> Expect.equal (toString newLevel)
                                                      , .error
                                                           >> Expect.equal Nothing
                                                      ]
                                              else
                                                  Expect.equal lev
                                              )
                                          >> Maybe.withDefault (Expect.fail "level with this index should exist")
                                    )
                                    model.levels
                            )
                  , fuzz
                      (Fuzz.tuple3
                          ( model
                          , invalidLevelIndexFuzz
                          , Fuzz.oneOf
                              [ Fuzz.map toString Fuzz.int
                              , Fuzz.constant "not a number"
                              ]
                          )
                      )
                      "invalid index"
                      <| \( model, index, newLevelStr ) -> update (Types.SetLevel index newLevelStr) model
                        |> .levels
                        |> Expect.equal model.levels
                  , fuzz
                      (Fuzz.tuple3 ( model, validLevelIndexFuzz, invalidLevelFuzz ))
                      "invalid level"
                      <| \( model, index, newLevel ) -> update (Types.SetLevel index (toString newLevel)) model
                        |> .levels
                        |> Expect.all
                            -- make sure there is at least one expectation for Expect.all
                            ((\_ -> Expect.pass) :: (Array.toList <|
                              Array.indexedMap
                                    (\i lev ->
                                        Array.get i
                                          >> Maybe.map
                                              (if i == index then
                                                  Expect.all
                                                      [ .value
                                                          >> Expect.equal lev.value
                                                      , .attemptedValue
                                                          >> Expect.equal (toString newLevel)
                                                      , .error
                                                           >> Expect.notEqual Nothing
                                                      ]
                                              else
                                                  Expect.equal lev
                                              )
                                          >> Maybe.withDefault (Expect.fail "level with this index should exist")
                                    )
                                    model.levels
                            ))
                  ]
            ]
        ]

validImageSizeFuzz : Fuzzer Int
validImageSizeFuzz =
    Fuzz.intRange 1 Config.maxImageSize


invalidImageSizeFuzz : Fuzzer Int
invalidImageSizeFuzz =
    Fuzz.oneOf
        [ Fuzz.intRange Random.minInt 0
        , Fuzz.intRange (Config.maxImageSize + 1) Random.maxInt
        ]


validLevelFuzz : Fuzzer Int
validLevelFuzz =
    Fuzz.intRange 0 Config.maxLevel


invalidLevelFuzz : Fuzzer Int
invalidLevelFuzz =
    Fuzz.oneOf
        [ Fuzz.intRange Random.minInt -1
        , Fuzz.intRange (Config.maxLevel + 1) Random.maxInt
        ]


validLevelIndexFuzz : Fuzzer Int
validLevelIndexFuzz =
    Fuzz.intRange 0 (Config.numberOfLevels - 1)


invalidLevelIndexFuzz : Fuzzer Int
invalidLevelIndexFuzz =
    Fuzz.oneOf
        [ Fuzz.intRange Random.minInt -1
        , Fuzz.intRange Config.numberOfLevels Random.maxInt
        ]


expectAllInList : (a -> Expectation) -> List a -> Expectation
expectAllInList expecter list =
    Expect.all
        (List.map (\value -> always (expecter value)) list)
        ()


expectAscending list =
    List.map2 (\a b -> a - b) (List.drop 1 list) list
     |> expectAllInList (Expect.greaterThan 0)

{-


update : Types.Msg -> Types.Model -> Types.Model
update msg model =
    case msg of
        Types.SetWidth widthStr ->
            { model
            | width = updateErrorable (validateSize "width") widthStr model.width
            }
        Types.SetHeight heightStr ->
            { model
            | height = updateErrorable (validateSize "height") heightStr model.height
            }
        Types.SetLevel index levelStr ->
            Array.get index model.levels
              |> Maybe.map (\oldLevel -> updateErrorable validateLevel levelStr oldLevel)  
              |> Maybe.map (\newLevel -> { model | levels = Array.set index newLevel model.levels })
              |> Maybe.withDefault model

-}