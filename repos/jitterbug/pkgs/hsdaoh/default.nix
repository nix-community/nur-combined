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
  flac,
  ...
}:
let
  pname = "hsdaoh";
  version = "0-unstable-2026-04-04";

  rev = "c7681852653585667715b7b56acfd390e40976a9";
  hash = "sha256-9RmTd9/luQzwmb/rPzVbTBEN4M6CP9U5WdFxr4TpFqc=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "steve-m";
    repo = "hsdaoh";
  };

  nativeBuildInputs = [
    udevCheckHook
    cmake
    pkg-config
    ninja
    libusb1
    libuvc
    flac
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
    homepage = "https://github.com/steve-m/hsdaoh";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
