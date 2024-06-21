{ lib
  # , stdenv
, stdenvNoCC
, fetchurl
, validatePkgConfig
, rpmextract
  # , enableStatic ? stdenv.hostPlatform.isStatic
}:
let
  # Release notes and download URLs are here:
  # https://registrationcenter.intel.com/en/products/
  version = "${mpiVersion}.${rel}";

  # mpiVersion = "2021.13.0";
  # rel = "719";
  mpiVersion = "2021.12.1";
  rel = "5";

  # shlibExt = stdenvNoCC.hostPlatform.extensions.sharedLibrary;

  oneapi-mpi = fetchurl {
    url = "https://yum.repos.intel.com/oneapi/intel-oneapi-mpi-${mpiVersion}-${rel}.x86_64.rpm";
    hash = "";
  };

  oneapi-mpi-devel = fetchurl {
    url = "https://yum.repos.intel.com/oneapi/intel-oneapi-mpi-devel-${mpiVersion}-${rel}.x86_64.rpm";
    hash = "";
  };

  oneapi-runtime-mpi = fetchurl {
    url = "https://yum.repos.intel.com/oneapi/intel-oneapi-runtime-mpi-${mpiVersion}-${rel}.x86_64.rpm";
    hash = "";
  };
in
stdenvNoCC.mkDerivation ({
  pname = "mpi";
  inherit version;
  preferLocalBuild = true;

  dontUnpack = true;

  nativeBuildInputs = [ validatePkgConfig rpmextract ];

  buildPhase = ''
    rpmextract ${oneapi-mpi}
    rpmextract ${oneapi-mpi-devel}
    rpmextract ${oneapi-runtime-mpi}
  '';

  # TODO: installPhase

  # Per license agreement, do not modify the binary
  dontStrip = true;
  dontPatchELF = true;

  meta = with lib; {
    description = "Intel MPI Library";
    longDescription = ''
      Use this standards-based MPI implementation to deliver flexible,
      efficient, scalable cluster messaging on Intel architecture.
      This component is part of the Intel HPC Toolkit.
    '';
    homepage = "https://www.intel.com/content/www/us/en/developer/tools/oneapi/mpi-library.html";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.issl;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ kwaa ];
    broken = true; # WIP
  };
})
