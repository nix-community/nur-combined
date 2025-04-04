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
  pname = "slazav-hr";
  version = "2025-03-03";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_hr";
    rev = "b61f2a83c12b860a833a3f09f78de203edb88569";
    hash = "sha256-/o0SlycXWvsHawz0bJcW9+UrBpS21ho/lHNkqhWCIpo=";
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

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Slazav mountains";
    homepage = "https://slazav.xyz/maps/hr.htm";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
