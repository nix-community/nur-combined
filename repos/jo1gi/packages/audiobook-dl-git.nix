{ pkgs, lib, fetchFromGitHub }:

with pkgs.python3Packages;

buildPythonApplication rec {
  pname = "audiobook-dl";
  version = "bb9a5b2";

  src = fetchFromGitHub {
    owner = "jo1gi";
    repo = pname;
    rev = version;
    sha256 = "sha256-Vdh2mkJkevuKRZy0dnQpcJDBVcKbY7gvz0J98ewxIgY=";
  };

  propagatedBuildInputs = [
    pkgs.ffmpeg
    mutagen
    requests
    rich
    lxml
    cssselect
    pillow
    m3u8
    pycryptodome
    importlib-resources
    appdirs
    tomli
  ];

  doCheck = false;

  meta = with lib; {
    description = "CLI tool for downloading audiobooks from online sources";
    homepage = "https://github.com/jo1gi/audiobook-dl";
    license = licenses.gpl3;
    maintainers = [ maintainers.jo1gi ];
    platforms = platforms.all;
  };
}
