{
  lib,
  stdenv,
  fetchFromGitHub,
  bc,
  cgpsmapper,
  fig2dev,
  git,
  gmaptool,
  imagemagick,
  libjpeg,
  mapsoft2,
  netpbm,
  sqlite,
  unstableGitUpdater,
  writableTmpDirAsHomeHook,
  zip,
}:

stdenv.mkDerivation {
  pname = "slazav-podm";
  version = "2025-05-29";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_podm";
    rev = "c7d0e406d8743d13d5cb0fc1d1c3a3ada713bf7d";
    hash = "sha256-rp1sPyCOghPPzMw3ikbjmv73AklDFUNIxrnU03hPmiA=";
    leaveDotGit = true;
  };

  nativeBuildInputs = [
    bc
    cgpsmapper
    fig2dev
    git
    gmaptool
    imagemagick
    libjpeg
    mapsoft2
    netpbm
    sqlite
    writableTmpDirAsHomeHook
    zip
  ];

  preBuild = ''
    make -C pics
  '';

  buildFlags = [ "out" ];

  installPhase = ''
    install -Dm644 OUT/* -t $out
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Slazav Moscow region map";
    homepage = "https://slazav.xyz/maps/podm.htm";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
