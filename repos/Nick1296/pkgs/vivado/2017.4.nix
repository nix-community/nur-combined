{ stdenv, lib, bash, coreutils, writeScript, gnutar, gzip, requireFile, patchelf
, procps, makeWrapper, ncurses, zlib, libX11, libXrender, libxcb, libXext
, libXtst, libXi, libxcrypt, glib, freetype, gtk2, buildFHSUserEnv, gcc
, ncurses5, glibc, gperftools, fontconfig, liberation_ttf, writeTextFile }:

let
  extractedSource = stdenv.mkDerivation rec {
    name = "vivado-2017.4_extracted_setup";

    src = requireFile rec {
      name = "Xilinx_Vivado_SDK_2017.4_1216_1.tar.gz";
      url =
        "https://www.xilinx.com/member/forms/download/xef-vivado.html?filename=Xilinx_Vivado_SDK_2017.4_1216_1.tar.gz";
      sha256 = "0p7bafc5jdmawcw6vvs7wniar5z6pvcbzjqwniwa2dzyz04pqama";
      message = ''
        Unfortunately, we cannot download file ${name} automatically.
        Please go to ${url} to download it yourself, and add it to the Nix store.

        Notice: given that this is a large (35.51GB) file, the usual methods of addings files
        to the Nix store (nix-store --add-fixed / nix-prefetch-url file:///) will likely not work.
        Use the method described here: https://nixos.wiki/wiki/Cheatsheet#Adding_files_to_the_store
      '';
    };

    buildInputs = [ patchelf procps ncurses makeWrapper ];

    builder = writeScript "${name}-builder" ''
      #! ${bash}/bin/bash
      source $stdenv/setup

      mkdir -p $out/
      tar -xvf $src --strip-components=1 -C $out/ Xilinx_Vivado_SDK_2017.4_1216_1/

      patchShebangs $out/
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/tps/lnx64/jre/bin/java
      sed -i -- 's|/bin/rm|rm|g' $out/xsetup
    '';
  };

  vivadoPackage = stdenv.mkDerivation rec {
    name = "vivado-2017.4";

    nativeBuildInputs = [ zlib ];
    buildInputs = [ patchelf procps ncurses makeWrapper ];

    extracted = "${extractedSource}";

    builder = ./builder-2017.4.sh;
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
      mainProgram = "vivado";
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  };

in buildFHSUserEnv {
  name = "vivado2017.4";
  targetPkgs = _pkgs: [
    vivadoPackage
    #add cable drivers udev rules
    (writeTextFile {
      name = "xilinx-dilligent-usb-udev";
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
  multiPkgs = pkgs: [ coreutils gcc ncurses5 zlib glibc.dev ];
  runScript = "vivado";
}
