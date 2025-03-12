{ stdenv, fetchurl, glibc, perl, python, xorg, zlib, gcc, fontconfig, freetype, glib, libselinux, libxml2, sqlite, expat, bzip2, libkrb5, gdbm, e2fsprogs }:

stdenv.mkDerivation rec {
  version = "5.1.1";
  name = "casa-${version}";

   src = fetchurl {
    url = "https://casa.nrao.edu/download/distro/linux/release/el7/casa-release-5.1.1-5.el7.tar.gz";
    sha256 = "0m30kcszrf356k5v5nivz6h9lalf1mqd5m25dkdwaa090j32034l";
  };

  nativeBuildInputs = [ glibc perl python xorg.libSM xorg.libICE xorg.libX11 xorg.libXext xorg.libXi xorg.libXrender xorg.libXrandr xorg.libXfixes xorg.libXcursor xorg.libXinerama xorg.libXft zlib gcc fontconfig glib freetype libselinux libxml2 sqlite expat xorg.libxcb bzip2 libkrb5 gdbm e2fsprogs ];

  phases = [ "unpackPhase" "installPhase" "fixupPhase" "installCheckPhase" "distPhase" ];

  # We do this manually in the custom postFixup phase
  dontStrip = true;
  dontPatchELF = true;
  dontPatchShebangs = true;

  installPhase = ''
     cd .. && cp -a $sourceRoot $out
  '';

  postFixup = ''
    echo "Fixing rights..."
    chmod u+w -R $out
    echo "Patching rpath and interpreter..."
    find $out -type f -exec $SHELL -c "patchelf --set-rpath ${glibc}/lib:$out/lib:${gcc.cc}/lib:${gcc.cc.lib}/lib:${zlib}/lib:${glib}/lib:${freetype}/lib:${xorg.libSM}/lib:${xorg.libICE}/lib:${xorg.libX11}/lib:${xorg.libXext}/lib:${xorg.libXi}/lib:${xorg.libXrender}/lib:${xorg.libXrandr}/lib:${xorg.libXfixes}/lib:${xorg.libXcursor}/lib:${xorg.libXinerama}/lib:${xorg.libxcb}/lib:${xorg.libXft}/lib:${fontconfig.lib}/lib:${libselinux.out}/lib:${libxml2.out}/lib:${sqlite.out}/lib:${expat}/lib:$out/etc/carta/lib:${bzip2.out}/lib:${libkrb5}/lib:${gdbm}/lib:${e2fsprogs.out}/lib '{}' 2>/dev/null" \;
    find $out -type f -exec $SHELL -c "patchelf --set-interpreter $(echo ${glibc}/lib/ld-linux*.so.2) '{}' 2>/dev/null" \;
    echo "Fixing path into scripts..."
    for file in `grep -l -r "$sourceRoot" $out`
    do
      sed -e "s,$sourceRoot,$out,g" -i $file
    done 
    echo "Patching shebangs..."
    patchShebangs $out
  '';

  meta = {
    description = "Casa binary distribution";
    maintainers = [ stdenv.lib.maintainers.bzizou ];
    platforms = stdenv.lib.platforms.linux;
  };
}

