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
  pname = "slazav-podm";
  version = "2021-01-09";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_podm";
    rev = "c95a381155986f9f621e5d26b21bda041ad8c24f";
    sha256 = "0jsrjzmg23rp3ay5149llqrq6pnr66wf7siphwn7gisz5g60pgpf";
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
    description = "Slazav Moscow region map";
    homepage = "http://slazav.xyz/maps/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
