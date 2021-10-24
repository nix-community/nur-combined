{ pkgs, stdenv, fetchFromGitHub, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "xmake-dev";
  version = "2.5x";

  rev = "72f482c4d675e4e82b6d37c10428de47f25d9b45";
  src = fetchFromGitHub {
    owner = "xmake-io";
    repo = "xmake";
    rev = "72f482c";
    sha256 = "sha256-JePIoVeaIxJ1HDtobu4I7UIkAM9hqaFK7OaUZ5B6KYs=";
    fetchSubmodules = true;
  };

  buildInputs = [
  ];

  configurePhase = ''
    '';

  buildPhase = ''
    mkdir ./bin
    make DESTDIR=./bin build
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share
    make install PREFIX=$out
    #so we get proper permissions
    find $out/share -type f -print0 | xargs -0 chmod 646
    chmod 644 $out/share/xmake/core/main.lua
  '';

  meta = with lib; {
    description = "A cross-platform build utility based on Lua ";
    homepage = "https://xmake.io/";
    license = with licenses; [ asl20 ];
    platforms = platforms.all;
    broken = true;
    maintainers = [ "uniquepointer" ];
  };
}
