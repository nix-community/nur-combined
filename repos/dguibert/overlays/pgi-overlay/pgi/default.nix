{ stdenv, requireFile
, nix-patchtools
, more
, zlib
, ncurses
, libxml2
, version
, sha256
, glibc
, file
, gcc
}:

let
  variant = if (stdenv.lib.versionAtLeast "2018-1812" version)  then "" else "-nollvm";
in
stdenv.mkDerivation {
  name = "pgilinux-${version}";
  src = requireFile {
    url = "https://www.pgroup.com/support/release_archive.php";
    name = "pgilinux-${version}-x86-64.tar.gz";
    inherit sha256;
  };
  dontPatchELF = true;
  dontStrip = true;

  buildInputs = [ nix-patchtools more file gcc ];
  libs = stdenv.lib.makeLibraryPath [
    stdenv.cc.cc.lib /* libstdc++.so.6 */
    #llvmPackages_7.llvm # libLLVM.7.so
    stdenv.cc.cc # libm
    stdenv.glibc
    zlib
    ncurses
    libxml2
    #"${placeholder "out"}/lib"
  ];
  installPhase = ''
    mkdir $out
    ## Set these environment variables for a silent install
    ## Valid silent install options:
    export PGI_SILENT=true
    export PGI_ACCEPT_EULA="accept"
    #PGI_INSTALL_DIR=/opt/pgi
    export PGI_INSTALL_DIR=$out
    ##  Installation of CUDA is the default and PGI_INSTALL_NVIDIA=true has no effect.
    ##  To skip CUDA installation, explicitly set to 'false':  PGI_INSTALL_NVIDIA=false
    ##  See documentation for how to use a different CUDA installation.
    #PGI_INSTALL_NVIDIA=true
    #PGI_INSTALL_JAVA=true
    #PGI_INSTALL_MPI=true
    #PGI_MPI_GPU_SUPPORT=true
    ##

    LINUXPART=$(cat .parts/linux86-64${variant})
    for i in $LINUXPART ; do
      tar cf - $i | ( cd $out; tar --no-same-owner -xf - )
    done

    for d in $(cd $out/linux86-64${variant}/*/; ls); do
      ln -s $out/linux86-64${variant}/*/$d $out/$d
    done
    cp common/license.dat $out

    # Hack around lack of libtinfo in NixOS
    ln -s ${ncurses.out}/lib/libncursesw.so.6 $out/lib/libtinfo.so.5
    ln -s ${ncurses.out}/lib/libncursesw.so.6 $out/lib/libncurses.so.5

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
    $out/bin/makelocalrc -x $out/linux*/* -d $out/bin
    echo "set DEFSTDOBJDIR=${glibc}/lib;" >> $out/bin/localrc

    # https://github.com/easybuilders/easybuild-easyblocks/issues/1493
    cat > $out/bin/siterc <<EOF
# replace unknown switch -pthread with -lpthread
switch -pthread is replace(-lpthread) positional(linker);
EOF
  '';
  passthru = {
    isClang = false;
    langFortran = true;
    hardeningUnsupportedFlags = [ "all" "stackprotector" ];
  };
}
