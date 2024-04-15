{
  stdenv,
  lib,
  fetchannex,
  glibc,
  gcc,
  file,
  cpio,
  rpm,
  patchelf,
  makeWrapper,
  preinstDir ? "opt/intel/compilers_and_libraries_${version}/linux/mpi",
  version ? "2019.1.144",
  url,
  sha256,
  nix-patchtools,
  libpsm2,
  ucx,
  rdma-core,
  zlib,
  numactl,
}: let
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
    src = fetchannex {inherit url sha256;};

    nativeBuildInputs = [file nix-patchtools makeWrapper];

    dontPatchELF = true;
    dontStrip = true;

    installPhase = ''
      set -xv
      export build=$PWD
      mkdir $out
      cd $out
      echo "${lib.concatStringsSep "+" components_}"
      ${lib.concatMapStringsSep "\n" extract components_}

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

    libs =
      (lib.concatStringsSep ":" [
        "${placeholder "out"}/lib"
        "${placeholder "out"}/intel64/libfabric/lib"
      ])
      + ":"
      + (lib.makeLibraryPath [
        stdenv.cc.libc
        gcc.cc.lib
        ucx
        rdma-core
        zlib
        libpsm2
        numactl
      ]);

    postFixup = ''
      find $out -type d -name ia32_lin -print0 | xargs -0 -i rm -r {}
      find $out -type d -name ia32_qnx -print0 | xargs -0 -i rm -r {} # 2019 version
      test -e $out/intel64/lib/libtmip_mx.so && rm $out/intel64/lib/libtmip_mx.so* # intelmpi> No package found that provides library: libmyriexpress.so
      rm -f $out/intel64/bin/tune/_hashlib.so # > No package found that provides library: libssl.so.6



      # FIXME release_mt/debug or debug_mt
      ln -s $out/lib/release/* $out/lib || true

      echo "libs: $libs"
      autopatchelf "$out"

      wrapProgram $out/bin/mpiexec.hydra --set FI_PROVIDER_PATH $out/intel64/libfabric/lib/prov

    '';

    passthru = {
      isIntel = true;
    };

    meta = {
      description = "Intel MPI ${version} library";
      maintainers = [lib.maintainers.dguibert];
      platforms = lib.platforms.linux;
    };
  };
in
  self
