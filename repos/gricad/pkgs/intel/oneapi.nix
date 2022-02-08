{ lib, stdenv, fetchurl, glibc, gcc, glib, libnotify, xdg-utils, ncurses, fakeroot }:

stdenv.mkDerivation rec {
  version = "2022.1.2.146";
  hpc_version = "2022.1.2.117";
  name = "intel-oneapi-${version}";
  sourceRoot = "/data/scratch/intel/oneapi_installer";

  nativeBuildInputs = [ fakeroot ];
  propagatedBuildInputs = [ glibc gcc glib libnotify xdg-utils ncurses ];

  phases = [ "installPhase" "fixupPhase" "installCheckPhase" "distPhase" ];

  installPhase = ''
     cd $sourceRoot
     mkdir -p $out/tmp
     bash ./l_BaseKit_p_${version}_offline.sh --log $out/basekit_install_log --extract-only --extract-folder $out/tmp -a --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept
     bash ./l_HPCKit_p_${hpc_version}_offline.sh --log $out/hpckit_install_log --extract-only --extract-folder $out/tmp -a --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept
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
    find $out -type f -exec $SHELL -c 'patchelf --set-interpreter $(echo ${glibc}/lib/ld-linux*.so.2) --set-rpath ${glibc}/lib:${gcc.cc}/lib:${gcc.cc.lib}/lib 2>/dev/null {}' \;
  '';

  meta = {
    description = "Intel OneAPI Basekit + HPCKit";
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}

