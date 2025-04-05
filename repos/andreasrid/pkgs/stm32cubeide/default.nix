{
  lib,
  buildFHSEnv,
  fetchzip,
  requireFile,
  stdenvNoCC,
  unzip,
  ncurses5,
  glib,
  gtk3,
  xorg,
  zlib,
  krb5,
  libusb1,
  extraPkgs ? [ ],
}:

let
  package = stdenvNoCC.mkDerivation rec {
    pname = "stm32cubeide";
    version = "1.17.0_23558_20241125_2245";

    src = requireFile {
      name = "en.st-stm32cubeide_1.17.0_23558_20241125_2245_amd64.sh.zip";
      url = "https://www.st.com/en/development-tools/stm32cubeide.html";
      sha256 = "sha256-eDxCZpXe8YSlApQUn6kpsZqcqpea6l4jRh2N9VKDxzI=";
    };

    nativeBuildInputs = [
      unzip
    ];

    sourceRoot = ".";
    unpackPhase = ''
      unzip $src
    '';

    buildPhase = ''
      chmod +rx st-stm32cubeide_${version}_amd64.sh
      ./st-stm32cubeide_${version}_amd64.sh --noexec --nox11 --target .
    '';

    installPhase = ''
      mkdir -p $out/{bin,opt/STM32CubeIde}

      tar -C $out/opt/STM32CubeIde -x -f st-stm32cubeide_1.17.0_23558_20241125_2245_amd64.tar.gz
      ln -s /opt/STM32CubeIde/stm32cubeide $out/bin/

      chmod +rx ./st-stlink-server.*.install.sh
      ./st-stlink-server.*.install.sh --noexec --nox11 --target $out/opt/stlink-server
      ln -s /opt/stlink-server/stlink-server $out/bin/

      #mkdir -p stlink-udev
      #chmod +rx st-stlink-udev-rules-*-linux-noarch.sh
      #./st-stlink-udev-rules-*-linux-noarch.sh --quiet --noexec --nox11 --target $out/opt/stlink-udev

      #mkdir jlink-udev
      #./segger-jlink-udev-rules-*-linux-noarch.sh --quiet --noexec --nox11 --target $out/opt/jlink-udev
    '';

    meta = with lib; {
      description = "STM32CubeIDE is an all-in-one multi-OS development tool, which is part of the STM32Cube software ecosystem.";
      longDescription = ''
        STM32CubeIDE is an advanced C/C++ development platform with peripheral configuration, code generation, code compilation, and debug features for STM32 microcontrollers and microprocessors. It is based on the Eclipse®/CDT™ framework and GCC toolchain for the development, and GDB for the debugging. It allows the integration of the hundreds of existing plugins that complete the features of the Eclipse® IDE.
      '';
      homepage = "https://www.st.com/en/development-tools/stm32cubeide.html";
      sourceProvenance = with sourceTypes; [ binaryBytecode ];
      maintainers = with maintainers; [ ];
      platforms = [ "x86_64-linux" ];
    };
  };
in
buildFHSEnv {
  inherit (package) pname version meta;
  runScript = "stm32cubeide";
  targetPkgs =
    let
      ncurses' = ncurses5.overrideAttrs (old: {
        configureFlags = old.configureFlags ++ [ "--with-termlib" ];
        postFixup = "";
      });
    in
    _:
    [
      package
      glib
      gtk3
      xorg.libX11
      xorg.libXext
      xorg.libXtst
      xorg.libXrender
      xorg.libXi
      zlib
      krb5.lib
      ncurses'
      (ncurses'.override { unicodeSupport = false; })
      libusb1
    ]
    ++ extraPkgs;
}
