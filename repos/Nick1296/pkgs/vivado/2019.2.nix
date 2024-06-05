{ stdenv, lib, bash, bashInteractive, coreutils, writeScript, gnutar, gzip
, requireFile, patchelf, procps, makeWrapper, ncurses, zlib, libX11, libXrender
, libxcb, libXext, libXtst, libXi, libxcrypt, glib, freetype, gtk2
, buildFHSUserEnv, gcc, ncurses5, glibc, gperftools, fontconfig, liberation_ttf
, writeTextFile, nettools }:

let
  extractedSource = stdenv.mkDerivation rec {
    name = "vivado-2019.2-extracted";

    src = requireFile rec {
      name = "Xilinx_Vivado_2019.2_1106_2127.tar.gz";
      url =
        "https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Vivado_2019.2_1106_2127.tar.gz";
      sha256 = "15hfkb51axczqmkjfmknwwmn8v36ss39wdaay14ajnwlnb7q2rxh";
      message = ''
        Unfortunately, we cannot download file ${name} automatically.
        Please go to ${url} to download it yourself, and add it to the Nix store.

        Notice: given that this is a large (25.6GB) file, the usual methods of addings files
        to the Nix store (nix-store --add-fixed / nix-prefetch-url file:///) will likely not work.
        Use the method described here: https://nixos.wiki/wiki/Cheatsheet#Adding_files_to_the_store
      '';
    };

    buildInputs = [ patchelf ];

    builder = writeScript "${name}-builder" ''
       #! ${bash}/bin/bash
       source $stdenv/setup

       mkdir -p $out/
       tar -xvf $src --strip-components=1 -C $out/ Xilinx_Vivado_2019.2_1106_2127/

       patchShebangs $out/
       patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
         $out/tps/lnx64/jre9.0.4/bin/java

       for f in $(find $out -executable -type f)
       do
         patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $f || true
      done
    '';
  };

  vivadoPackage = stdenv.mkDerivation rec {
    name = "vivado-2019.2";

    nativeBuildInputs = [ zlib ];
    buildInputs = [ patchelf procps ncurses makeWrapper ];

    extracted = "${extractedSource}";
    builder = ./builder-2019.2.sh;
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
      description = "Xilinx Vivado 2019.2 HLx Edition";
      homepage = "https://www.xilinx.com/products/design-tools/vivado.html";
      license = lib.licenses.unfree;
    };
  };

in buildFHSUserEnv {
  name = "vivado2019.2";
  targetPkgs = _pkgs: [
    vivadoPackage
    #add cable drivers udev rules
    (writeTextFile {
      name = "xilinx-diligent-usb-udev";
      destination = "/etc/udev/rules.d/52-xilinx-digilent-usb.rules";
      text = ''
        ATTR{idVendor}=="1443", MODE:="666"
        ACTION=="add", ATTR{idVendor}=="0403", ATTR{manufacturer}=="Digilent", MODE:="666"
      '';
    })
    (writeTextFile {
      name = "xilinx-pcusb-udev";
      destination = "/etc/udev/rules.d/52-xilinx-pcusb.rules";
      text = ''
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="0008", MODE="666"
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="0007", MODE="666"
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="0009", MODE="666"
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="000d", MODE="666"
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="000f", MODE="666"
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="0013", MODE="666"
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="0015", MODE="666"
      '';
    })
    (writeTextFile {
      name = "xilinx-ftdi-usb-udev";
      destination = "/etc/udev/rules.d/52-xilinx-ftdi-usb.rules";
      text = ''
        ACTION=="add", ATTR{idVendor}=="0403", ATTR{manufacturer}=="Xilinx", MODE:="666"
      '';
    })
  ];
  multiPkgs = pkgs:
    with pkgs; [
      coreutils
      gcc
      ncurses5
      zlib
      glibc.dev
      libxcrypt-legacy
    ];
  runScript = "bash";
}
