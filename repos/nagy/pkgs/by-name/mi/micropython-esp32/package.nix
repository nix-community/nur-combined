# FIXME: This still needs a disabled sandbox to build
# upstream issue: https://github.com/espressif/idf-component-manager/issues/54
{
  callPackage,
  fetchFromGitHub,
  micropython,
  # You need to setup nixpkgs-esp-dev as an overlay for this attribute
  # https://github.com/mirrexagon/nixpkgs-esp-dev/
  esp-idf-esp32 ? null,
  board ? "ESP32_GENERIC",
}:

micropython.overrideAttrs (
  {
    nativeBuildInputs ? [ ],
    ...
  }:
  {
    nativeBuildInputs = nativeBuildInputs ++ [ esp-idf-esp32 ];

    dontUseCmakeConfigure = true;

    doCheck = false;

    buildPhase = ''
      runHook preBuild

      HOME=$PWD \
        make -C ports/esp32 BOARD=${board}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dm444 ports/esp32/build-${board}/firmware.bin -t $out/share/micropython/

      runHook postInstall
    '';
  }
)
