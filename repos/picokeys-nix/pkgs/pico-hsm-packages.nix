{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,

  cmake,
  pico-sdk-full,
  picotool,
  gcc-arm-embedded,

  pico-keys-sdk,
}:

let
  version = "5.6";
  src = fetchFromGitHub {
    owner = "polhenarejos";
    repo = "pico-hsm";
    rev = "v${version}";
    hash = "sha256-mCpNzFlj4mJNJ01dlBDIrSXI5fCPSF+YgPXnesq3XlY=";
  };
  pico-hsm =
    {
      picoBoard ? "waveshare_rp2040_one",
      usbVid ? null,
      usbPid ? null,
      vidPid ? null,
      eddsaSupport ? false,
    }:
    stdenv.mkDerivation {
      pname = "pico-hsm${lib.optionalString eddsaSupport "-eddsa"}";
      inherit version src;

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
          "mv pico_hsm.uf2 pico_hsm${lib.optionalString eddsaSupport "_eddsa"}_${
            lib.optionalString (vidPid != null) "${vidPid}-"
          }${picoBoard}-${version}.uf2"
        }
        ${lib.optionalString (
          vidPid != null && picoBoard == null
        ) "mv pico_hsm.uf2 pico_hsm${lib.optionalString eddsaSupport "_eddsa"}_${vidPid}-${version}.uf2"}
        mkdir -p $out
        cp -r *.uf2 $out
      '';

      meta = {
        description = "Hardware Security Module (HSM) for Raspberry Pico and ESP32";
        homepage = "https://github.com/polhenarejos/pico-hsm";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ vizid ];
      };
    };
  pico-hsm-tool =
    {
      pycvc,
      pypicohsm,
    }:
    python3.pkgs.buildPythonApplication rec {
      inherit src;
      pname = "pico-hsm-tool";
      version = "2.2";
      pyproject = true;

      doCheck = false;

      sourceRoot = "source/tools";

      patchPhase = ''
        mv pico-hsm-tool.py pico-hsm-tool
        cat > setup.py <<EOF
        from setuptools import setup
        setup(
          name = "${pname}",
          version = "${version}",
          scripts = ["pico-hsm-tool"],
          package_dir = {"": "."}
        )
        EOF
      '';

      build-system = [ python3.pkgs.setuptools ];

      dependencies = with python3.pkgs; [
        keyring
        cryptography
        pycvc
        pypicohsm
      ];

      meta = {
        description = "Tool for interacting with the Pico HSM";
        homepage = "https://github.com/polhenarejos/pico-hsm";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ vizid ];
      };
    };
in
{
  inherit pico-hsm pico-hsm-tool;
}
