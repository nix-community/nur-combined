{ lib, stdenv, fetchurl
# By default, jemalloc puts a je_ prefix onto all its symbols on OSX, which
# then stops downstream builds (mariadb in particular) from detecting it. This
# option should remove the prefix and give us a working jemalloc.
# Causes segfaults with some software (ex. rustc), but defaults to true for backward
# compatibility.
, stripPrefix ? stdenv.hostPlatform.isDarwin
, disableInitExecTls ? false
}:

stdenv.mkDerivation rec {
  pname = "jemalloc";
  version = "4.5.0";

  src = fetchurl {
    url = "https://github.com/jemalloc/jemalloc/releases/download/${version}/${pname}-${version}.tar.bz2";
    sha256 = "sha256-lAnYVmS08TW3dRiwsRjFSQCdwQ9suhRVfRcEdmEfZ4A=";
  };

  # see the comment on stripPrefix
  configureFlags = []
    ++ lib.optional stripPrefix "--with-jemalloc-prefix="
    ++ lib.optional disableInitExecTls "--disable-initial-exec-tls"
    # jemalloc is unable to correctly detect transparent hugepage support on
    # ARM (https://github.com/jemalloc/jemalloc/issues/526), and the default
    # kernel ARMv6/7 kernel does not enable it, so we explicitly disable support
    ++ lib.optionals (stdenv.hostPlatform.isAarch32 && lib.versionOlder lib.version "5") [
      "--disable-thp"
      "je_cv_thp=no"
    ]
  ;

  patches = [
    # https://github.com/jemalloc/jemalloc/pull/2244
    # Use volatile to workaround buffer overflow false positives.
    ./patch/fix-integration-test.patch
  ];

  doCheck = true;

  enableParallelBuilding = true;

  meta = {
    homepage = "http://jemalloc.net";
    description = "General purpose malloc(3) implementation";
    longDescription = ''
      malloc(3)-compatible memory allocator that emphasizes fragmentation
      avoidance and scalable concurrency support.
    '';
    license = lib.licenses.bsd2;
    platforms = lib.platforms.all;
  };
}
