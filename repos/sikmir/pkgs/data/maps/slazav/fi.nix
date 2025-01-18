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
  version = "2025-01-16";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_fi";
    rev = "31110d93183c2f62b3ec7865442c09f2f5d1c335";
    hash = "sha256-0qqW4YmJ8klQ4sA5NggMxDeci8Im24UxHYppitScTl8=";
    leaveDotGit = true;
  };

  postPatch = ''
    substituteInPlace vmaps.conf \
      --replace-fail "/home/sla/mapsoft2/programs/ms2render/" ""
  '';

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
    description = "custom render of Finnish topo maps";
    homepage = "https://slazav.xyz/maps/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
