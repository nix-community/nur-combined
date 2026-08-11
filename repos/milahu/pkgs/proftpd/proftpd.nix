/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./proftpd.nix { }'
./result/bin/proftpd --help
*/

{ lib
, stdenv
, fetchFromGitHub
, pkgs
}:

stdenv.mkDerivation rec {
  pname = "proftpd";
  version = "1.3.8";

  #outputs = [ "out" "dev" ]; # error: cycle detected

  nativeBuildInputs = with pkgs; [
    # for configure
    file
    /*
    # for unit tests
    check
    subunit
    */
  ];

  buildInputs = with pkgs; [
    # for mod_auth
    libxcrypt
    # for OpenSSL support
    openssl
    # for zlib support
    zlib
    /*
    # for mod_rewrite
    libidn2
    # for xattr support
    attr
    # for mod_geoip
    geoip
    # for PAM support
    linux-pam
    # for mod_lang
    gettext
    # for mod_cap
    libcap
    # for mod_ldap
    #cyrus-sasl # FIXME undef
    #libldap # FIXME undef
    openldap
    # for memcache support
    libmemcached
    # for redis support
    hiredis
    #hiredis-ssl # FIXME undef
    #redis # not needed? ci.yml says hiredis
    # for mod_sql_mysql
    mariadb-connector-c
    # for mod_sql_postgres
    #libpq # FIXME undef
    postgresql
    # for mod_sql_odbc
    unixODBC
    # for Sodium support
    libsodium
    # for mod_sql_sqlite
    sqlite
    # NOTE: Alpine does not support mod_wrap, due to lack of tcpwrappers
    # for PCRE2 support
    pcre2 # v1.3.8
    # for ftptop
    ncurses
    */
  ];

  src = fetchFromGitHub {
    owner = "proftpd";
    repo = "proftpd";
    rev = "v${version}";
    hash = "sha256-DnVUIcrE+mW4vTZzoPk+dk+2O3jEjGbGIBiVZgcvkNA=";
  };

  # based on .github/workflows/ci.yml
  # module sources are in modules/ and contrib/
  modulesList = [
    /*
    "tls"
    "tls_fscache"
    "sftp"
    "sftp_pam"
    "deflate"
    "ban"
    "dnsbl"
    "geoip"
    "shaper"
    "load"
    "qos"
    "facl"
    "rewrite"
    "exec"
    "copy"
    "ctrls_admin"
    "dynmasq"
    "ifversion"
    "ifsession"
    "unique_id"
    "sql"
    "sql_mysql"
    "sql_odbc"
    "sql_postgres"
    "sql_sqlite"
    "sql_passwd"
    "sftp_sql"
    "tls_shmcache"
    "tls_memcache"
    "tls_redis"
    "ldap"
    "log_forensic"
    "quotatab"
    "quotatab_file"
    "quotatab_ldap"
    "quotatab_radius"
    "quotatab_sql"
    "radius"
    "readme"
    "site_misc"
    "snmp"
    "wrap2"
    "wrap2_file"
    "wrap2_redis"
    "wrap2_sql"
    "digest"
    "auth_otp"
    "statcache"
    */
  ];

  PROFTPD_MODULES = pkgs.lib.concatStringsSep ":" (
    builtins.map (val: "mod_${val}") modulesList
  );

  #preConfigure = ''./configure --help; exit 1'';

  configureFlags = [
    #''LIBS="-lodbc -lm -lsubunit -lrt -pthread"''
    #"--enable-devel=coverage:fortify" # warning: #warning _FORTIFY_SOURCE requires compiling with optimization (-O)
    #"--enable-ctrls"
    #"--enable-facl"
    #"--enable-memcache"
    #"--enable-nls"
    #"--enable-pcre2" # v1.3.8
    #"--enable-redis"
    #"--enable-dso" # load modules without restarting the server http://www.proftpd.org/docs/howto/DSO.html
    #"--enable-tests"
    #''--with-modules=${PROFTPD_MODULES}'' # static linking
    ''--with-shared=${PROFTPD_MODULES}'' # dynamic linking
  ];

  # fix: install: cannot change ownership of '/nix/store/*/sbin/proftpd': Invalid argument
  postPatch = ''
    substituteInPlace Make.rules.in \
      --subst-var-by install_user nixbld \
      --subst-var-by install_group nixbld
    substituteInPlace configure \
      --replace /usr/bin/file file
  '';

  postInstall = ''
    mkdir -p $out/share/doc/proftpd
    mv $out/etc/proftpd.conf $out/share/doc/proftpd/proftpd.conf.example
    echo 'removing empty folders'
    find "$out" -depth -type d -exec rmdir --ignore-fail-on-non-empty '{}' \;
  '';

  meta = with lib; {
    homepage = "https://github.com/proftpd/proftpd";
    description = "highly configurable FTP server";
    license = licenses.gpl2;
  };
}
