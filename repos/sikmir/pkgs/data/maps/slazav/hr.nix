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
  version = "2024-12-15";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "map_hr";
    rev = "32824f6c621812a8ed12a16d267e215ea39cd2b8";
    hash = "sha256-EPc4y2Wm0tu2Ah58HHrqz4gsszOyufeTEBnKEJB6xs4=";
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
