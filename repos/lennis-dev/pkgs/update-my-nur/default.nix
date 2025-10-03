{
  lib,
  stdenv,
  makeWrapper,
  jq,
  nix-prefetch-github
}: let
  inherit (lib) makeBinPath;
in
  stdenv.mkDerivation rec {
    name = "update-my-nur";
    version = "0.0.1";
    src = ./.;
    nativeBuildInputs = [makeWrapper];

    buildInputs = [jq nix-prefetch-github];
    installPhase = ''
      install -Dm755 update.sh $out/bin/update-my-nur
      wrapProgram $out/bin/update-my-nur --prefix PATH : '${makeBinPath buildInputs}'
    '';
    ##
  }
