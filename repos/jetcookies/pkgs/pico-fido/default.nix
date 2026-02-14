{
  lib,
  stdenvNoCC,
  fetchFromGitHub,

  cmake,
  gcc-arm-embedded,
  picotool,
  python3,

  pico-sdk,

  # Options
  # https://github.com/polhenarejos/pico-fido#build-for-raspberry-pico
  picoBoard ? "pico",
  vidpid ? null,
  usbVID ? null,
  usbPID ? null,
  secureBootPKey ? null,
  extraCmakeFlags ? null,
}:
assert lib.assertMsg (!(vidpid != null && (usbVID != null || usbPID != null))) "pico-fido: Arguments 'vidpid' and 'usbVID/usbPID' could not be set at the same time.";
assert lib.assertMsg ((secureBootPKey != null) -> (lib.isPath secureBootPKey)) "pico-fido: Argument 'secureBootPKey' must be a valid file path, but got: '${toString secureBootPKey}'.";
assert lib.assertMsg ((extraCmakeFlags != null) -> (lib.isList extraCmakeFlags)) "pico-fido: Argument 'extraCmakeFlags' must be a list, but got: '${toString extraCmakeFlags}'.";
stdenvNoCC.mkDerivation (finalAttrs: {

  pname = "pico-fido";
  version = "7.2";

  src = fetchFromGitHub {
    owner = "polhenarejos";
    repo = "pico-fido";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PKuIFfyIULlq9xSjcYtMTVm+r+5JjIJTtscxvlCxKdE=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    gcc-arm-embedded
    picotool
    python3
  ];

  PICO_SDK_PATH="${pico-sdk.override { withSubmodules = true; }}/lib/pico-sdk/";

  cmakeFlags = [
    "-DCMAKE_C_COMPILER=${lib.getExe' gcc-arm-embedded "arm-none-eabi-gcc"}"
    "-DCMAKE_CXX_COMPILER=${lib.getExe' gcc-arm-embedded "arm-none-eabi-g++"}"
  ]
  ++ lib.optionals (picoBoard != null) [ "-DPICO_BOARD=${picoBoard}" ]
  ++ lib.optionals (vidpid != null) [ "-DVIDPID=${vidpid}" ]
  ++ lib.optionals (usbVID != null && usbPID != null) [ "-DUSB_VID=${usbVID}" "-DUSB_PID=${usbPID}" ]
  ++ lib.optionals (secureBootPKey != null) [ "-DSECURE_BOOT_PKEY=${secureBootPKey}" ]
  ++ lib.optionals (extraCmakeFlags != null) extraCmakeFlags;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/pico-fido
    install pico_fido.uf2 $out/share/pico-fido/pico-fido-${picoBoard}-${if (vidpid != null) then vidpid else "none"}.uf2

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/polhenarejos/pico-fido/releases/tag/v${finalAttrs.version}";
    description = "FIDO Passkey for Raspberry Pico and ESP32";
    homepage = "https://github.com/polhenarejos/pico-fido";
    license = lib.licenses.agpl3Only;
    platforms = pico-sdk.meta.platforms;
  };
})
