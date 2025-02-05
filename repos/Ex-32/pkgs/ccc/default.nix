{
  lib,
  stdenv,
  fetchFromGitHub,
}: let
  rev = "3ba139f52fe7740267e9cb5d4ecd2b2a9a2bf69a";
  hash = "sha256-wngyFU59vz3KDfWqw1g77HuUbYEZokOYwBziyRmEV+E=";
in
  stdenv.mkDerivation rec {
    pname = "ccc";
    version = builtins.substring 0 7 rev;

    src = fetchFromGitHub {
      owner = "ssleert";
      repo = "ccc";
      inherit rev hash;
    };

    installPhase = ''
      mkdir -p $out/bin
      cp "${pname}" $out/bin/${pname}
    '';

    meta = {
      homepage = "https://github.com/ssleert/ccc";
      description = "A Linux ram cache dropper in C without *alloc()";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "ccc";
    };
  }
