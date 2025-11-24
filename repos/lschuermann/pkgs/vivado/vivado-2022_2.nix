{
  stdenv,
  lib,
  bash,
  coreutils,
  writeScript,
  gnutar,
  gzip,
  requireFile,
  patchelf,
  procps,
  makeWrapper,
  ncurses,
  zlib,
  libX11,
  libXrender,
  libxcb,
  libXext,
  libXtst,
  libXi,
  libxcrypt,
  glib,
  freetype,
  gtk2,
  buildFHSEnv,
  gcc,
  ncurses5,
  glibc,
  gperftools,
  fontconfig,
  liberation_ttf,
}:

let
  extractedSource = stdenv.mkDerivation rec {
    name = "vivado-2022.2-extracted";

    src = requireFile rec {
      name = "Xilinx_Unified_2022.2_1014_8888.tar.gz";
      url = "https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2022.2_1014_8888.tar.gz";
      sha256 = "1s28fwhnjqkng9imqbd89cm8xaf33lq4f511i3irf127lhnav1v0";
      message = ''
        Unfortunately, we cannot download file ${name} automatically.
        Please go to ${url} to download it yourself, and add it to the Nix store.

        Notice: given that this is a large (35.51GB) file, the usual methods of addings files
        to the Nix store (nix-store --add-fixed / nix-prefetch-url file:///) will likely not work.
        Use the method described here: https://nixos.wiki/wiki/Cheatsheet#Adding_files_to_the_store
      '';
    };

    buildInputs = [ patchelf ];

    builder = writeScript "${name}-builder" ''
      #! ${bash}/bin/bash
      source $stdenv/setup

      mkdir -p $out/
      tar -xvf $src --strip-components=1 -C $out/ Xilinx_Unified_2022.2_1014_8888/

      patchShebangs $out/
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/tps/lnx64/jre11.0.11_9/bin/java
      sed -i -- 's|/bin/rm|rm|g' $out/xsetup
    '';
  };

  vivadoPackage = stdenv.mkDerivation rec {
    name = "vivado-2022.2";

    nativeBuildInputs = [ zlib ];
    buildInputs = [
      patchelf
      procps
      ncurses
      makeWrapper
    ];

    extracted = "${extractedSource}";

    builder = ./builder-2022_2.sh;
    inherit ncurses;

    libPath = lib.makeLibraryPath [
      stdenv.cc.cc
      ncurses
      zlib
      libX11
      libXrender
      libxcb
      libXext
      libXtst
      libXi
      freetype
      gtk2
      glib
      libxcrypt
      gperftools
      glibc.dev
      fontconfig
      liberation_ttf
    ];

    meta = {
      description = "Xilinx Vivado WebPack Edition";
      homepage = "https://www.xilinx.com/products/design-tools/vivado.html";
      license = lib.licenses.unfree;
    };
  };
in
buildFHSEnv {
  name = "vivado";
  targetPkgs = _pkgs: [ vivadoPackage ];
  multiPkgs =
    pkgs: with pkgs; [
      coreutils
      gcc
      ncurses5
      zlib
      glibc.dev
      libxcrypt-legacy
    ];
  runScript = "vivado";
}
