{ stdenv }:

stdenv.mkDerivation rec {
  name = "gpg-clean-up-${version}";
  version = "0.0.1";
  src = ./.;
  phases = [ "installPhase" "fixupPhase" ];
  installPhase = ''
    install -Dm755 $src/gpg-clean-up $out/bin/gpg-clean-up
  '';
}
