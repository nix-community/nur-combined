{ lib
, stdenv
, fetchFromGitHub
, callPackage
, zig_0_14
}:

stdenv.mkDerivation {
  pname = "zlint-unstable";
  version = "unstable-2025-12-06";

  src = fetchFromGitHub {
    owner = "DonIsaac";
    repo = "zlint";
    rev = "48d0266d0c9967612da09e8c3a43001ff62ff79a";
    hash = "sha256-N5ztky9fLMdoDR7wHXKOLJY3sgd2DUmWBJ9NHCrf8PY=";
  };

  nativeBuildInputs = [
    zig_0_14.hook
  ];

  postPatch = ''
    ln -s ${callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
  '';

  zigBuildFlags = [ "-Doptimize=ReleaseSafe" ];

  meta = with lib; {
    description = "A linter for the Zig programming language (unstable/HEAD)";
    homepage = "https://github.com/DonIsaac/zlint";
    license = licenses.mit;
    platforms = platforms.unix ++ platforms.darwin;
    maintainers = [ ];
    mainProgram = "zlint";
  };
}
