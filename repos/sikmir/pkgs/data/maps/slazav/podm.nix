{
  lib,
  stdenv,
  fetchFromGitHub,
  bc,
  cgpsmapper,
  git,
  gmaptool,
  libjpeg,
  mapsoft2,
  netpbm,
  sqlite,
  zip,
}:

stdenv.mkDerivation {
  pname = "slazav-podm";
  version = "2024-12-09";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_podm";
    rev = "af2c30996e71fcd8dbc4756d289ec2d7e7a198e0";
    hash = "sha256-hG2oLMTNTZUF/BFIgbS8CYSofjryKyN2fpTqHKjhQcU=";
    leaveDotGit = true;
  };

  nativeBuildInputs = [
    bc
    cgpsmapper
    git
    gmaptool
    libjpeg
    mapsoft2
    netpbm
    sqlite
    zip
  ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  buildFlags = [ "out" ];

  installPhase = ''
    install -Dm644 OUT/* -t $out
  '';

  meta = {
    description = "Slazav Moscow region map";
    homepage = "https://slazav.xyz/maps/podm.htm";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
