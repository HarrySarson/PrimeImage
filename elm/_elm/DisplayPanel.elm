module DisplayPanel exposing (Props, view)

import Array
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Types

type alias Props =
  { stage : Int
  }


view : Props -> Html.Html a
view props =
  div []
    [ div [ class "display-panel stage-selecting" ] (Maybe.withDefault [] (Array.get props.stage displays))
    ]

displays = Array.fromList
  [ [ span [ class "image-number" ]
      [ text """1001010777777777777770777777777777777777770777777777777777777777
1010010777777777777702077777777777777777702077777777777777777777
1001000777777777777770777777777777777777770777777777777777777777
7777777777777777777705077777777777777777705077777777777777777777
7777777777777777777055107777777777777777015507777777777777777777
7777777777777777777055507777777777777777055507777777777777777777
7777777777777777777000037777777007777777300007777777777777777777
7777777777777777770433307777770880777777033340777777777777777777
7777777778777777777000007777771001777777000007777777777777777777
7778777077777777777099907777710550177777099907777777777707777777
7777777017777777777099907777105555017777099907777777777107777777
7777777047777777777099907717053003507177100007777777777407777777
7777770107777777787000800500511111150050080007777777777010777777
7777770107777777777109900051100000011500099907777777777010777777
7777777247777777777000001115051111605111001007777777777327777777
7777777007777787777099301500115005110051039907777777777007777777
7777777077877777771099300011110880111100039901777787777707777777
7777777047777777700000001111115005111112000000078777777407778777
7000700560110011055059901111111111111111099505501100110650070007
0656065555005500555009001111116005111111009005550055005555606560
5555555555555555555009001115088988805111009005555555555555555555
0000005500000000000090901119088888809111090900000000000055000000
1111105501111111111090901110888888880111090901111111111055011111
9511105501115995111090901118008008008111090901115995111055011159
0851105501168008511030301118888888888111030301159008512065011580
0801100001108008011053501118888888889111053501108008011000011080
0801105501108008010900001118888888888111000090108018011055011080
0802105501108008011055501110000330000111056501108008011055011080
0801105501108008011059503400000000099933059501108008011055011080
3331105501133333311093305555655555555555033901133333312055011333
0000005500000000000095909999999999999999095900000000000055000000
1111505505111111111094901111112111111111094901111111115055051111
1111105501111111111092901119000100009111092901111111111055011112
1111100001111112111095901210888988880111095901111111111000011111
8511105501115891111095901110800880080111195901111985111055011158
0051106501150008111092901110088888800111092901118000511055011500
0831105501138080110055901110188888800111095500110808311055011380
0831105501138080110555550110088888800110555550110808311056011390
0031105611130000110555550110088888800110555550110000311055011300
1111055550111111110555550110088888800110555550111111110555501112
1111055550111111110555550110088888800110555550111111110550000000
0000055550000000000555550000088888800000555550000000000550120397"""
      ]
    ]
  , [ canvas [] []
    ]
  ]