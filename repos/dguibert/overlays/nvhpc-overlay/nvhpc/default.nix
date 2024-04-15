{
  stdenv,
  fetchurl,
  lib,
  nix-patchtools,
  more,
  zlib,
  ncurses,
  libxml2,
  glibc,
  file,
  gcc,
  flock,
  url,
  version,
  sha256,
}:
stdenv.mkDerivation {
  name = "nvhpc-${version}";
  src = fetchurl {
    inherit url sha256;
  };
  dontPatchELF = true;
  dontStrip = true;

  buildInputs = [
    nix-patchtools
    more
    file
    gcc
    flock
    /*
    for makelocalrc
    */
  ];
  libs = lib.makeLibraryPath [
    stdenv.cc.cc.lib
    /*
    libstdc++.so.6
    */
    #llvmPackages_7.llvm # libLLVM.7.so
    stdenv.cc.cc # libm
    stdenv.glibc
    zlib
    ncurses
    libxml2
    #"${placeholder "out"}/lib"
  ];
  installPhase = ''
    ## Set these environment variables for a silent install
    ## Valid silent install options:
    export NVHPC_SILENT=true
    export NVHPC_ACCEPT_EULA="accept"
    export NVHPC_INSTALL_DIR=$out
    export NVHPC_INSTALL_TYPE="single"

    mkdir prefix
    cd install_components
    LINUXPART=$(cat .parts/Linux_x86_64)
    for i in $LINUXPART ; do
      tar cf - $i | ( cd ../prefix/; tar --no-same-owner -xf - )
    done
    cd ..

    # TODO install each component:
    # comm_libs  compilers  cuda  examples  math_libs  profilers  REDIST
    mkdir -p $out/Linux_x86_64/${version}
    mv prefix/Linux_x86_64/${version}/compilers $out/Linux_x86_64/${version}/
    ln -s $out/Linux_x86_64/${version}/compilers/* $out/

    # Hack around lack of libtinfo in NixOS
    #ln -s ${ncurses.out}/lib/libncursesw.so.6 $out/lib/libtinfo.so.5
    #ln -s ${ncurses.out}/lib/libncursesw.so.6 $out/lib/libncurses.so.5

    #TODO keep $ORIGIN:$ORIGIN/../lib
    ## autopatchelf $out
    echo "Patching rpath and interpreter..."
    for f in $(find $out -type f -executable); do
      type="$(file -b --mime-type $f)"
      case "$type" in
      "application/executable"|"application/x-executable")
        echo "Patching executable: $f"
        patchelf --set-interpreter $(echo ${glibc}/lib/ld-linux*.so.2) --set-rpath $libs:\$ORIGIN:\$ORIGIN/../lib:$ORIGIN/../lib64 $f || true
        ;;
      "application/x-sharedlib"|"application/x-pie-executable")
        echo "Patching library: $f"
        patchelf --set-rpath $libs:\$ORIGIN:\$ORIGIN/../lib:$ORIGIN/../lib64 $f || true
        ;;
      *)
        echo "$f ($type) not patched"
        ;;
      esac
    done

    patchShebangs $out

    find $out -empty -delete || true
    #rm $out/*/*/lib/libnuma.so*
    # generate localrc
    sed -i -e "s/^target=.*/target=Linux_x86_64/" $out/bin/makelocalrc
    $out/bin/makelocalrc -x $out
    echo "set DEFSTDOBJDIR=${glibc}/lib;" >> $out/bin/localrc
    # set NOSWITCHERROR=1;’ # https://forums.developer.nvidia.com/t/pgcc-error-unknown-switch-wall/130833

    # https://github.com/easybuilders/easybuild-easyblocks/issues/1493
    # pgcc-Error-RC file /nix/store/dn3lqas9fr5y5qymw8ay0pj10rc9fwq5-nvhpc-21.5/bin/siterc line 2: switch -pthread already exists
    ${lib.optionalString (!lib.versionAtLeast version "21.7") ''
            cat > $out/bin/siterc <<EOF
      switch -idirafter arg is shorthand(-I \$arg);
      EOF
          # switch -pthread is replace(-lpthread) positional(linker);
    ''}
  '';
  passthru = {
    isClang = false;
    langFortran = true;
    hardeningUnsupportedFlags = ["fortify" "stackprotector" "pie" "pic" "strictoverflow" "format"];
  };
}
