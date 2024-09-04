{ lib, stdenv, fetchFromGitHub, ncurses }:
stdenv.mkDerivation {
  name = "pcalc";
  src = fetchFromGitHub {
    owner = "alt-romes";
    repo = "programmer-calculator";
    rev = "060c9969170e78e9259e801b3bdfa548fdbbb504";
    hash = "sha256-JQcYCYKdjdy8U2XMFzqTH9kAQ7CFv0r+sC1YfuAm7p8=";
  };

  buildInputs = [
    ncurses
  ];

  installPhase = ''
    install -D pcalc $out/bin/pcalc
  '';

  meta = {
    description = "Terminal calculator made for programmers working with multiple number representations, sizes, and overall close to the bits";
    homepage = "https://github.com/alt-romes/programmer-calculator";
    platforms = lib.platforms.all;
  };
}
