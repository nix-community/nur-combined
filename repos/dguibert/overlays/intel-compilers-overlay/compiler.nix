{
  stdenv,
  lib,
  fetchannex,
  gcc,
  file,
  cpio,
  rpm,
  patchelf,
  version ? "2019.0.117",
  url,
  sha256,
  preinstDir ? "opt/intel/compilers_and_libraries_${version}/linux",
  nix-patchtools,
  mpi,
  makeWrapper,
}: let
  components_ =
    [
      "intel-comp*"
      "intel-openmp*"
      "intel-icc*"
      "intel-ifort*"
    ]
    ++ lib.optionals (lib.versionOlder "2017.99.999" version) ["intel-c-comp*"];

  extract = pattern: ''
    for rpm in $(ls $build/rpm/${pattern}.rpm | grep -v 32bit); do
      echo "Extracting: $rpm"
      ${rpm}/bin/rpm2cpio $rpm | ${cpio}/bin/cpio -ivd
    done
  '';

  self = stdenv.mkDerivation rec {
    inherit version;
    name = "intel-compilers-${version}";

    src = fetchannex {inherit url sha256;};

    nativeBuildInputs = [file patchelf nix-patchtools makeWrapper];

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
    '';

    libs =
      (lib.concatStringsSep ":" [
        "${placeholder "out"}/compiler/lib/intel64_lin"
      ])
      + ":"
      + (lib.makeLibraryPath [
        stdenv.cc.libc
        gcc.cc.lib
        mpi
      ]);

    preFixup = ''
      # Fixing man path
      rm -f $out/documentation
      rm -f $out/man
      # version 2019
      rm -f $out/compiler/lib/intel64_lin/offload_main
      rm -f $out/compiler/lib/intel64_lin/libioffload_target.so.5 #> No package found that provides library: libcoi_device.so.0



      autopatchelf "$out"

      echo "Fixing path into scripts..."
      for file in `grep -l -r "/${preinstDir}/" $out`
      do
        sed -e "s,/${preinstDir}/,$out,g" -i $file
      done

      ln -s $out/bin/intel64/* $out/bin/
      ln -s $out/compiler/lib/intel64_lin $out/lib

      for comp in icc icpc ifort xild xiar; do
        wrapProgram $out/bin/$comp --prefix PATH : "${gcc}/bin:${gcc.cc}/bin"
      done

    '';

    enableParallelBuilding = true;

    passthru =
      {
        lib = self; # compatibility with gcc, so that `stdenv.cc.cc.lib` works on both
        isIntel = true;
        hardeningUnsupportedFlags = ["stackprotector"];
        langFortran = true;
      }
      // lib.optionalAttrs stdenv.isLinux {
        inherit gcc;
      };

    meta = {
      description = "Intel compilers and libraries ${version}";
      maintainers = [lib.maintainers.guibert];
      platforms = lib.platforms.linux;
    };
  };
in
  self
