{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, qtbase
, obs-studio
, xorg
, libxkbcommon
}:
stdenv.mkDerivation rec {
  pname = "input-overlay";
  version = "5.0.0-rc1";

  src = fetchFromGitHub {
    owner = "univrsal";
    repo = "input-overlay";
    rev = "v${version}";
    sha256 = "sha256-G7tkzIr8ex9vB1wvxZePnsMBxEHIFYbdrHtSGdDu7c0=";
    fetchSubmodules = true;
  };

  patches = [
    ./dont-hardcode-install-path.patch
  ];

  dontWrapQtApps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    obs-studio
    qtbase

    # libuiohook deps
    xorg.libX11
    xorg.libXtst
    xorg.libXt
    xorg.libXinerama
    xorg.libXi
    xorg.libxcb
    libxkbcommon
    xorg.libxkbfile
  ];

  cmakeFlags = [
    "-DDEB_INSTALLER=ON"
  ];

  postInstall = ''
    rm $out/COPYING.txt
    mkdir -p $out/bin
    mv $out/client/client $out/bin/input-overlay-client
    mv $out/share/obs/obs-plugins/input-overlay/data/locale \
      $out/share/obs/obs-plugins/input-overlay/
    rm $out/share/obs/obs-plugins/input-overlay/data/example.html
    rmdir $out/share/obs/obs-plugins/input-overlay/data
    rmdir $out/client
  '';

  meta = {
    description = "Plugin for showing keyboard, mouse, and gamepad inputs in OBS Studio.";
    homepage = "https://github.com/univrsal/input-overlay";
    license = lib.licenses.gpl2Only;
    broken = lib.versionAtLeast lib.version "22.11pre";
  };
}
