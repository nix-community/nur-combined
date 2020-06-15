{ writeScriptBin, fetchFromGitHub, python3 }:
let
  src = fetchFromGitHub {
    owner = "makefu";
    repo = "youtube-dl2kodi";
    rev = "88abe687842309d7bda0b7ba65b64e8058b855d6";
    sha256 = "18csv2ighwgdgsm66hvw7fanv1pz522p24q59q2cwqy86fpg9y03";
  };
in writeScriptBin "youtube-dl2kodi" ''
  ${python3}/bin/python ${src}/youtube-dl2kodi.py "$@"
''
