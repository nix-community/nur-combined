{
  lib,
  stdenv,
  fetchFromGitHub,
  bc,
  cgpsmapper,
  gmaptool,
  mapsoft2,
}:

stdenv.mkDerivation {
  pname = "slazav-hr";
  version = "2021-02-07";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_hr";
    rev = "f476649b5ff12fb6fa037e6fb023c1da19639b84";
    sha256 = "0z2782smylf62ank8bpdhnvldqy46xai8ahg87yfyl203zcpp07h";
  };

  nativeBuildInputs = [
    bc
    cgpsmapper
    gmaptool
    mapsoft2
  ];

  buildFlags = [
    "directories"
    "reg_img"
  ];

  installPhase = "install -Dm644 OUT/all_*.img -t $out";

  meta = {
    description = "Slazav mountains";
    homepage = "http://slazav.xyz/maps/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
