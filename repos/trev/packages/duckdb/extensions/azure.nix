{
  lib,
  stdenv,
  callPackage,
  cmake,
  curl,
  fetchFromGitHub,
  libxml2,
  openssl,
}:

let
  mkAzureSdkPackage =
    {
      pname,
      version,
      tag,
      hash,
      sourceRoot,
      buildInputs ? [ ],
      propagatedBuildInputs ? [ ],
      cmakeFlags ? [ ],
    }:
    stdenv.mkDerivation {
      inherit
        pname
        version
        sourceRoot
        buildInputs
        propagatedBuildInputs
        ;

      src = fetchFromGitHub {
        owner = "Azure";
        repo = "azure-sdk-for-cpp";
        rev = tag;
        inherit hash;
      };

      nativeBuildInputs = [ cmake ];

      cmakeFlags = [
        (lib.cmakeBool "BUILD_TESTING" false)
        (lib.cmakeBool "BUILD_SAMPLES" false)
        (lib.cmakeBool "BUILD_PERFORMANCE_TESTS" false)
        (lib.cmakeBool "CMAKE_POSITION_INDEPENDENT_CODE" true)
        (lib.cmakeBool "WARNINGS_AS_ERRORS" false)
      ]
      ++ cmakeFlags;

      env.AZURE_SDK_DISABLE_AUTO_VCPKG = "1";

      meta = {
        description = "Azure SDK for C++ component ${pname}";
        homepage = "https://github.com/Azure/azure-sdk-for-cpp";
        license = lib.licenses.mit;
        platforms = lib.platforms.unix;
      };
    };

  azure-core-cpp = mkAzureSdkPackage {
    pname = "azure-core-cpp";
    version = "1.16.1";
    tag = "azure-core_1.16.1";
    hash = "sha256-gMINz3bH80l0QYX3iKJlL962WIMujR1wuN+t4t7g7qg=";
    sourceRoot = "source/sdk/core/azure-core";
    buildInputs = [
      curl.dev
      curl.out
      openssl.dev
      openssl.out
    ];
    propagatedBuildInputs = [
      curl.dev
      curl.out
      openssl.dev
      openssl.out
    ];
    cmakeFlags = [
      (lib.cmakeBool "BUILD_TRANSPORT_CURL" true)
    ];
  };

  azure-identity-cpp = mkAzureSdkPackage {
    pname = "azure-identity-cpp";
    version = "1.13.2";
    tag = "azure-identity_1.13.2";
    hash = "sha256-864fU7BkVWXE0vVEYniXQUbrNRvLhhv6aR3wwdnjbQo=";
    sourceRoot = "source/sdk/identity/azure-identity";
    buildInputs = [
      azure-core-cpp
      openssl.dev
      openssl.out
    ];
    propagatedBuildInputs = [
      azure-core-cpp
      openssl.dev
      openssl.out
    ];
  };

  azure-storage-common-cpp = mkAzureSdkPackage {
    pname = "azure-storage-common-cpp";
    version = "12.11.0";
    tag = "azure-storage-common_12.11.0";
    hash = "sha256-u+zaMoX64GcTKE7QIF5WyENTogLBMTCenoI8hPY7m08=";
    sourceRoot = "source/sdk/storage/azure-storage-common";
    buildInputs = [
      azure-core-cpp
      libxml2.dev
      libxml2.out
      openssl.dev
      openssl.out
    ];
    propagatedBuildInputs = [
      azure-core-cpp
      libxml2.dev
      libxml2.out
      openssl.dev
      openssl.out
    ];
  };

  azure-storage-blobs-cpp = mkAzureSdkPackage {
    pname = "azure-storage-blobs-cpp";
    version = "12.15.0";
    tag = "azure-storage-blobs_12.15.0";
    hash = "sha256-u+zaMoX64GcTKE7QIF5WyENTogLBMTCenoI8hPY7m08=";
    sourceRoot = "source/sdk/storage/azure-storage-blobs";
    buildInputs = [ azure-storage-common-cpp ];
    propagatedBuildInputs = [ azure-storage-common-cpp ];
  };

  azure-storage-files-datalake-cpp = mkAzureSdkPackage {
    pname = "azure-storage-files-datalake-cpp";
    version = "12.13.0";
    tag = "azure-storage-files-datalake_12.13.0";
    hash = "sha256-u+zaMoX64GcTKE7QIF5WyENTogLBMTCenoI8hPY7m08=";
    sourceRoot = "source/sdk/storage/azure-storage-files-datalake";
    buildInputs = [ azure-storage-blobs-cpp ];
    propagatedBuildInputs = [ azure-storage-blobs-cpp ];
  };
in

(callPackage ./generic.nix { }) {
  name = "azure";
  repo = "duckdb-azure";
  branch = "v1.5-variegata";
  rev = "003214c96d0caa39d5c3e27a9e1976a0692c7d37";
  hash = "sha256-+d0jF+kzxhcIf6HWgn1FRotPalH2ZYnb1rdXpsJmhAc=";
  duckdbBuildInputs = [
    azure-identity-cpp
    azure-storage-blobs-cpp
    azure-storage-files-datalake-cpp
  ];
}
