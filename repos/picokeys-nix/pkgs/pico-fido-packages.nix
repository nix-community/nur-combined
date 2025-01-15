{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:
let
  version = "6.2";
  source = fetchFromGitHub {
    owner = "polhenarejos";
    repo = "pico-fido";
    rev = "v${version}";
    hash = "sha256-wzJyJq9kWzuDOqahd90YcbLx3w+JZSuClFkCcDponSA=";
    fetchSubmodules = true;
  };
  pico-fido =
    {
      picoBoard ? "waveshare_rp2040_one",
      usbVid ? null,
      usbPid ? null,
      vidPid ? null,

      cmake,
      pico-sdk-full,
      picotool,
      gcc-arm-embedded,
    }:
    stdenv.mkDerivation {
      pname = "pico-fido";
      inherit version;

      src = source;

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
          "mv pico_fido.uf2 pico_fido_${
            lib.optionalString (vidPid != null) "${vidPid}-"
          }${picoBoard}-${version}.uf2"
        }
        ${lib.optionalString (
          vidPid != null && picoBoard == null
        ) "mv pico_fido.uf2 pico_fido_${vidPid}-${version}.uf2"}
        mkdir -p $out
        cp -r *.uf2 $out
      '';

      meta = {
        description = "Transforming a Raspberry Pico into a FIDO Passkey";
        homepage = "https://github.com/polhenarejos/pico-fido";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ vizid ];
      };
    };

  pico-fido-tool-words = python3.pkgs.buildPythonPackage {
    pname = "words";
    inherit version;

    format = "other";

    src = source;

    installPhase = "install -Dm755 $src/tools/words.py $out/words.py";
    pythonImportsCheck = [ "words" ];
  };

  pico-fido-tool = python3.pkgs.buildPythonApplication {
    pname = "pico-fido-tool";
    version = "1.8";

    format = "other";

    src = source;

    dependencies = with python3.pkgs; [
      pico-fido-tool-words
      cryptography
      fido2
    ];

    installPhase = "install -Dm755 $src/tools/pico-fido-tool.py $out/bin/pico-fido-tool";

    meta = {
      description = "Tool for interacting with the Pico Fido";
      homepage = "https://github.com/polhenarejos/pico-fido";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ vizid ];
    };
  };
in
{
  inherit pico-fido pico-fido-tool;
}
