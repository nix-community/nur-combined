{ lib, stdenv, fetchpatch, fetchurl, cmake, bison, ncurses, openssl
, readline, zlib, perl, cctools, CoreServices }:

# Note: zlib is not required; MySQL can use an internal zlib.

let
self = stdenv.mkDerivation rec {
  pname = "mysql";
  version = "5.5.62";

  src = fetchurl {
    url = "mirror://mysql/MySQL-5.5/${pname}-${version}.tar.gz";
    sha256 = "1mwrzwk9ap09s430fpdkyhvx5j2syd3xj2hyfzvanjphq4xqbrxi";
  };

  patches = [
    # https://github.com/percona/percona-server/commit/c5f8e6fe6346b3837d5c23d9989073b47c326b7a
    # https://github.com/percona/percona-server/commit/abfb28442745d60553270f342debe3b11573e28f
    ./patch/5.5.62-numerous-valgrind-errors-in-openssl.patch
    # https://github.com/percona/percona-server/commit/dddeabde2fc7f6896347d69a35880ab236498ee3
    ./patch/5.5.62-openssl-1.1-support.patch
  ] ++
    # Minor type error that is a build failure as of clang 6.
    lib.optional stdenv.cc.isClang (fetchpatch {
      url = "https://svn.freebsd.org/ports/head/databases/mysql55-server/files/patch-sql_sql_partition.cc?rev=469888";
      extraPrefix = "";
      sha256 = "09sya27z3ir3xy5mrv3x68hm274594y381n0i6r5s627x71jyszf";
    }) ++
    lib.optionals stdenv.isCygwin [
      ./patch/5.5.17-cygwin.patch
      ./patch/5.5.17-export-symbols.patch
    ];

  preConfigure = lib.optional stdenv.isDarwin ''
    ln -s /bin/ps $TMPDIR/ps
    export PATH=$PATH:$TMPDIR
  '';

  buildInputs = [ cmake bison ncurses openssl readline zlib ]
     ++ lib.optionals stdenv.isDarwin [ perl cctools CoreServices ];

  cmakeFlags = [
    "-DWITH_SSL=yes"
    "-DWITH_READLINE=yes"
    "-DWITH_EMBEDDED_SERVER=yes"
    "-DWITH_ZLIB=yes"
    "-DHAVE_IPV6=yes"
    "-DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock"
    "-DMYSQL_DATADIR=/var/lib/mysql"
    "-DINSTALL_SYSCONFDIR=etc/mysql"
    "-DINSTALL_INFODIR=share/mysql/docs"
    "-DINSTALL_MANDIR=share/man"
    "-DINSTALL_PLUGINDIR=lib/mysql/plugin"
    "-DINSTALL_SCRIPTDIR=bin"
    "-DINSTALL_INCLUDEDIR=include/mysql"
    "-DINSTALL_DOCREADMEDIR=share/mysql"
    "-DINSTALL_SUPPORTFILESDIR=share/mysql"
    "-DINSTALL_MYSQLSHAREDIR=share/mysql"
    "-DINSTALL_DOCDIR=share/mysql/docs"
    "-DINSTALL_SHAREDIR=share/mysql"
    "-DINSTALL_MYSQLTESTDIR="
    "-DINSTALL_SQLBENCHDIR="
  ];

  NIX_CFLAGS_COMPILE =
    lib.optionals stdenv.cc.isGNU [ "-fpermissive" ] # since gcc-7
    ++ lib.optionals stdenv.cc.isClang [ "-Wno-c++11-narrowing" ]; # since clang 6

  NIX_LDFLAGS = lib.optionalString stdenv.isLinux "-lgcc_s";

  prePatch = ''
    sed -i -e "s|/usr/bin/libtool|libtool|" cmake/libutils.cmake
  '';
  postInstall = ''
    sed -i -e "s|basedir=\"\"|basedir=\"$out\"|" $out/bin/mysql_install_db
    rm -r $out/data "$out"/lib/*.a
  '';

  passthru = {
    client = self;
    connector-c = self;
    server = self;
    mysqlVersion = "5.5";
  };

  meta = with lib; {
    homepage = "https://www.mysql.com/";
    description = "The world's most popular open source database";
    platforms = platforms.unix;
    # See https://downloads.mysql.com/docs/licenses/mysqld-5.5-gpl-en.pdf
    license = with licenses; [
      artistic1 bsd0 bsd2 bsd3 bsdOriginal
      gpl2 lgpl2 lgpl21 mit publicDomain  licenses.zlib
    ];
    broken = stdenv.isAarch64;
  };
}; in self
