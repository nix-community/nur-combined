{
  lib,
  stdenv,
  fetchgit,
  cmake,
  pkg-config,
  libusb1,
  ...
}:
stdenv.mkDerivation rec {
  pname = "osmo-fl2k";
  version = "0.2.1";

  src = fetchgit {
    url = "https://gitea.osmocom.org/sdr/osmo-fl2k.git";
    rev = "refs/tags/v${version}";
    hash = "sha256-8Q/lM7nWps12Pekat90fgk2TssO3ht5VNygTx3Rl+lE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libusb1
  ];

  cmakeFlags = [
    (lib.cmakeBool "INSTALL_UDEV_RULES" true)
    (lib.cmakeOptionType "PATH" "UDEV_RULES_PATH" "${placeholder "out"}/lib/udev/rules.d")
  ];

  meta = with lib; {
    description = "Turns FL2000-based USB 3.0 to VGA adapters into low cost DACs";
    homepage = "https://osmocom.org/projects/osmo-fl2k/wiki";
    license = licenses.gpl2Plus;
  };
}
