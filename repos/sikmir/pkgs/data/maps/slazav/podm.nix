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
  version = "2025-01-27";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_podm";
    rev = "ab455d4eba552a9cdc6b0356cc59667220b6ac3b";
    hash = "sha256-ctakSU79ZhsZj1QoZ/1MdT7nOM2fiPB6OzwOnhXAqZM=";
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
