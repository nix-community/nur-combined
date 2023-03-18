{ lib, stdenv, sources }:

stdenv.mkDerivation rec {
  inherit (sources.programs-db) pname version src;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    install -Dm 0644 ./programs.sqlite -D $out/programs.sqlite
    runHook postInstall
  '';

  meta = with lib; {
    description = "programs.sqlite for command-not-found";
    homepage = "https://channels.nixos.org";
    license = licenses.mit;
  };
}
