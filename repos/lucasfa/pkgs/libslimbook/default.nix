{
  stdenv,
  lib,
  pkgs,
  fetchFromGitHub,
  gcc,
  pkg-config,
  meson,
  ninja,
  libinputSupport ? true,
  libinput,
  efibootmgrSupport ? true,
  efibootmgr,
  usbutilsSupport ? true,
  usbutils,
  pciutilsSupport ? true,
  pciutils,
  flatpakSupport ? true,
  flatpak,
}:

stdenv.mkDerivation rec {
  pname = "libslimbook";
  version = "1.18.4";

  src = fetchFromGitHub {
    owner = "Slimbook-Team";
    repo = pname;
    tag = version;
    hash = "sha256-mGEGFrdu2DXQ8fykOQrY/AhInbY1+2L8CvWFICm5Lkg=";
  };
  enableParallelBuilding = true;

  nativeBuildInputs = [
    gcc
    pkg-config
    meson
    ninja
  ];

  buildInputs =
    [ ]
    ++ lib.optional libinputSupport libinput
    ++ lib.optional efibootmgrSupport efibootmgr
    ++ lib.optional usbutilsSupport usbutils
    ++ lib.optional pciutilsSupport pciutils
    ++ lib.optional flatpakSupport flatpak;
  # lib.optional qc71_slimbook_laptopSupport qc71_slimbook_laptop

  patches = [
    ./flatpak.diff
    ./efi_and_lib.diff
  ];
  postPatch = ''
    substituteInPlace \
      src/slimbookctl.cpp \
        --replace-fail "/usr/libexec" "$out/libexec"
  ''
  + ''
    substituteInPlace \
      slimbook-settings.service \
      slimbook-sleep \
        --replace-fail "/usr/bin" "$out/bin"
  ''
  + ''
    substituteInPlace \
      report.d/libinput \
        --replace-fail "libinput" "${pkgs.libinput}/bin/libinput"
  ''
  + ''
    substituteInPlace \
      report.d/efiboot \
        --replace-fail "efibootmgr" "${pkgs.efibootmgr}/bin/efibootmgr"
  ''
  + ''
    substituteInPlace \
      report.d/pci \
        --replace-fail "lspci" "${pkgs.pciutils}/bin/lspci"
  ''
  + ''
    substituteInPlace \
      report.d/usb \
        --replace-fail "lsusb" "${pkgs.usbutils}/bin/lsusb"
  '';

  meta = {
    description = "";
    homepage = "https://github.com/Slimbook-Team/${pname}";
    license = lib.licenses.lgpl3Plus;
    mainProgram = "slimbookctl";
    platforms = lib.platforms.linux;
  };
}
