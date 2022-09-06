{ lib, stdenv, fetchurl, glibc, libX11, glib, libnotify, xdg-utils, ncurses, nss, 
  at-spi2-core, libxcb, libdrm, gtk3, mesa, qt515, zlib, xorg }:

stdenv.mkDerivation rec {
  version = "2022.2.0.262";
  hpc_version = "2022.2.0.191";
  name = "intel-oneapi-${version}";

  # For localy downloaded offline installers
  # sourceRoot = "/data/scratch/intel/oneapi_installer";
 
  # For installer fetching (no warranty of the links)
  sourceRoot = ".";
  srcs = [
    (fetchurl {
      url = "https://registrationcenter-download.intel.com/akdlm/irc_nas/18673/l_BaseKit_p_2022.2.0.262_offline.sh";
      sha256 = "03qx6sb58mkhc7iyc8va4y1ihj6l3155dxwmqj8dfw7j2ma7r5f6";
    })
    (fetchurl {
      url = "https://registrationcenter-download.intel.com/akdlm/irc_nas/18679/l_HPCKit_p_2022.2.0.191_offline.sh";
      sha256 = "0swz4w9bn58wwqjkqhjqnkcs8k8ms9nn9s8k7j5w6rzvsa6817d2";
    })
  ];

  propagatedBuildInputs = [ glibc glib libnotify xdg-utils ncurses nss at-spi2-core libxcb libdrm gtk3 mesa qt515.full zlib xorg.xlibsWrapper ];

  libPath = lib.makeLibraryPath [ stdenv.cc.cc libX11 glib libnotify xdg-utils ncurses nss at-spi2-core libxcb libdrm gtk3 mesa qt515.full zlib xorg.xlibsWrapper ];

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
     bash $base_kit --log $out/basekit_install_log --extract-only --extract-folder $out/tmp -a --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept
     bash $hpc_kit --log $out/hpckit_install_log --extract-only --extract-folder $out/tmp -a --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept
     for file in `grep -l -r "/bin/sh" $out/tmp`
     do
       sed -e "s,/bin/sh,${stdenv.shell},g" -i $file
     done
     export HOME=$out
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
      for file in `find $dir -type f`
      do
        echo "       $file"
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath '$ORIGIN'":${glibc}/lib:$libPath:$dir/latest/lib64" $file 2>/dev/null || true
      done
    done
  '';

  meta = {
    description = "Intel OneAPI Basekit + HPCKit";
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}

