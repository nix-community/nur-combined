{ lib
, stdenv
, fetchFromGitHub
, ncurses
, nodejs
, pnpm
, yarn
, just
,
}:
let
  rev = "27c6fbc7fa534ce891db75361f2d2a27db64bb63";
in
stdenv.mkDerivation rec {
  pname = "projectdo";
  version = "unstable-2025-03-08";

  src = fetchFromGitHub {
    owner = "paldepind";
    repo = "projectdo";
    inherit rev;
    hash = "sha256-ZBAzHo7/Sy8uyjWganSFs/uOJkmuDP8WxU3WVGttPTo=";
  };

  dontConfigure = true;
  dontBuild = true;

  doCheck = true;
  checkPhase = ''
    make test
  '';

  nativeBuildInputs = [
    ncurses
    nodejs
    pnpm
    yarn
    just
  ];

  installPhase = ''
    make PREFIX=$out install
    install -D functions/* -t $out/share/fish/vendor_functions.d
    install -D completions/* -t $out/share/fish/vendor_completions.d
  '';

  meta = {
    description = "Context-aware single-letter project commands to speed up your terminal workflow";
    homepage = "https://github.com/paldepind/projectdo";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ alanpearce ];
    mainProgram = "projectdo";
    platforms = lib.platforms.all;
  };
}
