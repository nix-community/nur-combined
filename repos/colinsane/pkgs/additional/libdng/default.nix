{ stdenv
, fetchFromGitLab
, lib
, libtiff
, meson
, ninja
, pkg-config
, scdoc
}:
stdenv.mkDerivation {
  pname = "libdng";
  version = "unstable-2024-04-28";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "libdng";
    rev = "9c7b18e7ff687a8c69704dc6fc8e7689e2532060";
    hash = "sha256-Im1suQcSvsmos4B9onpa/i+DV9ylW5zxJYzGF3XqBZA=";
  };

  depsBuildBuild = [
    pkg-config  # to find scdoc for cross builds
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

