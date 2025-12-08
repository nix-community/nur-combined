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
  version = "2025-12-08";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_hr";
    rev = "f94a4efc92aa7439254d2c3ae397cbbcc5f51881";
    hash = "sha256-9ugdeGZxaYVUX3nMS3qRoQBqwdNBtUIUk8qZOOr6sjU=";
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
    description = "Slazav mountains";
    homepage = "https://slazav.xyz/maps/hr.htm";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
