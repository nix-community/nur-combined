{ lib, stdenv, fetchurl, glibc, libX11, glib, libnotify, xdg-utils, ncurses, nss, 
  at-spi2-core, libxcb, libdrm, gtk3, mesa, qt515, zlib, xorg, atk, nspr, dbus,
  pango, cairo, gdk_pixbuf, cups, expat, libxkbcommon, alsaLib, file, at-spi2-atk,
  freetype, fontconfig, xml2 }:

stdenv.mkDerivation rec {
  version = "2024.0.1.46";
  hpc_version = "2024.0.1.38";
  version_dir="2024.0";
  name = "intel-oneapi-${version}";

  # For localy downloaded offline installers
  # sourceRoot = "/data/scratch/intel/oneapi_installer";
 
  # For installer fetching (no warranty of the links)
  sourceRoot = ".";
  srcs = [
    (fetchurl {
      url = "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/163da6e4-56eb-4948-aba3-debcec61c064/l_BaseKit_p_2024.0.1.46_offline.sh";
      sha256 = "1sp1fgjv8xj8qxf8nv4lr1x5cxz7xl5wv4ixmfmcg0gyk28cjq1g";
    })
    (fetchurl {
      url = "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/67c08c98-f311-4068-8b85-15d79c4f277a/l_HPCKit_p_2024.0.1.38_offline.sh";
      sha256 = "06vpdz51w2v4ncgk8k6y2srlfbbdqdmb4v4bdwb67zsg9lmf8fp9";
    })
  ];

  nativeBuildInputs = [ file ];
 
  propagatedBuildInputs = [ glibc glib libnotify xdg-utils ncurses nss 
                           at-spi2-core libxcb libdrm gtk3 mesa qt515.full 
                           zlib freetype fontconfig xorg.xorgproto xorg.libX11 xorg.libXt
                           xorg.libXft xorg.libXext xorg.libSM xorg.libICE ];

  libPath = lib.makeLibraryPath [ stdenv.cc.cc libX11 glib libnotify xdg-utils 
                                  ncurses nss at-spi2-core libxcb libdrm gtk3 
                                  mesa qt515.full zlib atk nspr dbus pango cairo 
                                  gdk_pixbuf cups expat libxkbcommon alsaLib
                                  at-spi2-atk xorg.libXcomposite xorg.libxshmfence 
                                  xorg.libXdamage xorg.libXext xorg.libXfixes
                                  xorg.libXrandr xml2 ];

  phases = [ "installPhase" "fixupPhase" "installCheckPhase" "distPhase" ];

  installPhase = ''
     cd $sourceRoot
     mkdir -p $out/tmp
     if [ "$srcs" = "" ]
     then
       base_kit="./l_BaseKit_p_${version}_offline.sh"
       hpc_kit="./l_HPCKit_p_${hpc_version}_offline.sh"
     else
       base_kit=`echo $srcs|cut -d" " -f1`
       hpc_kit=`echo $srcs|cut -d" " -f2`
     fi
     # Extract files
     bash $base_kit --log $out/basekit_install_log --extract-only --extract-folder $out/tmp -a --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept
     bash $hpc_kit --log $out/hpckit_install_log --extract-only --extract-folder $out/tmp -a --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept
     for file in `grep -l -r "/bin/sh" $out/tmp`
     do
       sed -e "s,/bin/sh,${stdenv.shell},g" -i $file
     done
     export HOME=$out
     # Patch the bootstraper binaries and libs
     for files in `find $out/tmp/l_BaseKit_p_${version}_offline/lib`
     do
       patchelf --set-rpath "${glibc}/lib:$libPath:$out/tmp/l_BaseKit_p_${version}_offline/lib" $file 2>/dev/null || true
     done
     patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${glibc}/lib:$libPath:$out/tmp/l_BaseKit_p_${version}_offline/lib" $out/tmp/l_BaseKit_p_${version}_offline/bootstrapper
     # launch install
     export LD_LIBRARY_PATH=${zlib}/lib
     $out/tmp/l_BaseKit_p_${version}_offline/install.sh --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp --eula accept -s --ignore-errors
     $out/tmp/l_HPCKit_p_${hpc_version}_offline/install.sh --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp --eula accept -s --ignore-errors
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
    patchelf --add-needed libstdc++.so.6 $clang_binary
  '';

  meta = {
    description = "Intel OneAPI Basekit + HPCKit";
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}

