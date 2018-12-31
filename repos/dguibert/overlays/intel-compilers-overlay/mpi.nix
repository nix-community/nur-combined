{ stdenv, fetchurl, glibc, gcc
, preinstDirMPI ? "scratch/intel/mpi"
, version ? "2017"
}:

let
preinstDir_ = "/${preinstDirMPI}";
self = stdenv.mkDerivation rec {
  inherit version;
  name = "intelmpi-${version}";
  sourceRoot = 
    if builtins.pathExists preinstDir_ then
      preinstDir_
    else
      abort ''

        ******************************************************************************************
        Specified preinstDir (${preinstDir_}) directory not found.
        To build this package, you have to first get and install locally the Intel Parallel Studio
        distribution with the official installation script provided by Intel.
        Then, set-up preinstDir to point to the directory of the local installation.
        ******************************************************************************************
      '';

  dontPatchELF = true;
  dontStrip = true;
  phases = [ "installPhase" "fixupPhase" "installCheckPhase" "distPhase" ];
  installPhase = ''
     cp -a $sourceRoot $out
     # Fixing man path
     rm -rf $out/benchmarks

     ln -s $out/intel64/bin $out/bin
     ln -s $out/intel64/etc $out/etc
     ln -s $out/intel64/include $out/include
     ln -s $out/intel64/lib $out/lib
  '';

  postFixup = ''
    echo "Fixing rights..."
    chmod u+w -R $out
    echo "Patching rpath and interpreter..."
    find $out -type f -executable -exec $SHELL -c 'patchelf --set-interpreter $(echo ${glibc}/lib/ld-linux*.so.2) --set-rpath ${glibc}/lib:${gcc.cc}/lib:${gcc.cc.lib}/lib:\$ORIGIN:\$ORIGIN/../lib 2>/dev/null {}' \;
    echo "Fixing path into scripts..."
    for file in `grep -l -r "$sourceRoot" $out`
    do
      sed -e "s,$sourceRoot,$out,g" -i $file
    done
  '';

  passthru = {
    isIntel = true;
  };

  meta = {
    description = "Intel MPI ${version} library";
    maintainers = [ stdenv.lib.maintainers.dguibert ];
    platforms = stdenv.lib.platforms.linux;
  };
};
in self
