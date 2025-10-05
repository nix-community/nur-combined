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
  writableTmpDirAsHomeHook,
  zip,
}:

stdenv.mkDerivation {
  pname = "slazav-fi";
  version = "2025-03-20";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_fi";
    rev = "6517526cd0b92c4a272139065dbbc0779bce67b0";
    hash = "sha256-EVGjkw4ouvlGl8ugwbyvVFO/SscbCprplqUbVi8uNio=";
    leaveDotGit = true;
  };

  postPatch = ''
    substituteInPlace vmaps.conf \
      --replace-fail "/home/sla/mapsoft2/programs/ms2render/" ""
  '';

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

  meta = {
    description = "custom render of Finnish topo maps";
    homepage = "https://slazav.xyz/maps/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
