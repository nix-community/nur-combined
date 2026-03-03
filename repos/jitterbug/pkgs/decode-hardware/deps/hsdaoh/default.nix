{
  maintainers,
  lib,
  stdenv,
  fetchFromGitHub,
  udevCheckHook,
  cmake,
  pkg-config,
  ninja,
  libusb1,
  libuvc,
  ...
}:
let
  pname = "hsdaoh";
  version = "0-unstable-2025-08-15";

  rev = "02e72ac62262a1144bfe067287e93b9853562c44";
  hash = "sha256-s9U1CGEce3BCREfvDnOTu23tFlT0z6C6sfTAojQptQ4=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "Stefan-Olt";
    repo = "hsdaoh";
  };

  nativeBuildInputs = [
    udevCheckHook
    cmake
    pkg-config
    ninja
    libusb1
    libuvc
  ];

  cmakeFlags = [
    (lib.cmakeFeature "INSTALL_UDEV_RULES" "ON")
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "/etc/udev/rules.d" "$out/lib/udev/rules.d"
  '';

  meta = {
    inherit maintainers;
    description = "High Speed Data Acquisition over HDMI.";
    homepage = "https://github.com/Stefan-Olt/hsdaoh";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
