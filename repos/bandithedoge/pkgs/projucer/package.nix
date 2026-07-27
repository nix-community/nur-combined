{
  lib,
  stdenv,

  gtk3,
  juce,
  juceCmakeHook,
  ladspa-sdk,
  libjack2,
  pkg-config,
  webkitgtk_4_1,
  writableTmpDirAsHomeHook,
}:
stdenv.mkDerivation {
  pname = "projucer";
  inherit (juce) version src;

  nativeBuildInputs = [
    juceCmakeHook
  ];

  buildInputs = [
    ladspa-sdk
  ];

  propagatedBuildInputs = juceCmakeHook.commonBuildInputs ++ [
    gtk3
    libjack2
    pkg-config
    webkitgtk_4_1
    writableTmpDirAsHomeHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp extras/Projucer/Projucer_artefacts/Release/Projucer $out/bin

    runHook postInstall
  '';

  cmakeFlags = [ "-DJUCE_BUILD_EXTRAS=ON" ];

  ninjaFlags = [ "Projucer" ];

  setupHook = ./setupHook.sh;

  meta = {
    homepage = "https://juce.com/";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    mainProgram = "Projucer";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
