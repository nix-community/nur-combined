{ lib
, stdenvNoCC
, fetchurl
, validatePkgConfig
, rpmextract
}:
let
  version = "${basekitVersion}.${rel}";

  shortVersion = "2024.2";
  basekitVersion = "2024.2.0";
  rel = "633";

  intel-basekit = fetchurl {
    url = "https://yum.repos.intel.com/oneapi/intel-basekit-${basekitVersion}-${rel}.x86_64.rpm";
    hash = "";
  };

  intel-basekit-env = fetchurl {
    url = "https://yum.repos.intel.com/oneapi/intel-basekit-env-${shortVersion}-${basekitVersion}-${rel}.noarch.rpm";
    hash = "";
  };

  intel-basekit-runtime = fetchurl {
    url = "https://yum.repos.intel.com/oneapi/intel-basekit-${basekitVersion}-${rel}.x86_64.rpm";
    hash = "";
  };

in
stdenvNoCC.mkDerivation ({
  pname = "basekit";
  inherit version;
  preferLocalBuild = true;

  dontUnpack = true;

  nativeBuildInputs = [ validatePkgConfig rpmextract ];

  buildPhase = ''
    rpmextract ${intel-basekit}
    rpmextract ${intel-basekit-env}
    rpmextract ${intel-basekit-runtime}
  '';

  # TODO: installPhase

  # Per license agreement, do not modify the binary
  dontStrip = true;
  dontPatchELF = true;

  meta = with lib; {
    description = "Intel oneAPI Base Toolkit";
    longDescription = ''
      Develop accelerated C++ and SYCL applications for CPUs, and GPUs.
      Toolkit includes compilers, pre-optimized libraries,
      and analysis tools for optimizing workloads including AI, HPC, and media.
    '';
    homepage = "https://software.intel.com/content/www/us/en/develop/tools/oneapi.html";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.issl;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ kwaa ];
    broken = true; # WIP
  };
})
