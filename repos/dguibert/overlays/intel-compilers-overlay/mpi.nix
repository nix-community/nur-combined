{ stdenv, fetchannex, glibc, gcc, file
, cpio, rpm
, patchelf
, makeWrapper
, preinstDir ? "opt/intel/compilers_and_libraries_${version}/linux/mpi"
, version ? "2019.1.144"
, url
, sha256
}:

let

  components_ = [
    "intel-mpi-rt-*"
    "intel-mpi-sdk-*"
  ];

  extract = pattern: ''
    ls $build
    ls $build/rpm
    ls $build/rpm/${pattern}
    for rpm in $(ls $build/rpm/${pattern}); do
      ${rpm}/bin/rpm2cpio $rpm | ${cpio}/bin/cpio -ivd
    done
  '';


self = stdenv.mkDerivation rec {
  inherit version;
  name = "intelmpi-${version}";
  src = fetchannex { inherit url sha256; };

  nativeBuildInputs= [ file patchelf makeWrapper ];

  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    set -xv
    export build=$PWD
    mkdir $out
    cd $out
    echo "${stdenv.lib.concatStringsSep "+" components_}"
    ${stdenv.lib.concatMapStringsSep "\n" extract components_}

    mv ${preinstDir}/* .
    rm -rf opt
    set +xv

    mkdir $out/Licenses
    #cp $licenseFile} $out/Licenses
    # Fixing man path
    rm -rf $out/benchmarks

    ln -s $out/intel64/bin $out/bin
    ln -s $out/intel64/etc $out/etc
    ln -s $out/intel64/include $out/include
    ln -s $out/intel64/lib $out/lib

  '';

  postFixup = ''
    echo "Patching rpath and interpreter..."
    for f in $(find $out -type f -executable); do
      type="$(file -b --mime-type $f)"
      case "$type" in
      "application/executable"|"application/x-executable")
        echo "Patching executable: $f"
        patchelf --set-interpreter $(echo ${glibc}/lib/ld-linux*.so.2) --set-rpath ${glibc}/lib:\$ORIGIN:\$ORIGIN/../lib $f || true
        ;;
      "application/x-sharedlib"|"application/x-pie-executable")
        echo "Patching library: $f"
        patchelf --set-rpath ${glibc}/lib:\$ORIGIN:\$ORIGIN/../lib:\$ORIGIN/../../libfabric/lib $f || true
        ;;
      *)
        echo "$f ($type) not patched"
        ;;
      esac
    done
     echo "Fixing path into scripts..."
    for file in `grep -l -r "/${preinstDir}" $out`; do
      sed -e "s,/${preinstDir},$out,g" -i $file
    done
    for file in `grep -l -r "I_MPI_SUBSTITUTE_INSTALLDIR" $out`; do
      sed -e "s,I_MPI_SUBSTITUTE_INSTALLDIR,$out,g" -i $file
    done

    wrapProgram $out/bin/mpiexec.hydra --set FI_PROVIDER_PATH $out/intel64/libfabric/lib/prov
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
