{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, buildPackages
, cmake
, zlib
, c-ares
, pkg-config
, re2
, openssl
, protobuf
, grpc
, abseil-cpp
, libnsl
}:

stdenv.mkDerivation rec {
  pname = "grpc";
  version = "1.3.2"; # N.B: if you change this, change pythonPackages.grpcio-tools to a matching version too
  core_version = "3.0.0";

  src = fetchFromGitHub {
    owner = "grpc";
    repo = "grpc";
    rev = "v${version}";
    sha256 = "sha256-G7KI8qZB96TXcSpK5OgmL7GkhDk64ImToEDekCQbg1c=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ]
    ++ lib.optional (stdenv.hostPlatform != stdenv.buildPlatform) grpc;
  propagatedBuildInputs = [ c-ares re2 zlib abseil-cpp ];
  buildInputs = [ c-ares.cmake-config openssl protobuf ]
    ++ lib.optionals stdenv.isLinux [ libnsl ];

  patches = [ 
    ./0002-fix-CMakeLists.txt.patch
    ./0003-update-for-newer-openssl.patch
    ];

  postPatch = /* add pkg-config generation  */ ''
    cp ${./pkg-config-templace.pc.in} cmake/pkg-config-template.pc.in
    sed -e '/^project(/iset(gRPC_CORE_VERSION "${core_version}")' -i CMakeLists.txt
    echo "include(${./GeneratePkgconfig.cmake})" >> CMakeLists.txt
  '' + /* update for the new glibc */ ''
    sed -e '/syscall(__NR_gettid)/d' -i src/core/lib/support/log_linux.c
  '';

  cmakeFlags = [
    "-DgRPC_ZLIB_PROVIDER=package"
    "-DgRPC_CARES_PROVIDER=package"
    "-DgRPC_RE2_PROVIDER=package"
    "-DgRPC_SSL_PROVIDER=package"
    "-DgRPC_PROTOBUF_PROVIDER=package"
    "-DgRPC_ABSL_PROVIDER=package"
    "-DBUILD_SHARED_LIBS=ON"
    "-DCMAKE_SKIP_BUILD_RPATH=OFF"
  ] ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "-D_gRPC_PROTOBUF_PROTOC_EXECUTABLE=${buildPackages.protobuf}/bin/protoc"
  ] ++ lib.optionals ((stdenv.hostPlatform.useLLVM or false) && lib.versionOlder stdenv.cc.cc.version "11.0") [
    # Needs to be compiled with -std=c++11 for clang < 11. Interestingly this is
    # only an issue with the useLLVM stdenv, not the darwin stdenv…
    # https://github.com/grpc/grpc/issues/26473#issuecomment-860885484
    "-DCMAKE_CXX_STANDARD=11"
  ];

  # CMake creates a build directory by default, this conflicts with the
  # basel BUILD file on case-insensitive filesystems.
  preConfigure = ''
    rm -vf BUILD
  '';

  # When natively compiling, grpc_cpp_plugin is executed from the build directory,
  # needing to load dynamic libraries from the build directory, so we set
  # LD_LIBRARY_PATH to enable this. When cross compiling we need to avoid this,
  # since it can cause the grpc_cpp_plugin executable from buildPackages to
  # crash if build and host architecture are compatible (e. g. pkgsLLVM).
  preBuild = lib.optionalString (stdenv.hostPlatform == stdenv.buildPlatform) ''
    export LD_LIBRARY_PATH=$(pwd)''${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH
  '';

  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=unknown-warning-option"
    + lib.optionalString stdenv.isAarch64 "-Wno-error=format-security";

  enableParallelBuilds = true;

  meta = with lib; {
    description = "The C based gRPC (C++, Python, Ruby, Objective-C, PHP, C#)";
    license = licenses.asl20;
    maintainers = with maintainers; [ lnl7 marsam ];
    homepage = "https://grpc.io/";
    platforms = platforms.all;
    changelog = "https://github.com/grpc/grpc/releases/tag/v${version}";
  };
}
