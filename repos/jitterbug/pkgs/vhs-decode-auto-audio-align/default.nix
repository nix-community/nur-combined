{ lib
, stdenv
, fetchurl
, unzip
, makeWrapper
, mono
}:

stdenv.mkDerivation {
  pname = "vhs-decode-auto-audio-align";
  version = "c21dfede5";

  src = fetchurl {
    url = "https://gitlab.com/wolfre/vhs-decode-auto-audio-align/-/jobs/5875926180/artifacts/raw/vhs-decode-auto-audio-align_0.0.0-c21dfede5.zip";
    hash = "sha256-FEQ4yhEpuguZmHQ/i7zrahPACgLQ9ATtd6YQRY705dQ=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r VhsDecodeAutoAudioAlign.exe $out/bin/.VhsDecodeAutoAudioAlign.exe
    cp -r Binah.dll $out/bin/Binah.dll

    makeWrapper "${mono}/bin/mono" "$out/bin/VhsDecodeAutoAudioAlign.exe" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ "$out" ]} \
      --add-flags $out/bin/.VhsDecodeAutoAudioAlign.exe

    runHook postInstall
  '';

  meta = with lib; {
    description = "A project to automatically align synchronous (RF) HiFi and linear audio captures to a video RF capture for VHS-Decode.";
    homepage = "https://gitlab.com/wolfre/vhs-decode-auto-audio-align";
    license = licenses.bsd3;
    maintainers = [ "JuniorIsAJitterbug" ];
    platforms = platforms.linux;
    downloadPage = "https://gitlab.com/wolfre/vhs-decode-auto-audio-align";
  };
}
