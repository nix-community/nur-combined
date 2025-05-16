{ lib
, stdenv
, fetchFromGitHub
, ncurses
, nodejs
, bun
, pnpm
, yarn
, just
, nix
,
}:
let
  rev = "8de1acb1975d3811b8c3a8f175c8dfabd800da10";
in
stdenv.mkDerivation rec {
  pname = "projectdo";
  version = "unstable-2025-03-08";

  src = fetchFromGitHub {
    owner = "paldepind";
    repo = "projectdo";
    inherit rev;
    hash = "sha256-WAhw5meVs7k4oaQFyS4LxG7TIrNK8Tl+hSAiFzdeZVM=";
  };

  dontConfigure = true;
  dontBuild = true;

  doCheck = true;
  checkPhase = ''
    make test
  '';

  nativeBuildInputs = [
    ncurses
  ];

  nativeCheckInputs = [
    bun
    nodejs
    pnpm
    yarn
    just
    nix
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
