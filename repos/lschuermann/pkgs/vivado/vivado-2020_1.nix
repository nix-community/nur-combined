{ stdenv
, lib
, bash
, coreutils
, writeScript
, gnutar
, gzip
, requireFile
, patchelf
, procps
, makeWrapper
, ncurses
, zlib
, libX11
, libXrender
, libxcb
, libXext
, libXtst
, libXi
, glib
, freetype
, gtk2
, buildFHSEnv
, gcc
, ncurses5
, glibc
}:

let
  extractedSource = stdenv.mkDerivation rec {
    name = "vivado-2020.1-extracted";

    src = requireFile rec {
      name = "Xilinx_Unified_2020.1_0602_1208.tar.gz";
      url = "https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2020.1_0602_1208.tar.gz";
      sha256 = "1sz34wklz2ywfkyxbl2lvmb1khza2y6kmf9s8p2618pcc4dgiq59";
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
      tar -xvf $src --strip-components=1 -C $out/ Xilinx_Unified_2020.1_0602_1208/

      patchShebangs $out/
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/tps/lnx64/jre9.0.4/bin/java
      sed -i -- 's|/bin/rm|rm|g' $out/xsetup
    '';
  };

  vivadoPackage = stdenv.mkDerivation rec {
    name = "vivado-2020.1";

    nativeBuildInputs = [ zlib ];
    buildInputs = [ patchelf procps ncurses makeWrapper ];

    extracted = "${extractedSource}";

    builder = ./builder-2020_1.sh;
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
  targetPkgs = _pkgs: [
    vivadoPackage
  ];
  multiPkgs = pkgs: [
    coreutils
    gcc
    ncurses5
    zlib
    glibc.dev
  ];
  runScript = "vivado";
}
