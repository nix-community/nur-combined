{
  lib,
  stdenv,
  fetchurl,
  runCommandCC,
  writeText,
  ceph,

  # Build tools
  autoconf,
  automake,
  cmake,
  fmt,
  git,
  libtool,
  pkg-config,
  python3,
  which,

  # Dependencies
  boost187,
  bzip2,
  curl,
  fetchFromGitHub,
  openssl,
  gtest,
  icu,
  lmdb,
  lua5_4,
  lz4,
  nss,
  nspr,
  oath-toolkit,
  openldap,
  rocksdb,
  snappy,
  sqlite,
  utf8proc,
  zlib,
  zstd,

  # Linux only
  babeltrace,
  gnugrep,
  kmod,
  keyutils,
  libcap,
  libcap_ng,
  libnl,
  liburing,
  libuuid,
  linuxHeaders,
  lttng-ust,
  nasm,
  rdma-core,
  udev,
  util-linux,

  # Darwin only
  apple-sdk,
}:

let
  ceph20 = lib.versionAtLeast ceph.version "20";

  version = if ceph20 then ceph.version else "20.2.0";

  src =
    if ceph20 then
      ceph.src
    else
      fetchurl {
        url = "https://download.ceph.com/tarballs/ceph-20.2.0.tar.gz";
        hash = "sha256-jeBk1pgx7zJzOVOfIzx47IJ/o1HEDO2amRbwtBdMZoU=";
      };

  ceph-python = python3.withPackages (ps: [
    ps.cython
    ps.pyyaml
  ]);

  ceph-rocksdb = rocksdb.overrideAttrs {
    version = "7.9.2";
    src = fetchFromGitHub {
      owner = "facebook";
      repo = "rocksdb";
      tag = "v7.9.2";
      hash = "sha256-5P7IqJ14EZzDkbjaBvbix04ceGGdlWBuVFH/5dpD5VM=";
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "librados";
  inherit version src;

  patches = lib.optionals (!lib.versionAtLeast version "20.2.1") [
    # PyO3 workaround — allows build on Python 3.12 (merged upstream in 20.2.1)
    (fetchurl {
      name = "ceph-upstream-pyo3-workaround.patch";
      url = "https://github.com/ceph/ceph/pull/66794.diff?full_index=1";
      hash = "sha256-+OrG9JpMOfZwtzAPJkBrzt+8BGKKiNjQMMpkJSHpGFo=";
    })
  ];

  nativeBuildInputs = [
    autoconf
    automake
    cmake
    fmt
    git
    libtool
    pkg-config
    ceph-python
    which
  ]
  ++ lib.optional stdenv.hostPlatform.isx86 nasm;

  buildInputs = [
    bzip2
    ceph-rocksdb
    curl
    gtest
    icu
    lmdb
    lua5_4
    lz4
    nss
    nspr
    oath-toolkit
    openldap
    snappy
    sqlite
    utf8proc
    zlib
    zstd
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    babeltrace
    keyutils
    libcap
    libcap_ng
    libnl
    liburing
    libuuid
    linuxHeaders
    lttng-ust
    udev
    util-linux
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk
  ];

  propagatedBuildInputs = [
    boost187
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    rdma-core
  ];

  preConfigure = ''
    unset AS
    patchShebangs src/
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace src/common/module.c \
      --replace-fail "char command[128];" "char command[256];" \
      --replace-fail "/sbin/modinfo"  "${kmod}/bin/modinfo" \
      --replace-fail "/sbin/modprobe" "${kmod}/bin/modprobe" \
      --replace-fail "/bin/grep" "${gnugrep}/bin/grep"
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Disable consteval in bundled fmt (incompatible with Clang 21)
    substituteInPlace src/fmt/include/fmt/base.h \
      --replace-fail '#  define FMT_USE_CONSTEVAL 1' '#  define FMT_USE_CONSTEVAL 0'

    # memset_s needs __STDC_WANT_LIB_EXT1__ before any string.h include
    substituteInPlace src/common/compat.cc \
      --replace-fail '// -*- mode:C++' $'#define __STDC_WANT_LIB_EXT1__ 1\n// -*- mode:C++'

    # static_cast<MetricConfigType>(-1) is UB in a constant expression (Clang 21)
    substituteInPlace src/mgr/MetricTypes.h \
      --replace-fail 'static const MetricConfigType METRIC_CONFIG_TYPE = static_cast<MetricConfigType>(-1);' \
                     'static constexpr int METRIC_CONFIG_TYPE = -1;'

    # tcp_info uses Linux-only TCP_INFO/SOL_TCP; provide stubs on macOS
    substituteInPlace src/common/tcp_info.h \
      --replace-fail '#include <netinet/tcp.h>' $'#ifdef __linux__\n#include <netinet/tcp.h>\n#endif' \
      --replace-fail 'bool tcp_info(int fd, struct tcp_info& info);' $'#ifdef __linux__\nbool tcp_info(int fd, struct tcp_info\& info);\n#endif' \
      --replace-fail 'bool dump_tcp_info(int fd, Formatter* f);' $'bool dump_tcp_info(int fd, Formatter* f);\n'
    substituteInPlace src/common/tcp_info.cc \
      --replace-fail '#include "common/tcp_info.h"' $'#include "common/tcp_info.h"\n#ifdef __linux__'
    echo $'#else\nnamespace ceph { bool dump_tcp_info(int, Formatter*) { return false; } }\n#endif' >> src/common/tcp_info.cc

    # cpu_set_t is Linux-only; include compat.h for forward declaration on macOS
    substituteInPlace src/common/numa.h \
      --replace-fail '#include <sched.h>' $'#include <sched.h>\n#ifdef __APPLE__\n#include "include/compat.h"\n#endif'

    # std::max with mismatched uint64_t vs size_t on macOS aarch64
    substituteInPlace src/osd/OSDMap.cc \
      --replace-fail 'max_prims_per_osd = std::max(max_prims_per_osd, n_prims);' \
                     'max_prims_per_osd = std::max(max_prims_per_osd, static_cast<uint64_t>(n_prims));' \
      --replace-fail 'max_acting_prims_per_osd = std::max(max_acting_prims_per_osd, n_aprims);' \
                     'max_acting_prims_per_osd = std::max(max_acting_prims_per_osd, static_cast<uint64_t>(n_aprims));'
  '';

  cmakeFlags = [
    "-DWITH_CEPHFS=OFF"
    "-DWITH_LIBCEPHFS=OFF"
    "-DWITH_LIBCEPHSQLITE=OFF"
    "-DWITH_RBD=OFF"
    "-DWITH_RADOSGW=OFF"
    "-DWITH_MGR=OFF"
    "-DWITH_FUSE=OFF"
    "-DWITH_BLUESTORE=OFF"
    "-DWITH_KRBD=OFF"
    "-DWITH_TESTS=OFF"
    "-DWITH_MGR_DASHBOARD_FRONTEND=OFF"
    "-DWITH_JAEGER=OFF"
    "-DWITH_UADK=OFF"
    "-DWITH_SPDK=OFF"
    "-DWITH_MANPAGE=OFF"

    "-DWITH_SYSTEM_BOOST=ON"
    "-DWITH_SYSTEM_ROCKSDB=ON"
    "-DWITH_SYSTEM_UTF8PROC=ON"
    "-DWITH_SYSTEM_ZSTD=ON"

    "-DCEPHADM_BUNDLED_DEPENDENCIES=none"

    "-DPython3_EXECUTABLE=${ceph-python}/bin/python3"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "-DWITH_SYSTEM_LIBURING=ON"
    "-DWITH_SYSTEMD=OFF"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "-DWITH_LTTNG=OFF"
    "-DWITH_BABELTRACE=OFF"
    "-DWITH_SYSTEMD=OFF"
    "-DWITH_RDMA=OFF"
  ];

  preBuild = ''
    cmake --build . --target legacy-option-headers -j 1
  '';

  buildPhase = ''
    runHook preBuild
    cmake --build . --target librados -j $NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Install shared libraries
    mkdir -p $out/lib
    if [[ -f lib/librados.dylib ]]; then
      cp -a lib/librados*.dylib $out/lib/
      cp -a lib/libceph-common*.dylib $out/lib/
    else
      cp -a lib/librados.so* $out/lib/
      cp -a lib/libceph-common.so* $out/lib/
      # Remove build-dir copies so shrink-rpath won't keep /build/ references
      rm lib/librados.so* lib/libceph-common.so*
    fi

    # Install headers
    mkdir -p $out/include/rados
    cp ../src/include/rados/librados.h $out/include/rados/
    cp ../src/include/rados/librados.hpp $out/include/rados/
    cp ../src/include/rados/librados_fwd.hpp $out/include/rados/
    cp ../src/include/rados/rados_types.h $out/include/rados/
    cp ../src/include/rados/rados_types.hpp $out/include/rados/
    cp ../src/include/rados/buffer.h $out/include/rados/
    cp ../src/include/rados/buffer_fwd.h $out/include/rados/
    cp ../src/include/rados/inline_memory.h $out/include/rados/
    cp ../src/include/rados/page.h $out/include/rados/
    cp ../src/include/rados/crc32c.h $out/include/rados/
  ''
  + ''
    runHook postInstall
  '';

  passthru.tests.compile =
    runCommandCC "librados-compile-test"
      {
        buildInputs = [ finalAttrs.finalPackage ];
        radosTestProgram = writeText "test.c" ''
          #include <rados/librados.h>
          int main(void) {
            rados_t c;
            rados_create2(&c, "ceph", "client.admin", 0);
            rados_shutdown(c);
            return 0;
          }
        '';
      }
      ''
        $CC $radosTestProgram -lrados -o test
        touch $out
      '';

  meta = {
    description = "C/C++ client library for Ceph RADOS object storage";
    homepage = "https://docs.ceph.com/en/latest/rados/api/librados-intro/";
    license = with lib.licenses; [
      lgpl21
      gpl2Only
      bsd3
      mit
      publicDomain
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
