{
  stdenv,
  lib,
  runCommand,
  autoPatchelfHook,
  alsa-lib,
  bash,
  buildFHSUserEnvBubblewrap,
  busybox,
  coreutils,
  envsubst,
  ffmpeg_4,
  fontconfig,
  freetype,
  gcc,
  glib,
  glibc,
  gnutar,
  gperftools,
  gtk2,
  gtk3,
  gzip,
  icu68,
  liberation_ttf,
  libX11,
  libxcb,
  libxcrypt-legacy,
  libXext,
  libXi,
  libXrender,
  libXtst,
  libXxf86vm,
  makeWrapper,
  ncurses5,
  patchelf,
  procps,
  requireFile,
  writeScript,
  xorg,
  zlib,
}:
# Modified from https://github.com/lschuermann/nur-packages/blob/master/pkgs/vivado/vivado-2022_2.nix
let
  extractedSource = stdenv.mkDerivation rec {
    pname = "vivado-extracted";
    version = "2022.2";

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

    installPhase = ''
      mkdir -p $out/
      tar -xvf $src --strip-components=1 -C $out/ Xilinx_Unified_2022.2_1014_8888/
    '';

    postFixup = ''
      patchShebangs $out/
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/tps/lnx64/jre11.0.11_9/bin/java
      sed -i -- 's|/bin/rm|rm|g' $out/xsetup
    '';
  };

  libraries = [
    (runCommand "busybox-arch" {} "mkdir -p $out/bin && ln -sf ${busybox}/bin/arch $out/bin/arch")
    coreutils
    fontconfig
    freetype
    gcc
    glib
    glibc.dev
    gperftools
    gtk2
    liberation_ttf
    libX11
    libxcb
    libxcrypt-legacy
    libXext
    libXi
    libXrender
    libXtst
    ncurses5
    zlib
  ];

  fhs = buildFHSUserEnvBubblewrap {
    name = "vivado-fhs";
    multiPkgs = pkgs: libraries;
    unshareUser = false;
    unshareIpc = false;
    unsharePid = false;
    unshareNet = false;
    unshareUts = false;
  };

  vivadoPackage = stdenv.mkDerivation rec {
    pname = "vivado";
    version = "2022.2";

    nativeBuildInputs = [envsubst zlib];
    buildInputs = [patchelf procps ncurses5 makeWrapper];

    src = extractedSource;

    buildPhase = ''
      runHook preBuild

      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${lib.makeLibraryPath libraries}"
      export HOME=$(pwd)

      cp ${./spoof_homedir.c} spoof_homedir.c
      gcc -shared -fPIC -D "FAKE_HOME=\"$(pwd)\"" spoof_homedir.c -o spoof_homedir.so -ldl
      export LD_PRELOAD="$(pwd)/spoof_homedir.so"

      cat ${./install_config.txt} | envsubst > install_config.txt

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # The installer will be killed as soon as it says that post install
      # tasks have failed.  This is required because it tries to run the
      # unpatched scripts to check if the installation has
      # succeeded. However, these scripts will fail because they have not
      # been patched yet, and the installer will proceed to delete the
      # installation if not killed.
      ($src/xsetup --agree 3rdPartyEULA,XilinxEULA --batch Install --config install_config.txt || true) | while read line
      do
        [[ "''${line}" == *"Execution of Pre/Post Installation Tasks Failed"* ]] && echo "killing installer!" && ((pkill -9 -f "extracted/tps/lnx64/jre/bin/java") || true)
        echo ''${line}
      done

      # Move desktop entries
      # Choose one of copy from desktop or .local/share
      mkdir -p $out/share/applications
      # cp -r Desktop $out/share/applications

      # For .local/share shortcuts, skip installer entries
      for F in .local/share/applications/*; do
          cat "$F" | grep "xsetup" && continue
          cp "$F" $out/share/applications/
      done
      sed -i -E "s#Exec=(.*)#Exec=${fhs}/bin/vivado-fhs -c '\\1'#" $out/share/applications/*

      runHook postInstall
    '';

    dontStrip = true;

    postFixup = ''
      # Remove all created references to $src, to avoid making it a runtime dependency
      #
      # If this package is upgraded to a newer Vivado version, this must be verified to be
      # effective using nix why-depends <this built derivation> $src
      sed -i -- "s|$src|/nix/store/00000000000000000000000000000000-vivado-2022.2-extracted|g" $out/opt/.xinstall/Vivado_2022.2/data/instRecord.dat
      sed -i -- "s|$src|/nix/store/00000000000000000000000000000000-vivado-2022.2-extracted|g" $out/opt/.xinstall/xic/data/instRecord.dat
      sed -i -- "s|$src|/nix/store/00000000000000000000000000000000-vivado-2022.2-extracted|g" $out/opt/.xinstall/DocNav/data/instRecord.dat

      # Add Vivado and xsdk to bin folder
      mkdir $out/bin
      makeWrapper ${fhs}/bin/vivado-fhs $out/bin/vivado \
        --add-flags "-c" \
        --add-flags "$out/opt/Vivado/2022.2/bin/vivado"
      makeWrapper ${fhs}/bin/vivado-fhs $out/bin/vitis_hls \
        --add-flags "-c" \
        --add-flags "$out/opt/Vitis_HLS/2022.2/bin/vitis_hls"
    '';

    meta = {
      description = "Xilinx Vivado WebPack Edition";
      homepage = "https://www.xilinx.com/products/design-tools/vivado.html";
      license = lib.licenses.unfree;
    };
  };
in
  vivadoPackage
