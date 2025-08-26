let
  fonts = import ./fonts.nix;
in
{
  all = fonts.fonts;

  default = [
    "Arial"
    "Arial Black"
    "Bahnschrift"
    "Calibri"
    "Calibri Light"
    "Cambria"
    "Candara"
    "Candara Light"
    "Comic Sans MS"
    "Consolas"
    "Constantia"
    "Corbel"
    "Corbel Light"
    "Courier New"
    "Franklin Gothic Medium"
    "Gabriola"
    "Georgia"
    "Impact"
    "Ink Free"
    "Lucida Sans Unicode"
    "Lucida Console"
    "Marlett"
    "Microsoft Sans Serifc"
    "Palatino Linotype"
    "Segoe MDL2 Assets"
    "Segoe Fluent Icons"
    "Segoe Print"
    "Segoe Script"
    "Segoe UI"
    "Segoe UI Light"
    "Segoe UI Semilight"
    "Segoe UI Black"
    "Segoe UI Emoji"
    "Segoe UI Historic"
    "Segoe UI Semibold"
    "Segoe UI Symbol"
    "Segoe UI Variable"
    "Sitka"
    "Sylfaen"
    "Symbol"
    "Tahoma"
    "Times New Roman"
    "Trebuchet MS"
    "Verdana"
    "Webdings"
    "Wingdings"
  ];

  japanese = [
    "MS Gothic"
    "Yu Gothic"
    "Yu Gothic Medium"
    "Yu Gothic Light"
  ];

  korean = [
    "Malgun Gothic"
    "Malgun Gothic Semilight"
  ];

  sea = [  # southeast asia
    "Javanese Text"
    "Microsoft Himalaya"
    "Microsoft New Tai Lue"
    "Microsoft PhagsPa"
    "Microsoft Tai Le"
    "Microsoft Yi Baiti"
    "Mongolian Baiti"
    "Myanmar Text"
    "Nirmala UI"
  ];

  thai = [
    "Leelawadee UI"
    "Leelawadee UI Semilight"
  ];

  zh-cn = [  # simplified chinese
    "NSimSun"
    "SimSun-ExtB"
    "Microsoft YaHei"
    "Microsoft YaHei Light"
  ];

  zh-tw = [  # traditional chinese
    "Microsoft JhengHei"
    "Microsoft JhengHei Light"
    "MingLiU_HKSCS-ExtB"
  ];

  other = [
    "Ebrima"
    "Gadugi"
    "MV Boli"
  ];
}
