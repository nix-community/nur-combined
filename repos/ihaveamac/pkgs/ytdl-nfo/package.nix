{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "ytdl-nfo";
  version = "0.3.0-unstable-2026-01-31";
  pyproject = true;

  # fork created from https://github.com/owdevel/ytdl-nfo/pull/44
  src = fetchFromGitHub {
    owner = "ihaveamac";
    repo = pname;
    rev = "5e656f59c5666a5e07b6ead314deef6c31827889";
    hash = "sha256-CbZ3uJJGTF6d2jGRTDeN5kvvTBdI3+NzF73MOIToFWw=";
  };

  build-system = [ python3Packages.poetry-core ];

  dependencies = with python3Packages; [
    pyyaml
    setuptools
  ];

  meta = {
    description = "youtube-dl JSON metadata to Kodi-style NFO converter (fork with setuptools fix)";
    homepage = "https://github.com/owdevel/ytdl-nfo";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.all;
    mainProgram = "ytdl-nfo";
  };
}
