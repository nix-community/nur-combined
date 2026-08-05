{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  git,
  pkg-config,
  python3,
  tpm2-tss,
  protobuf,
  mbedtls,
}:
let
  trustedFirmwareA = fetchFromGitHub {
    owner = "ARM-software";
    repo = "arm-trusted-firmware";
    tag = "v2.7.0";
    hash = "sha256-WDJMMIWZHNqxxAKeHiZDxtPjfsfQAWsbYv+0o0PiJQs=";
  };
  nanopb = fetchFromGitHub {
    owner = "nanopb";
    repo = "nanopb";
    tag = "nanopb-0.4.2";
    hash = "sha256-60+HybIg6zVXpQJiLxmLlUatjxYqHe98aoV9buqCR6s=";
  };
  qcbor = fetchFromGitHub {
    owner = "laurencelundblade";
    repo = "QCBOR";
    tag = "v1.0";
    hash = "sha256-AscS8CCk5RjGUwLzvKoROBbjER45ipGM10HZYS+MkTY=";
  };
  t_cose = fetchFromGitHub {
    owner = "laurencelundblade";
    repo = "t_cose";
    rev = "fc3a4b2c7196ff582e8242de8bd4a1bc4eec577f";
    hash = "sha256-GwxeEUZYNDjqw7JDyYIQq70rqrdsauTLO8oIkIaSEn8=";
  };
  pythonEnv = python3.withPackages (pythonPackages: [
    pythonPackages.protobuf
  ]);
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "parsec";
  version = "1.5.0";
  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "parallaxsecond";
    repo = "parsec";
    tag = finalAttrs.version;
    fetchSubmodules = true;
    hash = "sha256-BWL2JMVv9+zI01g2pctHsSt5aV8a+V0gHWFQ0QZKZ2U=";
  };

  cargoHash = "sha256-zxp1r23otuw4fv5KSbVBJiPPLdhKa1fdgUCTruU+j2w=";

  env = {
    CMAKE_POLICY_VERSION_MINIMUM = "3.5";
    PROTOC = "${protobuf}/bin/protoc";
    TS_TFA_PATH = trustedFirmwareA;
    CXXFLAGS = "-std=c++17";
  };

  nativeBuildInputs = [
    cmake
    git
    pkg-config
    protobuf
    pythonEnv
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    tpm2-tss
    mbedtls
  ];

  postPatch = ''
        substituteInPlace $cargoDepsCopy/source-registry-0/grpcio-sys-0.12.1+1.46.5-patched/grpc/third_party/abseil-cpp/absl/strings/str_format.h \
          --replace-fail '#include <cstdio>' '#include <cstdio>
    #include <stdint.h>'
        substituteInPlace $cargoDepsCopy/source-registry-0/grpcio-sys-0.12.1+1.46.5-patched/grpc/third_party/abseil-cpp/absl/strings/internal/str_format/extension.h \
          --replace-fail '#include <limits.h>' '#include <limits.h>
    #include <stdint.h>'

        sed -i '/#  Test executable/,$d' trusted-services-vendor/deployments/libts/linux-pc/CMakeLists.txt
        substituteInPlace trusted-services-vendor/external/nanopb/nanopb-init-cache.cmake.in \
          --replace-fail '${"\${CMAKE_SOURCE_DIR}"}/generator/protoc' '${protobuf}/bin/protoc'
        substituteInPlace trusted-services-vendor/external/nanopb/nanopb-init-cache.cmake.in \
          --replace-fail 'set(nanopb_BUILD_GENERATOR On CACHE BOOL "")' \
            'set(nanopb_BUILD_GENERATOR Off CACHE BOOL "")'
  '';

  preBuild = ''
    depsDir=trusted-services-vendor/build-libts/_deps
    mkdir -p "$depsDir"

    cp -R ${nanopb} "$depsDir/nanopb-src"
    chmod -R u+w "$depsDir/nanopb-src"
    printf '%s\n' \
      'def resource_filename(package, resource):' \
      '    raise RuntimeError("grpc_tools is not available")' \
      > "$depsDir/nanopb-src/generator/pkg_resources.py"

    cp -R ${qcbor} "$depsDir/qcbor-src"
    chmod -R u+w "$depsDir/qcbor-src"
    for patchFile in trusted-services-vendor/external/qcbor/*.patch; do
      patch -d "$depsDir/qcbor-src" -p1 < "$patchFile"
    done

    cp -R ${t_cose} "$depsDir/t_cose-src"
    chmod -R u+w "$depsDir/t_cose-src"
    for patchFile in trusted-services-vendor/external/t_cose/*.patch; do
      patch -d "$depsDir/t_cose-src" -p1 < "$patchFile"
    done

    cmake \
      -S trusted-services-vendor/deployments/libts/linux-pc \
      -B trusted-services-vendor/build-libts \
      -DMBEDTLS_INSTALL_DIR=${mbedtls} \
      -DCMAKE_INSTALL_PREFIX=$PWD/trusted-services-vendor/build-libts/install
    cmake --build trusted-services-vendor/build-libts --target install

    export LIBRARY_PATH="$PWD/trusted-services-vendor/build-libts/install/linux-pc/lib:$LIBRARY_PATH"
    export LD_LIBRARY_PATH="$PWD/trusted-services-vendor/build-libts/install/linux-pc/lib:$LD_LIBRARY_PATH"
  '';

  postInstall = ''
    install -Dm755 trusted-services-vendor/build-libts/install/linux-pc/lib/libts.so.*.*.* -t $out/lib
    cp -P trusted-services-vendor/build-libts/install/linux-pc/lib/libts.so* $out/lib
  '';

  buildFeatures = [
    "mbed-crypto-provider"
    "pkcs11-provider"
    "tpm-provider"
    "cryptoauthlib-provider"
    "trusted-service-provider"

    "direct-authenticator"
    "unix-peer-credentials-authenticator"
    "jwt-svid-authenticator"
  ];

  meta = {
    description = "Platform AbstRaction for SECurity";
    homepage = "https://parsec.community";
    changelog = "https://github.com/parallaxsecond/parsec/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "parsec";
    platforms = lib.platforms.linux;
  };
})
