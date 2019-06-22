{ stdenv, fetchurl, fetchFromGitHub, cmake, pkgconfig, ncurses, zlib, xz, lzo, lz4, bzip2, snappy
, libiconv, openssl, pcre, boost, judy, bison, libxml2, libkrb5
, libaio, libevent, jemalloc, cracklib, systemd, numactl, perl
, fixDarwinDylibNames, cctools, CoreServices
}:

with stdenv.lib;

let # in mariadb # spans the whole file

libExt = stdenv.hostPlatform.extensions.sharedLibrary;

mariadb = server // {
  inherit client; # MariaDB Client
  server = server; # MariaDB Server
};

common = rec { # attributes common to both builds
  version = "10.3.16";

  src = fetchurl {
    urls = [
      "https://downloads.mariadb.org/f/mariadb-${version}/source/mariadb-${version}.tar.gz"
      "https://downloads.mariadb.com/MariaDB/mariadb-${version}/source/mariadb-${version}.tar.gz"
    ];
    sha256 = "06z2wn4wzryc2kghl12hp8893a2hb8m2qnwjn2czs2k2mwz75s9r";
    name   = "mariadb-${version}.tar.gz";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [
    ncurses openssl zlib pcre jemalloc libiconv
  ] ++ stdenv.lib.optionals stdenv.isLinux [ libaio systemd libkrb5 ]
    ++ stdenv.lib.optionals stdenv.isDarwin [ perl fixDarwinDylibNames cctools CoreServices ];

  prePatch = ''
    sed -i 's,[^"]*/var/log,/var/log,g' storage/mroonga/vendor/groonga/CMakeLists.txt
  '';

  patches = [
    ./cmake-includedir.patch
    ./cmake-libmariadb-includedir.patch
  ] ++ optionals stdenv.isDarwin [
      # Derived from "Fixed c++11 narrowing error"
      # https://github.com/MariaDB/server/commit/a0dfefb0f8a47145e599a5f1b0dc576fa7634b92
      ./fix-c++11-narrowing-error.patch
  ];

  cmakeFlags = [
    "-DBUILD_CONFIG=mysql_release"
    "-DMANUFACTURER=NixOS.org"
    "-DDEFAULT_CHARSET=utf8mb4"
    "-DDEFAULT_COLLATION=utf8mb4_unicode_ci"
    "-DSECURITY_HARDENED=ON"

    "-DINSTALL_UNIX_ADDRDIR=/run/mysqld/mysqld.sock"
    "-DINSTALL_BINDIR=bin"
    "-DINSTALL_DOCDIR=share/doc/mysql"
    "-DINSTALL_DOCREADMEDIR=share/doc/mysql"
    "-DINSTALL_INCLUDEDIR=include/mysql"
    "-DINSTALL_LIBDIR=lib/mysql"
    "-DINSTALL_PLUGINDIR=lib/mysql/plugin"
    "-DINSTALL_INFODIR=share/mysql/docs"
    "-DINSTALL_MANDIR=share/man"
    "-DINSTALL_MYSQLSHAREDIR=share/mysql"
    "-DINSTALL_SCRIPTDIR=bin"
    "-DINSTALL_SUPPORTFILESDIR=share/doc/mysql"
    "-DINSTALL_MYSQLTESTDIR=OFF"
    "-DINSTALL_SQLBENCHDIR=OFF"

    "-DWITH_ZLIB=system"
    "-DWITH_SSL=system"
    "-DWITH_PCRE=system"
    "-DWITH_SAFEMALLOC=OFF"
    "-DWITH_UNIT_TESTS=OFF"
    "-DEMBEDDED_LIBRARY=OFF"
  ] ++ optional stdenv.isDarwin [
    # On Darwin without sandbox, CMake will find the system java and attempt to build with java support, but
    # then it will fail during the actual build. Let's just disable the flag explicitly until someone decides
    # to pass in java explicitly.
    "-DCONNECT_WITH_JDBC=OFF"
    "-DCURSES_LIBRARY=${ncurses.out}/lib/libncurses.dylib"
  ] ++ optional stdenv.hostPlatform.isMusl [
    "-DWITHOUT_TOKUDB=1" # mariadb docs say disable this for musl
  ];

  postInstall = ''
    mkdir -p "$dev"/bin && mv "$out"/bin/{mariadb_config,mysql_config} "$dev"/bin
    mkdir -p "$dev"/lib/mysql && mv "$out"/lib/mysql/{libmariadbclient.a,libmysqlclient.a,libmysqlclient_r.a,libmysqlservices.a} "$dev"/lib/mysql
    mkdir -p "$dev"/lib/mysql/plugin && mv "$out"/lib/mysql/plugin/{caching_sha2_password.so,dialog.so,mysql_clear_password.so,sha256_password.so} "$dev"/lib/mysql/plugin
  '';

  passthru.mysqlVersion = "5.7";

  meta = with stdenv.lib; {
    description = "An enhanced, drop-in replacement for MySQL";
    homepage    = https://mariadb.org/;
    license     = licenses.gpl2;
    maintainers = with maintainers; [ thoughtpolice ];
    platforms   = platforms.all;
  };
};

client = stdenv.mkDerivation (common // {
  name = "mariadb-client-${common.version}";

  outputs = [ "out" "dev" "man" ];

  propagatedBuildInputs = [ openssl zlib ]; # required from mariadb.pc

  patches = common.patches ++ [ ./cmake-plugin-includedir.patch ];

  cmakeFlags = common.cmakeFlags ++ [
    "-DWITHOUT_SERVER=ON"
    "-DWITH_WSREP=OFF"
    "-DINSTALL_MYSQLSHAREDIR=share/mysql-client"
  ];

  preConfigure = ''
    cmakeFlags="$cmakeFlags \
      -DCMAKE_INSTALL_PREFIX_DEV=$dev"
  '';

  postInstall = common.postInstall + ''
    rm "$out"/bin/{mysqltest,mytop,wsrep_sst_rsync_wan}
    rm "$out"/lib/mysql/{libmariadb${libExt},libmysqlclient_r${libExt}}
    rm "$out"/lib/mysql/plugin/daemon_example.ini
    rm -r "$out"/share/doc
    libmysqlclient_path=$(readlink -f $out/lib/mysql/libmysqlclient${libExt})
    mv "$libmysqlclient_path" "$out"/lib/mysql/libmysqlclient${libExt}
    ln -sv libmysqlclient${libExt} "$out"/lib/mysql/libmysqlclient_r${libExt}
  '';

  enableParallelBuilding = true; # the client should be OK
});

