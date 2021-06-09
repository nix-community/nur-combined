{ pkgs ? import <nixpkgs> { }, stdenv ? pkgs.stdenv, fetchurl ? pkgs.fetchurl, lib ? pkgs.lib }:

stdenv.mkDerivation rec {
  name = "ii-1.8";

  src = fetchurl {
    url = "https://dl.suckless.org/tools/${name}.tar.gz";
    sha256 = "1lk8vjl7i8dcjh4jkg8h8bkapcbs465sy8g9c0chfqsywbmf3ndr";
  };

  buildInputs = with pkgs; [ openssl ];

  installPhase = ''
    make install PREFIX=$out
  '';

  patches = [ ./ii-1.8-usernames.diff ];

  meta = {
    homepage = "https://tools.suckless.org/ii/";
    license = lib.licenses.mit;
    description = "Irc it, simple FIFO based irc client";
    platforms = lib.platforms.unix;
  };
}
