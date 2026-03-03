{
  maintainers,
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  alsa-lib,
  ...
}:
let
  pname = "amcdx-video-patcher-cli";
  version = "0.7.0";

  rev = "49addb6ea7fbf8b2caed247baf74194034f1fd61";
  hash = "sha256-9Yxpu+EgHuQKDlN1Cj6rz0NLYJ45EBDHAYw2Uh+oKHU=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "da8eat";
    repo = "VideoEditorInstaller";

    sparseCheckout = [
      "v${version}"
    ];
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
  ];

  installPhase = ''
    install -m755 -D v${version}/AMCDXVideoPatcherCLI $out/bin/AMCDXVideoPatcherCLI
  '';

  meta = {
    inherit maintainers;
    description = "AMCDX Video Patcher CLI.";
    homepage = "https://mogurenko.com";
    downloadPage = "https://github.com/da8eat/VideoEditorInstaller";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "AMCDXVideoPatcherCLI";
  };
}
