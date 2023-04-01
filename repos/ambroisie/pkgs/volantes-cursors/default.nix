{ lib, fetchFromGitHub, inkscape, stdenvNoCC, xcursorgen }:
stdenvNoCC.mkDerivation rec {
  pname = "volantes-cursors";
  version = "unstable-2020-06-06";

  src = fetchFromGitHub {
    owner = "varlesh";
    repo = pname;
    rev = "d1d290ff42cc4fa643716551bd0b02582b90fd2f";
    hash = "sha256-irMN/enoo90nYLfvSOScZoYdvhZKvqqp+grZB2BQD9o=";
  };

  nativeBuildInputs = [
    inkscape
    xcursorgen
  ];

  postPatch = ''
    patchShebangs .
    # The script tries to build in its source directory...
    substituteInPlace build.sh --replace \
      ': "''${BUILD_DIR:="$SCRIPT_DIR"/build}"' \
      "BUILD_DIR=$(pwd)/build"
    substituteInPlace build.sh --replace \
      ': "''${OUT_DIR:="$SCRIPT_DIR"/dist}"' \
      "OUT_DIR=$(pwd)/dist"
  '';

  buildPhase = ''
    HOME="$NIX_BUILD_ROOT" ./build.sh
  '';

  installPhase = ''
    make install PREFIX= DESTDIR=$out/
  '';

  meta = with lib; {
    description = "Classic cursor with a flying style";
    homepage = "https://github.com/varlesh/volantes-cursors";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ambroisie ];
  };
}
