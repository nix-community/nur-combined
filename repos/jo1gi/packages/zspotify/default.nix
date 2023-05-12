{ pkgs, lib, fetchFromGitHub }:
with pkgs.python3Packages;

let
  music_tag = buildPythonPackage rec {
    pname = "music-tag";
    version = "0.4.3";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-Cqtubu2o3w9TFuwtIZC9dFYbfgNWKrCRzo1Wh828//Y=";
    };

    propagatedBuildInputs = [ mutagen ];

    doCheck = false;
  };

  librespot = buildPythonPackage rec {
    pname = "librespot";
    version = "0be8216";

    src = fetchFromGitHub {
      owner = "kokarare1212";
      repo = "librespot-python";
      rev = version;
      sha256 = "sha256-nKPYD0mEUaQGuk5n94+rBb0XrUf+HDw7SOc7WEbxMdo=";
    };

    propagatedBuildInputs = [
      defusedxml
      protobuf
      pycryptodomex
      pyogg
      requests
      websocket-client
      zeroconf
    ];

    patchPhase = ''
      sed 's/websocket-client==\d+.\d+.\d+/websocket-client/' requirements.txt > requirements.txt
    '';

    doInstallCheck = false;
    nativeInstallCheckInputs = false;
    doCheck = false;
  };
in
buildPythonApplication rec {
  pname = "zspotify";
  version = "b5be199";

  src = fetchFromGitHub {
    owner = "jsavargas";
    repo = pname;
    rev = "b5be199";
    sha256 = "sha256-NX1dLv/OAsHrT3vL/jsdce2yoQ1wWQXOB77TILP14aY=";
  };

  patches = [ ./dependency.patch ];

  propagatedBuildInputs = [
    pkgs.ffmpeg
    appdirs
    librespot
    music_tag
    mutagen
    pydub
    pillow
    requests
    setuptools
    tqdm
  ];

  meta = with lib; {
    description = "ZSpotify is a Spotify downloader that enables users to find and download songs";
    homepage = "https://github.com/jsavargas/zspotify";
    license = licenses.gpl3;
    maintainers = [ maintainers.jo1gi ];
    platforms = platforms.all;
  };
}
