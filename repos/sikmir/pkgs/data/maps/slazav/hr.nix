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
  pname = "slazav-hr";
  version = "2024-08-03";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_hr";
    rev = "d65d437f4cb9a450538c17778f22f9e129773c39";
    hash = "sha256-P+H6vXL+lvebhpup5KH6l5HZQiwPKvhCR8YsOmcItFE=";
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
    description = "Slazav mountains";
    homepage = "https://slazav.xyz/maps/hr.htm";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
