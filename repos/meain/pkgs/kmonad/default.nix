# kmonad nix package
{ pkgs, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "kmonad";
  name = pname;
  version = "0.4.5";

  src = pkgs.fetchurl {
    url = "https://github.com/kmonad/kmonad/releases/download/${version}/kmonad";
    sha256 = "sha256-BkC0ETONKpSnWZGQiSA9nTduRHVUYTsJFFafVuRq+rc=";
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
