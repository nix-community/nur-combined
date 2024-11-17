{
  stdenv,
  fetchFromGitLab,
  lib,
  libtiff,
  meson,
  ninja,
  pkg-config,
  scdoc,
}:
stdenv.mkDerivation {
  pname = "libdng";
  version = "unstable-2024-08-28";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "libdng";
    rev = "bd4372559f1b470e2916fa3c04469a18e466b02e";
    hash = "sha256-6+qB11Vzsejxxuu174ZIGB+A+O9UW5H8DVmWWDdSoEo=";
  };

  depsBuildBuild = [
    pkg-config # to find scdoc for cross builds
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
  ];

  buildInputs = [
    libtiff
  ];

  meta = with lib; {
    description = "Interface library between libtiff and the world to make sure the output is valid DNG";
    homepage = "https://libdng.me.gapixels.me";
    license = licenses.mit;
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
  };
}
