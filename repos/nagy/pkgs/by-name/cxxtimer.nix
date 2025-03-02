{
  stdenv,
  lib,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "cxxtimer";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "andremaravilha";
    repo = "cxxtimer";
    rev = "v${version}";
    hash = "sha256-kmS1FeZWrwhPzg6DBCOzyW0jHg/zQDxtZc3fufadsus=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/include/ $src/cxxtimer.hpp

    runHook postInstall
  '';

  meta = with lib; {
    description = "A timer for modern C++";
    homepage = "https://github.com/andremaravilha/cxxtimer";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
