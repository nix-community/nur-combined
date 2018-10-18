{ pkgs, stdenv }:


stdenv.mkDerivation rec {
  name = "download-archiver-${version}";
  version = "0.0.1";

  src = ./.;

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    install -Dm755 $src/download-archiver.rb $out/bin/download-archiver

    substituteInPlace $out/bin/download-archiver \
      --subst-var-by ruby_bin ${pkgs.ruby}/bin/ruby
  '';
}
