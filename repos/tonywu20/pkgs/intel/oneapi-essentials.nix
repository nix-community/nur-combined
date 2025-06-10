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
  version = "2025.1.1.8";
  version_dir = "2025.1";
  name = "intel-oneapi-essentials-${version}";

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
      url = "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/ee18bd01-7360-4bde-abc0-05f780620549/intel-cpp-essentials-2025.1.1.8_offline.sh";
      sha256 = "af3e5395480984ec14ee4819273c051d29884b34f553f512e2bd35d3c14604ec";
    })
    (fetchurl {
      url = "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/2238465b-cfc7-4bf8-ad04-e55cb6577cba/intel-fortran-essentials-2025.1.1.8_offline.sh";
      sha256 = "aa4bcf4eac5e3ea768c345e42ec35278ca38099f30181486daf7e04ad24dc888";
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
      cpp_kit="./intel-cpp-essentials-${version}_offline.sh"
      fort_kit="./intel-fortran-essentials-${version}_offline.sh"
    else
      cpp_kit=`echo $srcs|cut -d" " -f1`
      fort_kit=`echo $srcs|cut -d" " -f2`
    fi
    # Extract files
    bash $cpp_kit --log $out/cpp_kit_install_log --extract-only --extract-folder $out/tmp -a --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept
    bash $fort_kit --log $out/fort_kit_install_log --extract-only --extract-folder $out/tmp -a --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept 
    for file in `grep -l -r "/bin/sh" $out/tmp`
    do
      sed -e "s,/bin/sh,${stdenv.shell},g" -i $file
    done
    export HOME=$out
    Patch the bootstraper binaries and libs
    for files in `find $out/tmp/intel-cpp-essentials-${version}_offline/lib`
    do
      patchelf --set-rpath "${glibc}/lib:$libPath:$out/tmp/intel-cpp-essentials-${version}_offline/lib" $file 2>/dev/null || true
    done
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${glibc}/lib:$libPath:$out/tmp/intel-cpp-essentials-${version}_offline/lib" $out/tmp/intel-oneapi-base-toolkit-${version}_offline/bootstrapper
    for files in `find $out/tmp/intel-cpp-essentials-${version}_offline/lib`
    do
      patchelf --set-rpath "${glibc}/lib:$libPath:$out/tmp/intel-cpp-essentials-${version}_offline/lib" $file 2>/dev/null || true
    done
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${glibc}/lib:$libPath:$out/tmp/intel-cpp-essentials-${version}_offline/lib" $out/tmp/intel-cpp-essentials-${version}_offline/bootstrapper
    for files in `find $out/tmp/intel-fortran-essentials-${version}_offline/lib`
    do
      patchelf --set-rpath "${glibc}/lib:$libPath:$out/tmp/intel-fortran-essentials-${version}_offline/lib" $file 2>/dev/null || true
    done
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${glibc}/lib:$libPath:$out/tmp/intel-fortran-essentials-${version}_offline/lib" $out/tmp/intel-fortran-essentials-${version}_offline/bootstrapper
    # launch install
    export LD_LIBRARY_PATH=${zlib}/lib
    $out/tmp/intel-cpp-essentials-${version}_offline/install.sh --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp --eula accept -s --ignore-errors 
    $out/tmp/intel-fortran-essentials-${version}_offline/install.sh --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp --eula accept -s --ignore-errors 
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
    description = "Intel C++ essentials + Fortran essentials";
    maintainers = [ lib.maintainers.tonywu20 ];
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}

