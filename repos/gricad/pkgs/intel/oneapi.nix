{ lib, stdenv, fetchurl, glibc, libX11, glib, libnotify, xdg-utils, ncurses, nss, at-spi2-core, libxcb, libdrm, gtk3, mesa, qt515, zlib }:

stdenv.mkDerivation rec {
  version = "2022.1.2.146";
  hpc_version = "2022.1.2.117";
  name = "intel-oneapi-${version}";

  # For localy downloaded offline installers
  # sourceRoot = "/data/scratch/intel/oneapi_installer";
 
  # For installer fetching (no warranty of the links)
  sourceRoot = ".";
  srcs = [
    (fetchurl {
      url = "https://registrationcenter-download.intel.com/akdlm/irc_nas/18487/l_BaseKit_p_2022.1.2.146_offline.sh";
      sha256 = "13invmm854j4h9461v1sr1h6a1r90iq5ah753625xqmxd9siy3yp";
    })
    (fetchurl {
      url = "https://registrationcenter-download.intel.com/akdlm/irc_nas/18479/l_HPCKit_p_2022.1.2.117_offline.sh";
      sha256 = "0yx1llddwbdrj6p6kjx325vcmvci005yac3zdp72a8pw6k56ssz3";
    })
  ];

  propagatedBuildInputs = [ glibc glib libnotify xdg-utils ncurses nss at-spi2-core libxcb libdrm gtk3 mesa qt515.full zlib ];

  libPath = lib.makeLibraryPath [ stdenv.cc.cc libX11 glib libnotify xdg-utils ncurses nss at-spi2-core libxcb libdrm gtk3 mesa qt515.full zlib ];

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
     $out/tmp/l_BaseKit_p_${version}_offline/install.sh --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept --ignore-errors
     $out/tmp/l_HPCKit_p_${hpc_version}_offline/install.sh --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept --ignore-errors
     rm -rf $out/tmp
  '';

  postFixup = ''
    echo "Fixing rights..."
    chmod u+w -R $out
    echo "Patching rpath and interpreter..."
    for dir in `find $out -mindepth 1 -maxdepth 1 -type d`
    do
      find $dir -type f -exec $SHELL -c "patchelf --set-interpreter \"$(cat $NIX_CC/nix-support/dynamic-linker)\" --set-rpath ${glibc}/lib:$libPath:$dir/latest/lib64 2>/dev/null {}" \;
    done
  '';

  meta = {
    description = "Intel OneAPI Basekit + HPCKit";
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}

