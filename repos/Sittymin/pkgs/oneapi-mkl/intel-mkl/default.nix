{ stdenv
, stdenvNoCC
, fetchurl
, autoPatchelfHook
, dpkg
, pkgs
, ocl-icd
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
  intel-dpcpp = pkgs.callPackage ./intel-dpcpp { };
  intel-mpi = pkgs.callPackage ./intel-mpi { };
in

let
  major = "2024.1";
  version = "2024.1.0-691";

  mkl = fetchdeb {
    package = "intel-oneapi-mkl-${major}-${version}_amd64";
    hash = "sha256-VQ+BJ4uMiSeNmCN2bt7FMFmzWGFuG88Z/PmN/ZRnaqg=";
  };
  mkl-devel = fetchdeb {
    package = "intel-oneapi-mkl-devel-${major}-${version}_amd64";
    hash = "sha256-l717OIu6hdfL8zvHLvaP5AXS9Qs2ZtC2WNKwcsqs7Ro=";
  };
  mkl-runtime = fetchdeb {
    package = "intel-oneapi-runtime-mkl-2024-${version}_amd64";
    hash = "sha256-pEVl7y/isx3exSouomGWwdTOFmodapRDWrjSAS7rNqE=";
  };
  mkl-core = fetchdeb {
    package = "intel-oneapi-mkl-core-${major}-${version}_amd64";
    hash = "sha256-LsQgfiTOtICfrR7Q7ZuXrXEC1KNFsIK5+6akXgS4sI8=";
  };
  mkl-core-common = fetchdeb {
    package = "intel-oneapi-mkl-core-common-${major}-${version}_all";
    hash = "sha256-iloGGo+awRJkrxQUtoDRZIcHrgDJyVUE2jfZez118HA=";
  };
  mkl-core-devel = fetchdeb {
    package = "intel-oneapi-mkl-core-devel-${major}-${version}_amd64";
    hash = "sha256-O+PA/At8+jhyeyyDTJKPjZBPje3VwYojdlxOiwTvmvw=";
  };
  mkl-core-devel-common = fetchdeb {
    package = "intel-oneapi-mkl-core-devel-common-${major}-${version}_all";
    hash = "sha256-KJWR3oic9KBPpTDYWyp/qXcUSm+d2mT3T4FCTtlSnaQ=";
  };
  mkl-cluster = fetchdeb {
    package = "intel-oneapi-mkl-cluster-${major}-${version}_amd64";
    hash = "sha256-XLq8+dBcmr+bRcgQmGSc6ibb4OG07xf2fBITHpKD/1M=";
  };
  mkl-cluster-devel = fetchdeb {
    package = "intel-oneapi-mkl-cluster-devel-${major}-${version}_amd64";
    hash = "sha256-btCGZVUqlHFl2sPuWLCblFpJSDQrA8q6Bu6NgwNLgTk=";
  };
  mkl-cluster-devel-common = fetchdeb {
    package = "intel-oneapi-mkl-cluster-devel-common-${major}-${version}_all";
    hash = "sha256-Bg20M9PDSFLL7TqU8GWaQtol8/8KwSpzkVB7FSOZAFg=";
  };
  mkl-sycl = fetchdeb {
    package = "intel-oneapi-mkl-sycl-${major}-${version}_amd64";
    hash = "sha256-P06z0OHXLe73qkU0bHfcuMC+Qa3FckTCW+eGivV82aM=";
  };
  mkl-sycl-devel = fetchdeb {
    package = "intel-oneapi-mkl-sycl-devel-${major}-${version}_amd64";
    hash = "sha256-F9JAUSElOfJZRUuBTd9RDVvey18DxTSZqQmb8R4z4aw=";
  };
  mkl-sycl-devel-common = fetchdeb {
    package = "intel-oneapi-mkl-sycl-devel-common-${major}-${version}_all";
    hash = "sha256-XEG+fPgAB1zvecV6kiUsmyr4vKFEtYm/EPpoGA3tFUI=";
  };
  mkl-sycl-include = fetchdeb {
    package = "intel-oneapi-mkl-sycl-include-${major}-${version}_amd64";
    hash = "sha256-G5R6En5/BQuiQDcM9MRQmTqkKtUzr/egEn5RZ9v+/so=";
  };
  mkl-sycl-blas = fetchdeb {
    package = "intel-oneapi-mkl-sycl-blas-${major}-${version}_amd64";
    hash = "sha256-bNq0L2sdvpp6kQg17EQrWfzKptPBIuQYffy83N+jqoU=";
  };
  mkl-sycl-lapack = fetchdeb {
    package = "intel-oneapi-mkl-sycl-lapack-${major}-${version}_amd64";
    hash = "sha256-Hxr5ebGUaO8e05DrOYQRfzxGqWcR8teFGm50kOzI68E=";
  };
  mkl-sycl-dft = fetchdeb {
    package = "intel-oneapi-mkl-sycl-dft-${major}-${version}_amd64";
    hash = "sha256-XxsQuqI5m8SupHkFAS+cvK8B7mMR197HSByry/0UWP8=";
  };
  mkl-sycl-sparse = fetchdeb {
    package = "intel-oneapi-mkl-sycl-sparse-${major}-${version}_amd64";
    hash = "sha256-fXu50CJHsfweo4yYx/nCjw6cBrkrSR6kvlGcSX5Jctc=";
  };
  mkl-sycl-vm = fetchdeb {
    package = "intel-oneapi-mkl-sycl-vm-${major}-${version}_amd64";
    hash = "sha256-H4Pl8zKQUilAZv3uBLB+rFNfPb8kiAPdgBmbPObqh3Q=";
  };
  mkl-sycl-rng = fetchdeb {
    package = "intel-oneapi-mkl-sycl-rng-${major}-${version}_amd64";
    hash = "sha256-Ja46ToENQvg1ZRTH0XtYQcAHsFZghp8S1WGTluhGeBA=";
  };
  mkl-sycl-stats = fetchdeb {
    package = "intel-oneapi-mkl-sycl-stats-${major}-${version}_amd64";
    hash = "sha256-ddZpE+iE9bZ+5fuYAsJbpQDaPL6tzg8aZgGTRwHH6qw=";
  };
  mkl-sycl-data-fitting = fetchdeb {
    package = "intel-oneapi-mkl-sycl-data-fitting-${major}-${version}_amd64";
    hash = "sha256-xdsxdhZ43gRh5VSNF8NeEQLY/avvfNBs4ws0xlbjKLI=";
  };
  mkl-classic = fetchdeb {
    package = "intel-oneapi-mkl-classic-${major}-${version}_amd64";
    hash = "sha256-9BbM2iSoSJgZhEIAsg9XRF4k+oK4wkcXoNhlF3qylR0=";
  };
  mkl-classic-devel = fetchdeb {
    package = "intel-oneapi-mkl-classic-devel-${major}-${version}_amd64";
    hash = "sha256-rb3W40lJmH/lVJfvCVlFCkBgbCushnsmHgI1tSN24Ag=";
  };
  mkl-classic-include = fetchdeb {
    package = "intel-oneapi-mkl-classic-include-${major}-${version}_amd64";
    hash = "sha256-StJASIlO2rMzuJ38unQedg932S/n3myEtLGzuOeXGiQ=";
  };
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "intel-mkl";

  dontStrip = true;
  # dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook dpkg ];

  buildInputs = [
    intel-dpcpp
    intel-mpi
    stdenv.cc.cc.lib
    ocl-icd
  ];

  unpackPhase = ''
    dpkg-deb -x ${mkl} .
    dpkg-deb -x ${mkl-devel} .
    dpkg-deb -x ${mkl-runtime} .
    dpkg-deb -x ${mkl-core} .
    dpkg-deb -x ${mkl-core-common} .
    dpkg-deb -x ${mkl-core-devel} .
    dpkg-deb -x ${mkl-core-devel-common} .
    dpkg-deb -x ${mkl-cluster} .
    dpkg-deb -x ${mkl-cluster-devel} .
    dpkg-deb -x ${mkl-cluster-devel-common} .
    dpkg-deb -x ${mkl-sycl} .
    dpkg-deb -x ${mkl-sycl-devel} .
    dpkg-deb -x ${mkl-sycl-devel-common} .
    dpkg-deb -x ${mkl-sycl-include} .
    dpkg-deb -x ${mkl-sycl-blas} .
    dpkg-deb -x ${mkl-sycl-lapack} .
    dpkg-deb -x ${mkl-sycl-dft} .
    dpkg-deb -x ${mkl-sycl-sparse} .
    dpkg-deb -x ${mkl-sycl-vm} .
    dpkg-deb -x ${mkl-sycl-rng} .
    dpkg-deb -x ${mkl-sycl-stats} .
    dpkg-deb -x ${mkl-sycl-data-fitting} .
    dpkg-deb -x ${mkl-classic} .
    dpkg-deb -x ${mkl-classic-devel} .
    dpkg-deb -x ${mkl-classic-include} .
  '';

  installPhase = ''
    mkdir -p $out
    mkdir -p $out/share

    cd ./opt/intel/oneapi/mkl/${major}

    mv bin $out/bin
    mv env $out/env
    mv etc/mkl $out/env/mkl
    mv include $out/include
    mv lib $out/lib
    # mv lib32 $out/lib32

    ln -s $out/lib/libmkl_rt.so $out/lib/libblas.so
    ln -s $out/lib/libmkl_rt.so $out/lib/libcblas.so
    ln -s $out/lib/libmkl_rt.so $out/lib/liblapack.so
    ln -s $out/lib/libmkl_rt.so $out/lib/liblapacke.so
    ln -s $out/lib/libmkl_rt.so $out/lib/libblas.so.3
    ln -s $out/lib/libmkl_rt.so $out/lib/libcblas.so.3
    ln -s $out/lib/libmkl_rt.so $out/lib/liblapack.so.3
    ln -s $out/lib/libmkl_rt.so $out/lib/liblapacke.so.3

    ln -s $out/lib/libmkl_intel_ilp64.so.2 $out/lib/libblas64.so.3
    ln -s $out/lib/libmkl_intel_ilp64.so.2 $out/lib/libcblas64.so.3
    ln -s $out/lib/libmkl_intel_ilp64.so.2 $out/lib/liblapack64.so.3
    ln -s $out/lib/libmkl_intel_ilp64.so.2 $out/lib/liblapacke64.so.3
    ln -s $out/lib/liblapack.so.3 $out/lib/libblas64.so
    ln -s $out/lib/libcblas64.so.3 $out/lib/libcblas64.so
    ln -s $out/lib/liblapack64.so.3 $out/lib/liblapack64.so
    ln -s $out/lib/liblapacke64.so.3 $out/lib/liblapacke64.so
    rm $out/lib/intel64

    cd share

    mv doc $out/share/doc
    mv locale $out/share/locale
  '';
}
