{ lib
, fetchFromGitHub
, stdenv
, cmake
, pkg-config
, alsa-lib
, curl
, jq
, ffmpeg
, flac
, sox
, useFlacSox ? true
, ...
}:
stdenv.mkDerivation rec {
  name = "cxadc-vhs-server";
  version = "v1.4.0";

  src = fetchFromGitHub {
    owner = "namazso";
    repo = "cxadc_vhs_server";
    rev = version;
    sha256 = "sha256-5C4ONWvxSAUf/NpCEGir3V64csmPNNfKkBkRRxumh8Y=";
  };

  patches = [
    ./patches/001-Replace-sys_errlist-with-strerror.patch
  ] ++ lib.optionals useFlacSox [ ./patches/002-Use-flac-sox-instead-of-ffmpeg.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
    alsa-lib
  ];

  buildInputs = [
    curl
    jq
    ffmpeg
  ] ++ lib.optionals useFlacSox [ flac sox ];

  installPhase = ''
    install -D -m 755 cxadc_vhs_server -t $out/bin/
    install -D -m 755 ../local-capture.sh $out/bin/cxadc-local-capture
  '';

  meta = {
    description = "A terrible HTTP server made for capturing VHS with two cxadc cards and cxadc-clock-generator-audio-adc or cxadc-clockgen-mod.";
    #license = ; ??/
    maintainers = [ "JuniorIsAJitterbug" ];
    homepage = "https://github.com/namazso/cxadc_vhs_server";
  };
}
