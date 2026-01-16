{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  callPackage,
  zig_0_14,
}:

stdenvNoCC.mkDerivation {
  pname = "zlint-unstable";
  version = "unstable-2025-11-29";

  src = fetchFromGitHub {
    owner = "DonIsaac";
    repo = "zlint";
    rev = "48d0266d0c9967612da09e8c3a43001ff62ff79a";
    hash = "sha256-N5ztky9fLMdoDR7wHXKOLJY3sgd2DUmWBJ9NHCrf8PY=";
  };

  nativeBuildInputs = [ zig_0_14 ];

  dontConfigure = true;
  dontInstall = true;

  preBuild = ''
    export HOME=$TMPDIR
    export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
    mkdir -p $ZIG_GLOBAL_CACHE_DIR
    ln -s ${callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
  '';

  buildPhase = ''
    runHook preBuild
    zig build --prefix $out -Doptimize=ReleaseSafe
    runHook postBuild
  '';

  meta = with lib; {
    description = "A linter for the Zig programming language (unstable/HEAD)";
    homepage = "https://github.com/DonIsaac/zlint";
    license = licenses.mit;
    platforms = platforms.unix ++ platforms.darwin;
    maintainers = [ ];
    mainProgram = "zlint";
  };
}
