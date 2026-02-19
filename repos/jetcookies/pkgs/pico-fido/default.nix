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
  vidpid ? "",
  usbVID ? "",
  usbPID ? "",
  enableEdDSA ? false,
  secureBootPKey ? null,
  extraCmakeFlags ? [ ],
}:
assert lib.assertMsg (!(vidpid != "" && (usbVID != "" || usbPID != ""))) "pico-fido: Arguments 'vidpid' and 'usbVID/usbPID' could not be set at the same time.";
stdenvNoCC.mkDerivation (finalAttrs: {

  pname = "pico-fido";
  version = "7.4";

  src = fetchFromGitHub {
    owner = "polhenarejos";
    repo = "pico-fido";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/IhKw+9NsRoRlm9Qcme+NqsdRN3myusn3ImSk8oAA5U=";
    fetchSubmodules = true;
  };

  mbedtls =
    if enableEdDSA then
      fetchFromGitHub {
        owner = "polhenarejos";
        repo = "mbedtls";
        rev = "32604790a0433470ac1836be4faa1e0793035673";
        hash = "sha256-a2edwKskmOKMy34xsD29OW/TlfHCn5PtUKDliDGUXi8=";
      }
    else
      fetchFromGitHub {
        owner = "Mbed-TLS";
        repo = "mbedtls";
        rev = "v3.6.5";
        hash = "sha256-6vTiOsTo8+r+GWhatAize3HC4TluboUQr9AOr1nx10o=";
      };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    gcc-arm-embedded
    picotool
    python3
  ];

  postPatch = ''
    rm -rf pico-keys-sdk/mbedtls
    cp -r ${finalAttrs.mbedtls} pico-keys-sdk/mbedtls
  '';

  PICO_SDK_PATH = "${pico-sdk.override { withSubmodules = true; }}/lib/pico-sdk/";

  cmakeFlags = [
    "-DCMAKE_C_COMPILER=${lib.getExe' gcc-arm-embedded "arm-none-eabi-gcc"}"
    "-DCMAKE_CXX_COMPILER=${lib.getExe' gcc-arm-embedded "arm-none-eabi-g++"}"
    "-DCMAKE_AR=${lib.getExe' gcc-arm-embedded "arm-none-eabi-ar"}"
    "-DCMAKE_RANLIB=${lib.getExe' gcc-arm-embedded "arm-none-eabi-ranlib"}"
  ]
  ++ lib.optionals (picoBoard != "pico") [ "-DPICO_BOARD=${picoBoard}" ]
  ++ lib.optionals (vidpid != "") [ "-DVIDPID=${vidpid}" ]
  ++ lib.optionals (usbVID != "" && usbPID != "") [
    "-DUSB_VID=${usbVID}"
    "-DUSB_PID=${usbPID}"
  ]
  ++ lib.optionals enableEdDSA [ "-DENABLE_EDDSA=ON" ]
  ++ lib.optionals (secureBootPKey != null) [ "-DSECURE_BOOT_PKEY=${secureBootPKey}" ]
  ++ extraCmakeFlags;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/pico-fido
    install pico_fido.uf2 $out/share/pico-fido/pico-fido-${picoBoard}${if enableEdDSA then "-eddsa" else ""}.uf2

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
