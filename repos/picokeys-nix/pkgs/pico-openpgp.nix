{
  picoBoard ? "waveshare_rp2040_one",
  usbVid ? null,
  usbPid ? null,
  vidPid ? null,

  version ? "3.2",
  rev ? "v3.2",
  hash ? "sha256-pcu3HA7Gd0QnTTbMd+KEhml7bxp07Q8FRWGjrm21iVs=",

  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pico-sdk-full,
  picotool,
  gcc-arm-embedded,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "pico-openpgp";
  inherit version;

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "polhenarejos";
    repo = "pico-openpgp";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    gcc-arm-embedded
    picotool
    python3
  ];

  phases = [
    "unpackPhase"
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
    ++ lib.optional (vidPid != null) [ "-DVIDPID=${vidPid}" ];

  installPhase = ''
    ${lib.optionalString (picoBoard != null)
      "mv pico_openpgp.uf2 pico_openpgp_${
        lib.optionalString (vidPid != null) "${vidPid}-"
      }${picoBoard}-${version}.uf2"
    }
    ${lib.optionalString (
      vidPid != null && picoBoard == null
    ) "mv pico_openpgp.uf2 pico_openpgp_${vidPid}-${version}.uf2"}

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
