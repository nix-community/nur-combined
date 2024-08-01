{ stdenv
, stdenvNoCC
, fetchurl
, autoPatchelfHook
, dpkg
, level-zero
, libfabric
,
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
  version = "2021.12.1-5";

  mpi = fetchdeb {
    package = "intel-oneapi-mpi-${major}-${version}_amd64";
    hash = "sha256-SbPANSGlAu/9OcBiovp5TEJ9wp3fFHXXBL0gdshjZB0=";
  };
  mpi-devel = fetchdeb {
    package = "intel-oneapi-mpi-devel-${major}-${version}_amd64";
    hash = "sha256-Eil/lPfGz86WJIZ2hqOss3tHIUOp1nFavkYZb5MphZ8=";
  };
  mpi-runtime = fetchdeb {
    package = "intel-oneapi-runtime-mpi-2021-${version}_amd64";
    hash = "sha256-DT2vut8qW20kh88eWToFoEO1Z7gWAEU0crfyJitnuIM=";
  };
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "intel-mpi";

  # dontUnpack = true;
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook dpkg ];

  buildInputs = [
    stdenv.cc.cc.lib
    level-zero
    libfabric
  ];

  unpackPhase = ''
    dpkg-deb -x ${mpi} .
    dpkg-deb -x ${mpi-devel} .
    dpkg-deb -x ${mpi-runtime} .
  '';

  installPhase = ''
    mkdir -p $out
    mkdir -p $out/share

    cd ./opt/intel/oneapi/mpi/${major}

    mv bin $out/bin
    mv include $out/include
    mv lib $out/lib

    cd share

    mv doc $out/share/doc
    mv man $out/share/man
  '';
  meta = {
    broken = true;
  };

}
