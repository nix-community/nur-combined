{
  stdenv,
  lib,
  fetchannex,
  glibc,
  file,
  patchelf,
  version ? "2019.0.117",
  url,
  sha256,
  preinstDir ? "compilers_and_libraries_${version}/linux",
  gcc,
  nix-patchtools,
  libpsm2,
  rdma-core,
  mpi,
}:
stdenv.mkDerivation rec {
  inherit version;
  name = "intel-compilers-redist-${version}";

  src = fetchannex {inherit url sha256;};
  nativeBuildInputs = [file nix-patchtools];

  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    set -xv
    mkdir $out
    mv compilers_and_libraries_${version}/linux/* $out
    ln -s $out/compiler/lib/intel64_lin $out/lib
    set +xv
  '';

  libs =
    (lib.concatStringsSep ":" [
      "${placeholder "out"}/lib"
      "${placeholder "out"}/mpi/intel64/lib"
      "${placeholder "out"}/mpi/intel64/lib/release_mt"
      "${placeholder "out"}/mpi/intel64/libfabric/lib"
    ])
    + ":"
    + (lib.makeLibraryPath [
      stdenv.cc.libc
      gcc.cc.lib
      libpsm2
      rdma-core
      mpi
    ]);

  preFixup = ''
    find $out -type d -name ia32_lin -print0 | xargs -0 -i rm -r {}
    find $out -type d -name ia32_qnx -print0 | xargs -0 -i rm -r {} # 2019 version
    find $out -type d -name intel64_lin_x32 -print0 | xargs -0 -i rm -r {} # 2019 version
    find $out -type d -name ia32_and -print0 | xargs -0 -i rm -r {} # 2019 version
    find $out -type d -name intel64_and -print0 | xargs -0 -i rm -r {} # 2019 version
    rm -f $out/compiler/lib/intel64_lin/offload_main
    rm -f $out/compiler/lib/intel64_lin/libioffload_target.so.5 #> No package found that provides library: libcoi_device.so.0

    autopatchelf "$out"

    echo "Fixing path into scripts..."
    for file in `grep -l -r "${preinstDir}/" $out`
    do
      sed -e "s,${preinstDir}/,$out,g" -i $file
    done
  '';

  meta = {
    description = "Intel compilers and libraries ${version}";
    maintainers = [lib.maintainers.dguibert];
    platforms = lib.platforms.linux;
  };
}
