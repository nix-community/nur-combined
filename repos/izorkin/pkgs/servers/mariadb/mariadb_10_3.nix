{ lib, stdenv, fetchurl
# Native buildInputs components
, bison, boost, cmake, fixDarwinDylibNames, makeWrapper, pkg-config
# Common components
, curl, libiconv, ncurses, openssl, pcre
, libaio, libkrb5, systemd
, CoreServices, cctools, perl
, jemalloc450, jemalloc, less
# Server components
, bzip2, lz4, lzo, snappy, xz, zlib, zstd
, cracklib, judy, libevent, libxml2
, linux-pam, numactl
, withStorageMroonga ? true, kytea, libsodium, msgpack, zeromq
, withStorageRocks ? true
, withStorageToku ? true
}:

with lib;

let # in mariadb # spans the whole file

libExt = stdenv.hostPlatform.extensions.sharedLibrary;

mytopEnv = perl.withPackages (p: with p; [ DBDmysql DBI TermReadKey ]);

mariadb = server // {
  inherit client; # MariaDB Client
  server = server; # MariaDB Server
};

common = rec { # attributes common to both builds
  version = "10.3.35";

  src = fetchurl {
    url = "https://downloads.mariadb.com/MariaDB/mariadb-${version}/source/mariadb-${version}.tar.gz";
    sha256 = "sha256-iaZ9uz84ZTPTk4WRBqYdG8pe6p2dyJ4hfo0JTrxRCds=";
    name   = "mariadb-${version}.tar.gz";
  };

  nativeBuildInputs = [ cmake pkg-config ]
    ++ optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames
    ++ optional (!stdenv.hostPlatform.isDarwin) makeWrapper;

  buildInputs = [
    curl libiconv ncurses openssl pcre zlib
  ] ++ optionals stdenv.hostPlatform.isLinux [ libaio libkrb5 systemd ]
    ++ optionals stdenv.hostPlatform.isDarwin [ CoreServices cctools perl ]
    ++ optional (!stdenv.hostPlatform.isDarwin && withStorageToku) [ jemalloc450 ]
    ++ optional (!stdenv.hostPlatform.isDarwin && !withStorageToku) [ jemalloc ];

  prePatch = ''
    sed -i 's,[^"]*/var/log,/var/log,g' storage/mroonga/vendor/groonga/CMakeLists.txt
  '';

  patches = [
    ./patch/cmake-includedir.patch
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
    "-DINSTALL_LIBDIR=lib"
    "-DINSTALL_PLUGINDIR=lib/mysql/plugin"
    "-DINSTALL_INFODIR=share/mysql/docs"
    "-DINSTALL_MANDIR=share/man"
    "-DINSTALL_MYSQLSHAREDIR=share/mysql"
    "-DINSTALL_SCRIPTDIR=bin"
    "-DINSTALL_SUPPORTFILESDIR=share/doc/mysql"
    "-DINSTALL_MYSQLTESTDIR=OFF"
    "-DINSTALL_SQLBENCHDIR=OFF"
    "-DINSTALL_PAMDIR=share/pam/lib/security"
    "-DINSTALL_PAMDATADIR=share/pam/etc/security"

    "-DWITH_ZLIB=system"
    "-DWITH_SSL=system"
    "-DWITH_PCRE=system"
    "-DWITH_SAFEMALLOC=OFF"
    "-DWITH_UNIT_TESTS=OFF"
    "-DEMBEDDED_LIBRARY=OFF"
  ] ++ optionals stdenv.hostPlatform.isDarwin [
    # On Darwin without sandbox, CMake will find the system java and attempt to build with java support, but
    # then it will fail during the actual build. Let's just disable the flag explicitly until someone decides
    # to pass in java explicitly.
    "-DCONNECT_WITH_JDBC=OFF"
    "-DCURSES_LIBRARY=${ncurses.out}/lib/libncurses.dylib"
  ];

  postInstall = ''
    # Remove Development components. Need to use libmysqlclient.
    rm "$out"/lib/mysql/plugin/daemon_example.ini
    rm "$out"/lib/{libmariadbclient.a,libmysqlclient.a,libmysqlclient_r.a,libmysqlservices.a}
    rm "$out"/bin/{mariadb_config,mysql_config}
    rm -r $out/include
    rm -r $out/lib/pkgconfig
    rm -r $out/share/aclocal
  '';

  # perlPackages.DBDmysql is broken on darwin
  postFixup = optionalString (!stdenv.hostPlatform.isDarwin) ''
    wrapProgram $out/bin/mytop --set PATH ${makeBinPath [ less ncurses ]}
  '';

  passthru.mysqlVersion = "5.7";

  meta = {
    description = "An enhanced, drop-in replacement for MySQL";
    homepage    = "https://mariadb.org/";
    license     = licenses.gpl2;
    maintainers = with maintainers; [ thoughtpolice ];
    platforms   = platforms.all;
  };
};

