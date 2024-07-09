{ stdenv
, stdenvNoCC
, fetchurl
, autoPatchelfHook
, dpkg
, hwloc
, ...
}:
let
  fetchdeb =
    { package
    , hash
    , ...
    }:
    fetchurl {
      inherit hash;
      url = "https://apt.repos.intel.com/oneapi/pool/main/${package}.deb";
    };
in

let
  major = "2021.12";
  version = "2021.12.0-495";

  tbb = fetchdeb {
    package = "intel-oneapi-tbb-${major}-${version}_amd64";
    hash = "sha256-1O+Lw2fWJM1EIsCR9/SGzMv2Kkv/GsE43AafP7szzsU=";
  };
  tbb-devel = fetchdeb {
    package = "intel-oneapi-tbb-devel-${major}-${version}_amd64";
    hash = "sha256-Jm0A6mUvTZZF952Gx+ESKGK/UL9fl9lQXts9Eop9+nY=";
  };
  tbb-runtime = fetchdeb {
    package = "intel-oneapi-runtime-tbb-2021-${version}_amd64";
    hash = "sha256-CJE704zhWwAb2Xd5GABge9JuY9yibrvmbxn9p9R1uvI=";
  };
  tbb-common = fetchdeb {
    package = "intel-oneapi-tbb-common-${major}-${version}_all";
    hash = "sha256-GvU91yogZH9QDMZZrMF+sCvAG746UO11oa6AjOzC71c=";
  };
  tbb-common-devel = fetchdeb {
    package = "intel-oneapi-tbb-common-devel-${major}-${version}_all";
    hash = "sha256-IRw9A3ZaeZfVWAj9J1iID1pGIGXKtaEVcD5MVDms3Rk=";
  };
  tbb-common-runtime = fetchdeb {
    package = "intel-oneapi-runtime-tbb-common-2021-${version}_all";
    hash = "sha256-DpSuaVb58kD20mNrAZ5QIOtdSUFBWo3e6T7FUtyA/oA=";
  };
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "intel-tbb";

  # dontUnpack = true;
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook dpkg ];

  buildInputs = [
    stdenv.cc.cc.lib
    hwloc
  ];

  autoPatchelfIgnoreMissingDeps = [ "libhwloc.so.5" ];

  unpackPhase = ''
    dpkg-deb -x ${tbb} .
    dpkg-deb -x ${tbb-devel} .
    dpkg-deb -x ${tbb-runtime} .
    dpkg-deb -x ${tbb-common} .
    dpkg-deb -x ${tbb-common-devel} .
    dpkg-deb -x ${tbb-common-runtime} .
  '';

  installPhase = ''
    mkdir -p $out

    cd ./opt/intel/oneapi/tbb/${major}

    mv include $out/include
    mv lib $out/lib
    mv lib32 $out/lib32
    mv share $out/share
  '';
}
