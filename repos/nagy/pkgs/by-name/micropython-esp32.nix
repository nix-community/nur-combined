# FIXME: This still needs a disabled sandbox to build
# upstream issue: https://github.com/espressif/idf-component-manager/issues/54
{
  fetchpatch,
  micropython,
  # You need to setup nixpkgs-esp-dev as an overlay for this attribute
  # https://github.com/mirrexagon/nixpkgs-esp-dev/
  esp-idf-esp32 ? null,
  board ? "ESP32_GENERIC_S3",
}:

micropython.overrideAttrs (
  {
    nativeBuildInputs ? [ ],
    patches ? [ ],
    ...
  }:
  {
    # patches = patches ++ [
    #   (fetchpatch {
    #     # ports/esp32/network_ppp: Ensure clean shutdown of PPP connection. #15242
    #     url = "https://github.com/micropython/micropython/pull/15242.patch";
    #     hash = "sha256-3PQwW22wDKObOVLMcsr9uVWQbRG5nyHVD3uPsOEOQ/w=";
    #   })
    # ];

    nativeBuildInputs = nativeBuildInputs ++ [ esp-idf-esp32 ];

    dontUseCmakeConfigure = true;

    doCheck = false;

    # idf-component-manager wants to access the network, so we disable it.
    # env.IDF_COMPONENT_MANAGER = "0";

    # workaround for https://github.com/micropython/micropython/issues/14257
    postPatch = ''
      substituteInPlace ports/esp32/boards/ESP32_GENERIC_S3/mpconfigboard.h \
        --replace-fail '#define MICROPY_HW_ENABLE_UART_REPL         (1)' '#define MICROPY_HW_ENABLE_UART_REPL         (0)'
    '';

    buildPhase = ''
      runHook preBuild

      HOME=$PWD \
        make -C ports/esp32 BOARD=${board}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dm644 ports/esp32/build-${board}/firmware.bin -t $out/share/micropython/

      runHook postInstall
    '';
  }
)
