module Types exposing (..)

type alias Image =
  { contents : String
  , filename : String
  }

type alias Model =
  { stage : Int
  , image : Maybe Image
  }


type Msg
  = ChangeStage Int
  | ImageSelected
  | ImageRead Image
