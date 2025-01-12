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
  pname = "slazav-fi";
  version = "2025-01-07";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_fi";
    rev = "f3f13bd52cfd6a9775af35dea7343902d17dd258";
    hash = "sha256-GYLMbsNlBBt3hdCKZwc7BxTgaVf0KmcB0kFYC5dk4kM=";
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
    description = "custom render of Finnish topo maps";
    homepage = "https://slazav.xyz/maps/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
