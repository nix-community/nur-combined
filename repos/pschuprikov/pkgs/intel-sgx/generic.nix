{ version, hasMitigation, sha256, optlibsSha256, aeSha256
, binutilsSha256 ? null, patchOpenMP ? false }:
{ stdenv, lib, overrideCC, wrapCCWith, fetchFromGitHub, fetchurl
, autoPatchelfHook, buildEnv, binutils-unwrapped, wrapBintoolsWith, file
, coreutils, ocaml, autoconf, automake, which, python, libtool, openssl
, ocamlPackages, perl, cmake, bash, protobuf, curl, fakeroot
, intelSGXDCAPPrebuilt, debugMode ? false, enableMitigation ? false }:

assert !hasMitigation -> !enableMitigation;

let
  useIntelBinUtils = binutilsSha256 != null;

  intel-sgx-path = "https://download.01.org/intel-sgx/";

  server-url-path = "${intel-sgx-path}/sgx-linux/${version}/";

  bintools-unwrapped-intel = stdenv.mkDerivation rec {
    name = "intel-sgx-binutils-${version}";

    inherit version;

    src = fetchurl {
      url = "${server-url-path}/as.ld.objdump.gold.r2.tar.gz";
      sha256 = binutilsSha256;
    };

    installPhase = ''
      mkdir -p $out/bin
      cp toolset/nix/* $out/bin
    '';

    buildInputs = [ stdenv.cc.cc autoPatchelfHook ];
  };

  binutils-intel-unwrapped = buildEnv {
    name = "intel-sgx-binutils-merged";
    paths = [ bintools-unwrapped-intel binutils-unwrapped ];
  };

  binutils-intel = wrapBintoolsWith { bintools = binutils-intel-unwrapped; };

  intelStdenv = overrideCC stdenv (wrapCCWith {
    cc = stdenv.cc.cc;
    bintools = binutils-intel;
  });

  intel-optlibs-prebuilt = fetchurl {
    url = "${server-url-path}/optimized_libs_${version}.tar.gz";
    sha256 = optlibsSha256;
  };

  intel-ae-prebuilt = fetchurl {
    url = "${server-url-path}/prebuilt_ae_${version}.tar.gz";
    sha256 = aeSha256;
  };

  sgxStdenv = if useIntelBinUtils then intelStdenv else stdenv;

  createDerivation = component: sdk:
    let arch = if stdenv.isx86_64 then "x64" else if stdenv.isx86_32 then "x32" else null;
     in (sgxStdenv.mkDerivation {
      name = "linux-sgx-${component}-${version}";

      src = fetchFromGitHub {
        owner = "intel";
        repo = "linux-sgx";
        rev = "sgx_${version}";
        sha256 = sha256;
        fetchSubmodules = true;
      };
      hardeningDisable = lib.optionals debugMode ["fortify"];
      dontUseCmakeConfigure = true;
      patchPhase = ''
        tar -xzvf ${intel-optlibs-prebuilt}
        tar -xzvf ${intelSGXDCAPPrebuilt}
      '' + lib.optionalString patchOpenMP ''
        pushd external/openmp/openmp_code
        patch -p1 < ../*.patch
        popd
      '' + ''

        substituteInPlace buildenv.mk \
          --replace /bin/cp ${coreutils}/bin/cp

        patchShebangs linux/installer
      '';

      preInstall = ''
        ./linux/installer/common/${component}/createTarball.sh
        export DESTDIR=$out
      '';

      installFlags = ["-C" "./linux/installer/common/${component}/output" ];

      preBuild = ''
        buildFlagsArray+="-j''${NIX_BUILD_CORES}"
      '';

      buildFlags = [
        ("${component}"
          + lib.optionalString (component == "sdk" && hasMitigation && !enableMitigation)
          "_no_mitigation")
      ] ++ lib.optional debugMode "DEBUG=1";

      buildInputs = [
        cmake
        file
        ocaml
        openssl
        libtool
        which
        python
        ocamlPackages.ocamlbuild
        autoconf
        automake
        perl
      ];
    }).overrideAttrs (attrs: lib.optionalAttrs (component == "psw") {
      patchPhase = attrs.patchPhase + ''
        tar -xzvf ${intel-ae-prebuilt}
        substituteInPlace psw/ae/aesm_service/source/CMakeLists.txt \
          --replace /usr/bin/getconf getconf
        substituteInPlace linux/installer/common/psw/createTarball.sh \
          --replace 'ARCH=$(get_arch)' "ARCH=${arch}"
        substituteInPlace external/dcap_source/QuoteGeneration/buildenv.mk \
          --replace /bin/cp ${coreutils}/bin/cp
        substituteInPlace psw/ae/pve/helper.cpp \
          --replace '#include "helper.h"' "#pragma GCC diagnostic push
        #pragma GCC diagnostic ignored \"-Wshadow\"
        #include \"helper.h\"
        #pragma GCC diagnostic pop"
        substituteInPlace psw/ae/pve/Makefile \
          --replace EPID_LIBDIR EPID_SDK_DIR
      '';

      preBuild = ''
        export SGX_SDK=${sdk}/opt/intel/sgxsdk
      '';

      buildInputs = attrs.buildInputs ++ [
        protobuf curl fakeroot
      ];
    });
in rec {
  sdk = createDerivation "sdk" null;
  psw = createDerivation "psw" sdk;
  stdenv = intelStdenv;
}