server = stdenv.mkDerivation (common // {
  name = "mariadb-server-${common.version}";

  outputs = [ "out" "dev" "man" ];

  nativeBuildInputs = common.nativeBuildInputs ++ [ bison ];

  buildInputs = common.buildInputs ++ [
    xz lzo lz4 bzip2 snappy
    libxml2 boost judy libevent cracklib
  ] ++ optional (stdenv.isLinux && !stdenv.isAarch32) numactl;

  patches = common.patches ++ [ ./cmake-without-client.patch ];

  cmakeFlags = common.cmakeFlags ++ [
    "-DMYSQL_DATADIR=/var/lib/mysql"
    "-DINSTALL_PLUGINDIR=lib/mysql/plugin"
    "-DENABLED_LOCAL_INFILE=OFF"
    "-DWITH_READLINE=ON"
    "-DWITH_EXTRA_CHARSETS=all"
    "-DWITH_EMBEDDED_SERVER=OFF"
    "-DWITH_UNIT_TESTS=OFF"
    "-DWITH_WSREP=ON"
    "-DWITH_INNODB_DISALLOW_WRITES=ON"
    "-DWITHOUT_EXAMPLE=1"
    "-DWITHOUT_FEDERATED=1"
    "-DWITHOUT_CLIENT=ON"
  ] ++ stdenv.lib.optionals stdenv.isDarwin [
    "-DWITHOUT_OQGRAPH=1"
    "-DWITHOUT_TOKUDB=1"
  ];

  preConfigure = ''
    cmakeFlags="$cmakeFlags \
      -DCMAKE_INSTALL_PREFIX_DEV=$dev
      -DINSTALL_SHAREDIR=$dev/share
      -DINSTALL_SUPPORTFILESDIR=$dev/share/mysql/support"
  '';

  postInstall = common.postInstall + ''
    chmod +x "$out"/bin/wsrep_sst_common
    rm "$out"/bin/mysql_client_test
    rm -r "$out"/data # Don't need testing data
    rm "$out"/bin/mysqltest
    ${ # We don't build with GSSAPI on Darwin
      optionalString (! stdenv.isDarwin) ''
        rm "$out"/lib/mysql/plugin/auth_gssapi_client.so
      ''
    }
    rm "$out"/lib/mysql/{libmysqlclient${libExt},libmysqlclient_r${libExt}}
    rm "$out"/lib/mysql/plugin/{daemon_example.ini,client_ed25519.so}
    mv "$out"/share/{groonga,groonga-normalizer-mysql} "$out"/share/doc/mysql
  '' + optionalString (! stdenv.isDarwin) ''
    sed -i 's/-mariadb/-mysql/' "$out"/bin/galera_new_cluster
  '';

  CXXFLAGS = optionalString stdenv.isi686 "-fpermissive";
});
in mariadb
