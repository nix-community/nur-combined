{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cxxtimer";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "andremaravilha";
    repo = "cxxtimer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+Q4ES5ZuSnq8+wddBuonAn6rDYNLYg5O+GFadaNyAyM=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/include/ cxxtimer.hpp

    runHook postInstall
  '';

  meta = {
    description = "Timer for modern C++";
    homepage = "https://github.com/andremaravilha/cxxtimer";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
