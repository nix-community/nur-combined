{pkgs ? import <nixpkgs> {}}:

pkgs.stdenv.mkDerivation {
  pname = "sw";
  version = "git";

  src = pkgs.fetchFromGitHub {
    owner = "jroimartin";
    repo = "sw";
    rev = "d8e8c8dc08cea31a45b6c7442ac6f212f6e5fdc9";
    sha256 = "1hb6zwnldxh3lj805zh2ghxdpn3sxc13n6gnfzxradvdaxpncnc6";
  };

  installPhase = ''
    DESTDIR=$out PREFIX=/ make install
    mkdir -p $out/share/sw
    install ./style.css $out/share/sw/style.css
    install ./sw.conf.def $out/share/sw/sw.conf.def
  '';
}
