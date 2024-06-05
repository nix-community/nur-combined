{ stdenv, coreutils-full, lib, bash, coreutils, writeScript, gnutar, gzip
, requireFile, patchelf, procps, makeWrapper, ncurses, zlib, libX11, libXrender
, libxcb, libXext, libXtst, libXi, libxcrypt, glib, freetype, gtk2
, buildFHSEnvChroot, gcc, ncurses5, glibc, gperftools, fontconfig
, liberation_ttf, writeTextFile, nettools, bashInteractive, lsb-release, libXft
, gtk3, python3, opencl-clhpp, ocl-icd, opencl-headers, libidn, fetchurl, unzip
, graphviz }:

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

  extractedUpdate = stdenv.mkDerivation rec {
    name = "vivado-2019.2.1_extracted_update";

    src = requireFile rec {
      name = "Xilinx_Vivado_Vitis_Update_2019.2.1_1205_0436.tar.gz";
      url =
        "https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Vivado_Vitis_Update_2019.2.1_1205_0436.tar.gz";
      sha256 = "1wn3inbi0nlyg8pskhsi0y6492rymi94shgcxghymxwgj574df3b";
      message = ''
        Unfortunately, we cannot download file ${name} automatically.
        Please go to ${url} to download it yourself, and add it to the Nix store.

        Notice: given that this is a large (9GB) file, the usual methods of addings files
        to the Nix store (nix-store --add-fixed / nix-prefetch-url file:///) will likely not work.
        Use the method described here: https://nixos.wiki/wiki/Cheatsheet#Adding_files_to_the_store
      '';
    };

    buildInputs = [ patchelf procps ncurses makeWrapper nettools ];

    builder = writeScript "${name}-builder" ''
        #! ${bash}/bin/bash
        source $stdenv/setup

        mkdir -p $out/
        tar -xvf $src --strip-components=1 -C $out/ Xilinx_Vivado_Vitis_Update_2019.2.1_1205_0436/

        patchShebangs $out/
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          $out/tps/lnx64/jre9.0.4/bin/java
      for f in $(find $out -executable -type f)
        do
          patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $f || true
       done
    '';
  };

  deps = [
    coreutils-full
    bashInteractive
    patchelf
    procps
    ncurses
    makeWrapper
    zlib
    stdenv.cc.cc
    ncurses
    zlib
    libX11
    libXext
    libXft
    libXrender
    libxcb
    libXext
    libXtst
    libXi
    freetype
    gtk2
    gtk3
    python3
    (libidn.overrideAttrs (_old: {
      # we need libidn.so.11 but nixpkgs has libidn.so.12
      src = fetchurl {
        url = "mirror://gnu/libidn/libidn-1.34.tar.gz";
        sha256 = "sha256-Nxnil18vsoYF3zR5w4CvLPSrTpGeFQZSfkx2cK//bjw=";
      };
    }))

    # to compile some xilinx examples
    opencl-clhpp
    ocl-icd
    opencl-headers

    # from installLibs.sh
    graphviz
    (lib.hiPrio gcc)
    unzip
    nettools
    glib
    libxcrypt
    gperftools
    glibc.dev
    fontconfig
    (ncurses5.overrideAttrs (old: {
      configureFlags = old.configureFlags ++ [ "--with-termlib" ];
      postFixup = "";
    }))
    lsb-release
    freetype
    liberation_ttf
  ];
  libPath = lib.makeLibraryPath deps;

in buildFHSEnvChroot {
  name = "vivado2019.2.1_fhs";
  targetPkgs = _pkgs:
    deps ++ [
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
      (writeTextFile {
        name = "vivado_2019.2_install_config";
        destination = "/opt/Xilinx/vivado_2019.2_install_config.txt";
        text = ''
          #### Vivado HL System Edition Install Configuration ####
          Edition=Vivado HL System Edition
          # Path where Xilinx software will be installed.
          Destination=/opt/Xilinx
          # Choose the Products/Devices the you would like to install.
          Modules=Zynq UltraScale+ MPSoC:1,DocNav:1,Virtex UltraScale+ HBM:1,Virtex UltraScale+ 58G:1,Virtex UltraScale+ 58G ES:1,Virtex UltraScale+:1,Zynq-7000:1,Kintex UltraScale+:1,Engineering Sample Devices:1,Model Composer:1,Kintex UltraScale:1,System Generator for DSP:1,Virtex UltraScale:1,Zynq UltraScale+ RFSoC:1,Versal AI Core Series ES1:1,Versal Prime Series ES1:1,Virtex UltraScale+ HBM ES:1,Zynq UltraScale+ RFSoC ES:1
          # Choose the post install scripts you'd like to run as part of the finalization step. Please note that some of these scripts may require user interaction during runtime.
          InstallOptions=Acquire or Manage a License Key:1,Enable WebTalk for Vivado to send usage statistics to Xilinx (Always enabled for WebPACK license):1
          ## Shortcuts and File associations ##
          # Choose whether Start menu/Application menu shortcuts will be created or not.
          CreateProgramGroupShortcuts=1
          # Choose the name of the Start menu/Application menu shortcut. This setting will be ignored if you choose NOT to create shortcuts.
          ProgramGroupFolder=Xilinx Design Tools
          #Choose whether shortcuts will be created for All users or just the Current user. Shortcuts can be created for all users only if you run the installer as administrator.
          CreateShortcutsForAllUsers=0
          # Choose whether shortcuts will be created on the desktop or not.
          CreateDesktopShortcuts=1
          # Choose whether file associations will be created or not.
          CreateFileAssociation=1
          # Choose whether disk usage will be optimized (reduced) after installation
          EnableDiskUsageOptimization=1
        '';
      })
      (writeTextFile {
        name = "vivado_2019.2.1_update_config";
        destination = "/opt/Xilinx/vivado_2019.2.1_update_config.txt";
        text = ''
          #### Vivado HL System Edition Install Configuration ####
          Edition=Vivado HL System Edition
          # Path where Xilinx software will be installed.
          Destination=/opt/Xilinx
          ## Shortcuts and File associations ##
          # Choose whether Start menu/Application menu shortcuts will be created or not.
          CreateProgramGroupShortcuts=1
          # Choose the name of the Start menu/Application menu shortcut. This setting will be ignored if you choose NOT to create shortcuts.
          ProgramGroupFolder=Xilinx Design Tools
          #Choose whether shortcuts will be created for All users or just the Current user. Shortcuts can be created for all users only if you run the installer as administrator.
          CreateShortcutsForAllUsers=0
          # Choose whether shortcuts will be created on the desktop or not.
          CreateDesktopShortcuts=1
          # Choose whether file associations will be created or not.
          CreateFileAssociation=1
          # Choose whether disk usage will be optimized (reduced) after installation
          EnableDiskUsageOptimization=1
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
  profile = ''
        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${libPath}"
        export LC_NUMERIC="en_US.UTF-8"
        if [ -e /opt/Xilinx/Vivado/2019.2/settings.sh ]; then
          source /opt/Xilinx/Vivado/2019.2/settings.sh
          vivado
        else
    ls -l /opt/Xilinx
          #${extractedSource}/xsetup --agree XilinxEULA,3rdPartyEULA,WebTalkTerms --config /opt/Xilinx/vivado_2019.2_install_config.txt
          #${extractedUpdate}/xsetup --agree XilinxEULA,3rdPartyEULA,WebTalkTerms --config /opt/Xilinx/vivado_2019.2.1_update_config.txt
        fi
  '';
  runScript = "bash";
}
