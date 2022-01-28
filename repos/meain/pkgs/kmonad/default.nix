# kmonad nix package
{ pkgs, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "kmonad";
  name = pname;
  version = "0.4.1";

  src = pkgs.fetchurl {
    url = "https://github.com/kmonad/kmonad/releases/download/${version}/kmonad-${version}-linux";
    sha256 = "sha256-g55Y58wj1t0GhG80PAyb4PknaYGJ5JfaNe9RlnA/eo8=";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${src} $out/bin/kmonad
    chmod +x $out/bin/*
  '';

  meta = with lib; {
    description = "An advanced keyboard manager";
    homepage = "https://github.com/kmonad/${pname}";
    license = licenses.mit;
  };
}
