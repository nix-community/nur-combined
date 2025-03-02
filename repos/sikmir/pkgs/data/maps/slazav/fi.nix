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
  writableTmpDirAsHomeHook,
  zip,
}:

stdenv.mkDerivation {
  pname = "slazav-fi";
  version = "2025-02-01";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_fi";
    rev = "1cc868653012c2a31441ccc0e8246be9666851b2";
    hash = "sha256-6psZAaBLQ9LvrZgMXKkKHt9k4KJciF9rCZSYsFGjew4=";
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
    writableTmpDirAsHomeHook
    zip
  ];

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
