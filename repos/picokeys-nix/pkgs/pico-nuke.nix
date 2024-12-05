{
  picoBoard ? "waveshare_rp2040_one",

  lib,
  stdenv,
  fetchFromGitHub,

  cmake,
  gcc-arm-embedded,
  picotool,
  python3,
  pico-sdk-full,
}:

stdenv.mkDerivation rec {
  pname = "pico-nuke";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "polhenarejos";
    repo = "pico-nuke";
    rev = "v${version}";
    hash = "sha256-58PodRPYCtvGuzCguGmbulcq5qPKDVf2xylQ7NaG514=";
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
    ];

  installPhase = ''
    ${lib.optionalString (picoBoard != null) "mv flash_nuke.uf2 flash_nuke_${picoBoard}-${version}.uf2"}
    mkdir -p $out
    cp -r *.uf2 $out
  '';

  meta = {
    description = "Raspberry Pi flash nuke to reset the flash to all 0s for all supported boards";
    homepage = "https://github.com/polhenarejos/pico-nuke";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
