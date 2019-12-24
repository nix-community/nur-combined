{ stdenv, fetchurl, glibc, gcc }:

stdenv.mkDerivation rec {
  version = "2016";
  name = "intel-compilers-2016";
  sourceRoot = "/scratch/intel/2016";

  buildInputs = [ glibc gcc ];

  phases = [ "installPhase" "fixupPhase" "installCheckPhase" "distPhase" ];

  installPhase = ''
     cp -a $sourceRoot $out
     # Fixing man path
     rm -f $out/man
     mkdir -p $out/share
     ln -s ../compilers_and_libraries/linux/man/common $out/share/man
  '';

  postFixup = ''
    echo "Fixing rights..."
    chmod u+w -R $out
    echo "Patching rpath and interpreter..."
    find $out -type f -exec $SHELL -c 'patchelf --set-interpreter $(echo ${glibc}/lib/ld-linux*.so.2) --set-rpath ${glibc}/lib:${gcc.cc}/lib:${gcc.cc.lib}/lib:$out/lib/intel64:$out/compilers_and_libraries_2016.2.181/linux/bin/intel64 2>/dev/null {}' \;
    echo "Fixing path into scripts..."
    for file in `grep -l -r "$sourceRoot" $out`
    do
      sed -e "s,$sourceRoot,$out,g" -i $file
    done 
  '';

  meta = {
    description = "Intel compilers and libraries 2016";
    longDescription = ''
      This package contains:
          - Intel Parallel Studio XE 2016 composer edition for C++ and Fortran update2
          - Intel MKL 11.3.2.181
          - Intel MPI 5.1.3.181
    '';
    maintainers = [ stdenv.lib.maintainers.bzizou ];
    platforms = stdenv.lib.platforms.linux;
    license = stdenv.lib.licenses.unfree;
  };
}

