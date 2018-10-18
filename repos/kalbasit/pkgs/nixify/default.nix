{ stdenv }:

stdenv.mkDerivation rec {
  name = "nixify";
  version = "0.0.1";
  src = ./.;
  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm755 $src/nixify $out/bin/nixify
    install -Dm644 $src/envrc $out/share/nixify/templates/envrc
    install -Dm644 $src/shell.nix $out/share/nixify/templates/shell.nix
  '';
}
