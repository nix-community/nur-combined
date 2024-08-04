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
  version = "2024-06-16";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_podm";
    rev = "f6357a7379567d5997325fd0f5b2078c327096f8";
    hash = "sha256-j71hgn0ISol8Cna0EQgY18z182YZmMLyH2UIYwmamK8=";
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

  buildFlags = [
    "in"
    "out"
  ];

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
