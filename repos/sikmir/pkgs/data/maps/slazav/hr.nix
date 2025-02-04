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
  version = "2025-01-27";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_hr";
    rev = "947b237a977453db2e5cbb961d5b3842ce770697";
    hash = "sha256-nXd1y1TVIhwS3XP2DzeFKsDsdYWk2Q6xOtlh9kmve8o=";
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

  buildFlags = [ "out" ];

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
