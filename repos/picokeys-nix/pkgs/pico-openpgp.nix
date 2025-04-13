{

  picoBoard ? "waveshare_rp2040_one",
  usbVid ? null,
  usbPid ? null,
  vidPid ? null,
  eddsaSupport ? false,

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
      "-DPICO_SDK_PATH=${pico-sdk-full}/lib/pico-sdk"
      "-DCMAKE_C_COMPILER=${gcc-arm-embedded}/bin/arm-none-eabi-gcc"
      "-DCMAKE_CXX_COMPILER=${gcc-arm-embedded}/bin/arm-none-eabi-g++"
    ]
    ++ lib.optional (picoBoard != null) [
      "-DPICO_BOARD=${picoBoard}"
    ]
    ++ lib.optional (usbVid != null) [
      "-DUSB_VID=${usbVid}"
    ]
    ++ lib.optional (usbPid != null) [
      "-DUSB_PID=${usbPid}"
    ]
    ++ lib.optional (vidPid != null) [ "-DVIDPID=${vidPid}" ]
    ++ lib.optional eddsaSupport [
      "-DENABLE_EDDSA=1"
    ];

  prePatch = ''
    cp -r ${pico-keys-sdk { inherit eddsaSupport; }}/share/pico-keys-sdk .
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
    cp -r *.uf2 $out
  '';

  meta = {
    description = "Converting a Raspberry Pico into an OpenPGP CCID smart card";
    homepage = "https://github.com/polhenarejos/pico-openpgp";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
