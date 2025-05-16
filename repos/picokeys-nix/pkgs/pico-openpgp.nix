{

  picoBoard ? "waveshare_rp2040_one",
  usbVid ? null,
  usbPid ? null,
  vidPid ? null,
  delayedBoot ? false,
  eddsaSupport ? false,
  secureBootKey ? null,
  generateOtpFile ? false,

  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pico-sdk-full,
  picotool,
  gcc-arm-embedded,
  python3,

  pico-keys-sdk,
}:
stdenv.mkDerivation rec {
  pname = "pico-openpgp${lib.optionalString eddsaSupport "-eddsa"}";
  version = "3.6";

  src = fetchFromGitHub {
    owner = "polhenarejos";
    repo = "pico-openpgp";
    rev = "v${version}";
    hash = "sha256-za3hymEurUQarSvaD9DrYnhsFUhe8G2p+LONN/ag260=";
  };

  nativeBuildInputs = [
    cmake
    gcc-arm-embedded
    picotool
    python3
  ];

  phases = [
    "unpackPhase"
    "patchPhase"
    "configurePhase"
    "buildPhase"
    "installPhase"
  ];

  cmakeFlags =
    [
      (lib.cmakeFeature "CMAKE_CXX_COMPILER" "${gcc-arm-embedded}/bin/arm-none-eabi-g++")
      (lib.cmakeFeature "CMAKE_C_COMPILER" "${gcc-arm-embedded}/bin/arm-none-eabi-gcc")
      (lib.cmakeFeature "PICO_SDK_PATH" "${pico-sdk-full}/lib/pico-sdk")

      (lib.cmakeFeature "PICO_BOARD" picoBoard)
      (lib.cmakeBool "ENABLE_DELAYED_BOOT" delayedBoot)
      (lib.cmakeBool "ENABLE_EDDSA" eddsaSupport)
    ]
    ++ lib.optional (usbVid != null && usbPid != null) [
      (lib.cmakeFeature "USB_VID" usbVid)
      (lib.cmakeFeature "USB_PID" usbPid)
    ]
    ++ lib.optional (vidPid != null) [
      (lib.cmakeFeature "VIDPID" vidPid)
    ]
    ++ lib.optional (secureBootKey != null) [
      (lib.cmakeFeature "SECURE_BOOT_PKEY" secureBootKey)
    ];

  prePatch = ''
    cp -r ${pico-keys-sdk { inherit eddsaSupport generateOtpFile; }}/share/pico-keys-sdk .
    chmod -R +w pico-keys-sdk
  '';

  installPhase = ''
    ${lib.optionalString (picoBoard != null)
      "mv pico_openpgp.uf2 pico_openpgp${lib.optionalString eddsaSupport "_eddsa"}_${
        lib.optionalString (vidPid != null) "${vidPid}-"
      }${picoBoard}-${version}.uf2"
    }
    ${lib.optionalString (vidPid != null && picoBoard == null)
      "mv pico_openpgp.uf2 pico_openpgp${lib.optionalString eddsaSupport "_eddsa"}_${vidPid}-${version}.uf2"
    }

    mkdir -p $out
    cp *.uf2 $out
    runHook postInstall
  '';

  postInstall = lib.optionalString generateOtpFile ''
    cp /build/source/otp.json $out
  '';

  meta = {
    description = "Converting a Raspberry Pico into an OpenPGP CCID smart card";
    homepage = "https://github.com/polhenarejos/pico-openpgp";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
