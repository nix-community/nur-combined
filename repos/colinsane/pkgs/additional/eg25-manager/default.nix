# package based on:
# - <https://github.com/NixOS/mobile-nixos/pull/573>

{ lib
, stdenv
, callPackage
, fetchFromGitLab
, gnugrep
, meson
, ninja
, pkg-config
, scdoc
, curl
, glib
, libgudev
, libusb1
# if true, build with MMGLIB. if false, eg25-manager won't speak to modemmanager and will be usable standalone
, withModemManager ? true, modemmanager
}:

let
  # eg25-manager needs to be made compatible with libgpiod 2.0 API. see:
  # - <https://github.com/NixOS/mobile-nixos/pull/573#issuecomment-1666739462>
  # - <https://gitlab.com/mobian1/eg25-manager/-/issues/45>
  # nixpkgs libgpiod was bumped 2023-07-29:
  # - <https://github.com/NixOS/nixpkgs/pull/246018>
  libgpiod1 = callPackage ./libgpiod1.nix { };
in
stdenv.mkDerivation rec {
  pname = "eg25-manager";
  version = "0.4.6";

  src = fetchFromGitLab {
    owner = "mobian1";
    repo = "eg25-manager";
    rev = version;
    hash = "sha256-2JsdwK1ZOr7ljNHyuUMzVCpl+HV0C5sA5LAOkmELqag=";
  };

  postPatch = ''
    substituteInPlace 'udev/80-modem-eg25.rules' \
      --replace '/bin/grep' '${gnugrep}/bin/grep'
  '';

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs = [
    glib # Contains gdbus-codegen program
    meson
    ninja
    pkg-config
    scdoc
  ];

  buildInputs = [
    curl
    glib
    libgpiod1
    libgudev
    libusb1
  ] ++ lib.optionals withModemManager [
    modemmanager
  ];

  passthru = {
    inherit libgpiod1;
  };

  meta = with lib; {
    description = "Manager daemon for the Quectel EG25 mobile broadband modem";
    homepage = "https://gitlab.com/mobian1/eg25-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
