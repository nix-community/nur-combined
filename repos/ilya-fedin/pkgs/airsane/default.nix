{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  coreutils,
  sane-backends,
  avahi,
  libusb1,
  libjpeg,
  libpng,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "airsane";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "SimulPiscator";
    repo = "AirSane";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U2FrcoLMZ9WmAkqMYnPOOV2JRkMUVowqzyfr2/NKbcU=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
        --replace-fail ' /etc/airsane' ' ''${CMAKE_INSTALL_PREFIX}/etc/airsane' \
        --replace-fail 'DESTINATION /' 'DESTINATION '
    substituteInPlace systemd/airsaned.service.in \
        --replace-fail '=/bin' '=${coreutils}/bin' \
        --replace-fail '/usr/bin/scanimage' '${sane-backends}/bin/scanimage' \
        --replace-fail '=saned' '=scanner'
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    sane-backends
    avahi
    libusb1
    libjpeg
    libpng
  ];

  meta = {
    description = "Publish SANE scanners to MacOS, Android, and Windows via Apple AirScan";
    homepage = "https://github.com/SimulPiscator/AirSane";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
  };
})
