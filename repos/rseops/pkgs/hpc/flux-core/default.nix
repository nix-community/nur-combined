{ lib
, stdenv
, fetchurl
, pkgs
, maintainers
}:


stdenv.mkDerivation rec {
  pname = "flux-core";
  version = "0.45.0";

  src = fetchurl {
    url = "https://github.com/flux-framework/flux-core/releases/download/v${version}/flux-core-${version}.tar.gz";
    sha256 = "6550fe682c1686745e1d9c201daf18f9c57691468124565c9252d27823d2fe46";
  };


  nativeBuildInputs = [
    pkgs.bash
    pkgs.pkgconfig
    pkgs.autoconf
    pkgs.automake
    pkgs.libtool
  ];

  buildInputs = [
    pkgs.cudatoolkit
    pkgs.libarchive
    pkgs.ncurses
    pkgs.zmqpp
    pkgs.czmq
    pkgs.hwloc
    pkgs.lua
    pkgs.luajitPackages.luaposix
    pkgs.python310
    pkgs.libuuid
    pkgs.python310Packages.cffi
    pkgs.python310Packages.pyyaml
    pkgs.python310Packages.jsonschema
    pkgs.python310Packages.docutils
    pkgs.jansson
    pkgs.lz4
    pkgs.sqlite
    pkgs.asciidoc
  ];

  # A native nix build won't have /bin/bash or possibly /usr/env/bin bash
  preConfigure = ''
    sed -i '1d' ./etc/completions/get_builtins.sh;
  '';

  meta = with lib; {
    description = "A next-generation resource manager.";
    homepage = "https://github.com/flux-framework/flux-core";
    license = licenses.lgpl3;
    maintainers = [ maintainers.vsoch ];
  };
}
