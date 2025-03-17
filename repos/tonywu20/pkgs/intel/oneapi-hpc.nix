{ lib
, stdenv
, fetchurl
, glibc
, libX11
, glib
, libnotify
, xdg-utils
, ncurses
, nss
, at-spi2-core
, libxcb
, libdrm
, gtk3
, mesa
, qt515
, zlib
, xorg
, atk
, nspr
, dbus
, pango
, cairo
, gdk_pixbuf
, cups
, expat
, libxkbcommon
, alsa-lib
, file
, at-spi2-atk
, freetype
, fontconfig
, xml2
}:

stdenv.mkDerivation rec {
  version = "2025.0.1.46";
  hpc_version = "2025.0.1.47";
  version_dir = "2025.0";
  name = "intel-oneapi-${version}";

  # For localy downloaded offline installers
  # sourceRoot = "/data/scratch/intel/oneapi_installer";

  # For installer fetching (no warranty of the links)
  sourceRoot = ".";
  srcs = [
    # (fetchurl {
    #   url = "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/dfc4a434-838c-4450-a6fe-2fa903b75aa7/intel-oneapi-base-toolkit-2025.0.1.46_offline.sh";
    #   sha256 = "094a7872bbdb1c1e1d0e65da553497de819132b298b0ddf624b45003cda82844";
    # })
    (fetchurl {
      url = "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/b7f71cf2-8157-4393-abae-8cea815509f7/intel-oneapi-hpc-toolkit-2025.0.1.47_offline.sh";
      sha256 = "941a4d4ccc05cfb60f5edbe7c2c5e34197cce561c12d565cd8c6fefe6b752fb6";
    })
  ];

  nativeBuildInputs = [ file ];

  propagatedBuildInputs = [
    glibc
    glib
    libnotify
    xdg-utils
    ncurses
    nss
    at-spi2-core
    libxcb
    libdrm
    gtk3
    mesa
    qt515.full
    zlib
    freetype
    fontconfig
    xorg.xorgproto
    xorg.libX11
    xorg.libXt
    xorg.libXft
    xorg.libXext
    xorg.libSM
    xorg.libICE
  ];

  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    libX11
    glib
    libnotify
    xdg-utils
    ncurses
    nss
    at-spi2-core
    libxcb
    libdrm
    gtk3
    mesa
    qt515.full
    zlib
    atk
    nspr
    dbus
    pango
    cairo
    gdk_pixbuf
    cups
    expat
    libxkbcommon
    alsa-lib
    at-spi2-atk
    xorg.libXcomposite
    xorg.libxshmfence
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xml2
  ];

  phases = [ "installPhase" "fixupPhase" "installCheckPhase" "distPhase" ];

  installPhase = ''
    cd $sourceRoot
    mkdir -p $out/tmp
    if [ "$srcs" = "" ]
    then
      # base_kit="./intel-oneapi-base-toolkit-${version}_offline.sh"
      hpc_kit="./intel-oneapi-hpc-toolkit-${hpc_version}_offline.sh"
    else
      # base_kit=`echo $srcs|cut -d" " -f1`
      hpc_kit=`echo $srcs|cut -d" " -f2`
    fi
    # Extract files
    # bash $base_kit --log $out/basekit_install_log --extract-only --extract-folder $out/tmp -a --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept
    bash $hpc_kit --log $out/hpckit_install_log --extract-only --extract-folder $out/tmp -a --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept 
    for file in `grep -l -r "/bin/sh" $out/tmp`
    do
      sed -e "s,/bin/sh,${stdenv.shell},g" -i $file
    done
    export HOME=$out
    # Patch the bootstraper binaries and libs
    # for files in `find $out/tmp/intel-oneapi-base-toolkit-${version}_offline/lib`
    # do
    #   patchelf --set-rpath "${glibc}/lib:$libPath:$out/tmp/intel-oneapi-base-toolkit-${version}_offline/lib" $file 2>/dev/null || true
    # done
    # patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${glibc}/lib:$libPath:$out/tmp/intel-oneapi-base-toolkit-${version}_offline/lib" $out/tmp/intel-oneapi-base-toolkit-${version}_offline/bootstrapper
    for files in `find $out/tmp/intel-oneapi-hpc-toolkit-${hpc_version}_offline/lib`
    do
      patchelf --set-rpath "${glibc}/lib:$libPath:$out/tmp/intel-oneapi-hpc-toolkit-${hpc_version}_offline/lib" $file 2>/dev/null || true
    done
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${glibc}/lib:$libPath:$out/tmp/intel-oneapi-hpc-toolkit-${hpc_version}_offline/lib" $out/tmp/intel-oneapi-hpc-toolkit-${hpc_version}_offline/bootstrapper
    # launch install
    export LD_LIBRARY_PATH=${zlib}/lib
    # $out/tmp/intel-oneapi-base-toolkit-${version}_offline/install.sh --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp --eula accept -s --ignore-errors
    $out/tmp/intel-oneapi-hpc-toolkit-${hpc_version}_offline/install.sh --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp --eula accept -s --ignore-errors 
    rm -rf $out/tmp
  '';

  postFixup = ''
    echo "Fixing rights..."
    chmod u+w -R $out
    echo "Patching rpath and interpreter..."
    for dir in `find $out -mindepth 1 -maxdepth 1 -type d`
    do
      echo "   $dir"
      for file in `find $dir -type f -exec file {} + | grep ELF| awk -F: '{print $1}'`
      do
          echo "       $file"
          patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath '$ORIGIN'":${glibc}/lib:$libPath:$dir/latest/lib64:$out/${version_dir}/lib" $file 2>/dev/null || true
      done
    done
    # Add missing lib into DT_NEEDED of clang
    clang_binary=`find $out -type f -name "clang"`
    xfortcom_binary=`find $out -type f -name "xfortcom"`
    patchelf --add-needed libstdc++.so.6 $clang_binary
    patchelf --add-needed libstdc++.so.6 $xfortcom_binary
  '';

  meta = {
    description = "Intel OneAPI + HPCKit";
    maintainers = [ lib.maintainers.tonywu20 ];
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}

