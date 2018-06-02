module Subscriptions exposing (subscriptions)

import Ports exposing (fileContentRead, nonPrimeGenerated)
import Types

subscriptions : Types.Model -> Sub Types.Msg
subscriptions model =
  Sub.batch
    [ fileContentRead Types.ImageRead
    , nonPrimeGenerated Types.NonPrimeGenerated
    ]
