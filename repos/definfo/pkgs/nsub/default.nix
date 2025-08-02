{
  stdenv,
  lib,
  fetchFromGitHub,
  check,
}:

stdenv.mkDerivation {
  pname = "nsub";
  version = "0-unstable-2024-07-06";

  src = fetchFromGitHub {
    owner = "nikiroo";
    repo = "nsub";
    rev = "d7bf97490eb05a41feecb2be09bc73ab9c4b1c59";
    hash = "sha256-o826J5gU3yILXQiqHqYJLCdw8azuOEbbU4iw5eUk3BI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ ];

  buildInputs = [ check ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  preInstall = ''
    mkdir -p $out/include/cutils
  '';

  meta = {
    description = "Subtitle/Lyrics conversion program (webvtt/srt/lrc) ";
    homepage = "https://github.com/nikiroo/nsub";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ definfo ];
    platforms = lib.platforms.all;
  };
}
