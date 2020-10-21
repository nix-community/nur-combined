Config
{ font = "Liberation Mono:size=14"
, bgColor = "black"
, fgColor = "white"
, border = BottomB
, borderColor = "black"
, position = Bottom
, commands =
    [ Run DynNetwork [] 10
    , Run Memory ["-t", "RAM: <usedratio>%"] 10
    , Run Battery [] 10
    , Run Volume "default" "Master" [] 10
    , Run Date "%F %a %T" "mydate" 10
    , Run StdinReader
    ]
, template = "%StdinReader% } %mydate% { %memory% | %default:Master% | %dynnetwork% | %battery% |"
}
