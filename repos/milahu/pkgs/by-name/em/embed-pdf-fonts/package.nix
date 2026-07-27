{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cairo,
  poppler,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "embed-pdf-fonts";
  version = "0-unstable-2014-12-21";

  src = fetchFromGitHub {
    owner = "mfiedler";
    repo = "embed-pdf-fonts";
    rev = "e430d55289bdcd1aceb9c63d0c337e3a9edb4400";
    hash = "sha256-YOVEOMaGtmHLzGW5lsTd2nzyLyGBE0kwidB4hz9bX5I=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    cairo
    poppler
  ];

  makeFlags = [
    "PREFIX=$(out)"
  ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  meta = {
    description = "Embed fonts referenced in an existing PDF file, using Fontconfig substitution settings";
    homepage = "https://github.com/mfiedler/embed-pdf-fonts";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "embed-pdf-fonts";
    platforms = lib.platforms.all;
  };
})
