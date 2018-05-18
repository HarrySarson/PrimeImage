module View exposing (view)

import Html exposing (Html, node)

import InteractionPanel
import DisplayPanel

import Config
import Types


view : Types.Model -> Html Types.Msg
view model =
  let
    -- todo: find a more elegant way to set these props
    canGoNext = model.stage + 1 < Config.stageCount
    displayProps =
      { stage = model.stage
      , canGoNext = canGoNext
      , imagePreview = model.image
      }
    interactionProps =
      { stage = model.stage
      , canGoNext = canGoNext
      , canGoBack = model.stage > 0
      }
  in
    node "main" []
      [ InteractionPanel.view interactionProps
      , DisplayPanel.view displayProps
      ]