{
  maintainers,
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  ninja,
  alsa-lib,
  curl,
  jq,
  ffmpeg,
  ...
}:
let
  pname = "cxadc-vhs-server";
  version = "1.4.0";

  rev = "v${version}";
  hash = "sha256-5C4ONWvxSAUf/NpCEGir3V64csmPNNfKkBkRRxumh8Y=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "namazso";
    repo = "cxadc_vhs_server";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
    alsa-lib
  ];

  buildInputs = [
    curl
    jq
    ffmpeg
  ];

  postPatch = ''
    substituteInPlace src/files.c \
      --replace-quiet "sys_errlist[errno]" "strerror(errno)" \
      --replace-quiet "sys_errlist[err]" "strerror(err)"
  '';

  installPhase = ''
    install -m755 -D cxadc_vhs_server -t $out/bin/cxadc_vhs_server
    install -m755 -D ../local-capture.sh $out/bin/cxadc-local-capture
  '';

  meta = {
    inherit maintainers;
    description = "A terrible HTTP server made for capturing VHS with two cxadc cards and cxadc-clock-generator-audio-adc or cxadc-clockgen-mod.";
    homepage = "https://github.com/namazso/cxadc_vhs_server";
    #license = ; unknown
    platforms = lib.platforms.linux;
  };
}