client = stdenv.mkDerivation (common // {
  pname = "mariadb-client";

  outputs = [ "out" "man" ];

  patches = common.patches ++ [
    ./patch/cmake-plugin-includedir.patch
  ];

  cmakeFlags = common.cmakeFlags ++ [
    "-DPLUGIN_AUTH_PAM=OFF"
    "-DWITHOUT_SERVER=ON"
    "-DWITH_WSREP=OFF"
    "-DINSTALL_MYSQLSHAREDIR=share/mysql-client"
  ];

  postInstall = common.postInstall + ''
    rm -r "$out"/share/doc
    rm "$out"/bin/mysqltest
    libmysqlclient_path=$(readlink -f $out/lib/libmysqlclient${libExt})
    rm "$out"/lib/{libmariadb${libExt},libmysqlclient${libExt},libmysqlclient_r${libExt}}
    mv "$libmysqlclient_path" "$out"/lib/libmysqlclient${libExt}
    ln -sv libmysqlclient${libExt} "$out"/lib/libmysqlclient_r${libExt}
  '';
});

server = stdenv.mkDerivation (common // {
  pname = "mariadb-server";

  outputs = [ "out" "man" ];

  nativeBuildInputs = common.nativeBuildInputs ++ [ bison boost.dev ];

  buildInputs = common.buildInputs ++ [
    bzip2 lz4 lzo snappy xz zstd
    cracklib judy libevent libxml2
  ] ++ optional (stdenv.hostPlatform.isLinux && !stdenv.hostPlatform.isAarch32) numactl
    ++ optional stdenv.hostPlatform.isLinux linux-pam
    ++ optional (!stdenv.hostPlatform.isDarwin) mytopEnv
    ++ optionals withStorageMroonga [ kytea libsodium msgpack zeromq ];

  patches = common.patches;

  postPatch = ''
    substituteInPlace scripts/galera_new_cluster.sh \
      --replace ":-mariadb" ":-mysql"
  '';

  cmakeFlags = common.cmakeFlags ++ [
    "-DMYSQL_DATADIR=/var/lib/mysql"
    "-DENABLED_LOCAL_INFILE=OFF"
    "-DWITH_READLINE=ON"
    "-DWITH_EXTRA_CHARSETS=all"
    "-DWITH_EMBEDDED_SERVER=OFF"
    "-DWITH_UNIT_TESTS=OFF"
    "-DWITH_WSREP=ON"
    "-DWITH_INNODB_DISALLOW_WRITES=ON"
    "-DWITHOUT_EXAMPLE=1"
    "-DWITHOUT_FEDERATED=1"
  ] ++ optional (stdenv.hostPlatform.isLinux && !stdenv.hostPlatform.isAarch32) [
    "-DWITH_NUMA=ON"
  ] ++ optional (!withStorageMroonga) [
    "-DWITHOUT_MROONGA=1"
  ] ++ optional (!withStorageRocks) [
    "-DWITHOUT_ROCKSDB=1"
  ] ++ optional (!stdenv.hostPlatform.isDarwin && withStorageRocks) [
    "-DWITH_ROCKSDB_JEMALLOC=ON"
  ] ++ optional (stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isMusl || !withStorageToku) [
    "-DWITHOUT_TOKUDB=1"
  ] ++ optional (!stdenv.hostPlatform.isDarwin && withStorageToku) [
    "-DWITH_JEMALLOC=static"
  ] ++ optional stdenv.hostPlatform.isDarwin [
    "-DPLUGIN_AUTH_PAM=OFF"
    "-DWITHOUT_OQGRAPH=1"
  ];

  preConfigure = optionalString (!stdenv.hostPlatform.isDarwin) ''
    patchShebangs scripts/mytop.sh
  '';

  postInstall = common.postInstall + ''
    chmod +x "$out"/bin/wsrep_sst_common
    rm "$out"/bin/{mysql_client_test,mysqltest}
    rm -r "$out"/data # Don't need testing data
  '' + optionalString withStorageMroonga ''
    mv "$out"/share/{groonga,groonga-normalizer-mysql} "$out"/share/doc/mysql
  '';

  CXXFLAGS = optionalString stdenv.hostPlatform.isi686 "-fpermissive";
});
in mariadb
