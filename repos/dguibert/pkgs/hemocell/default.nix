{
  stdenv,
  lib,
  fetchurl,
  palabos,
  parmetis ? null,
  hdf5,
  mpi ? hdf5.mpi,
  cmake,
  testCase ? "pipeflow",
  pkg-config,
  # [  9%] Performing update_custom step for 'hemocell'
  #  /tmp/nix-build-hemocell-pipeflow-1.4.drv-0/hemocell-1.4/scripts/safe_libhemocell_compilation.sh
  #  /tmp/nix-build-hemocell-pipeflow-1.4.drv-0/hemocell-1.4/scripts/safe_libhemocell_compilation.sh: line 9: flock: command not found
  flock,
  # /tmp/nix-build-hemocell-pipeflow-1.4.drv-0/hemocell-1.4/scripts/safe_libhemocell_compilation.sh: line 14: ps: command not found
  procps,
  gcc-unwrapped,
}:
stdenv.mkDerivation {
  name = "hemocell-${testCase}-1.4";

  src = fetchurl {
    url = "https://www.hemocell.eu/user_guide/_downloads/hemocell-1.4.tgz";
    sha256 = "04y68n3lxg1x4301j3h57hsr7hkv22vimn0rp49pq1bjjq8062v4";
  };

  preConfigure = ''
    ( tar xf ${palabos.src}; ln -s palabos-* palabos)
    ( cd patch && ./patchPLB.sh )

    ${lib.optionalString (parmetis != null) "cd external && tar -xzf ${parmetis.src}"}

    ( cd build/hemocell
      sed -i -e "s@cmake ./@cmake $cmakeFlags .@" ../../scripts/safe_libhemocell_compilation.sh
      cmake $cmakeFlags ./)
    sed -i -e "s@reset .*@@" scripts/safe_libhemocell_compilation.sh
    cd cases/${testCase}
  '';

  cmakeFlags = [
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
    "-DCMAKE_C_COMPILER=mpicc"
    "-DCMAKE_CXX_COMPILER=mpic++"
  ];

  preInstall = ''
    pwd
    ls -R
  '';

  buildInputs = [cmake hdf5 mpi pkg-config flock procps];
}
