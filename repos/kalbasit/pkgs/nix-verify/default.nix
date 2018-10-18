{ stdenv }:

stdenv.mkDerivation rec {
  name = "nix-verify";

  src = ./.;

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    install -Dm755 $src/nix-verify $out/bin/nix-verify
  '';
}
