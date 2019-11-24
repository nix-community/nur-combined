# pcre functionality is tested in nixos/tests/php-pcre.nix
{ config, lib, stdenv, fetchurl
, autoconf, automake, bison, file, flex, libtool, pkgconfig, re2c
, libxml2, readline, zlib, curl, postgresql, gettext
, openssl, pcre, pcre2, sqlite
, libxslt, libmcrypt, bzip2, icu, openldap, cyrus_sasl, libmhash, unixODBC
, uwimap, pam, gmp, apacheHttpd, libiconv, systemd, libsodium, html-tidy, libargon2
, gd, freetype, libXpm, libjpeg, libpng, libwebp
, libzip, valgrind, oniguruma
, bison2, freetds, icu60
}:

with lib;

let
  php7 = versionAtLeast version "7.0";
  generic =
  { version
  , sha256
  , extraPatches ? []
  , withSystemd ? config.php.systemd or stdenv.isLinux
  , imapSupport ? config.php.imap or (!stdenv.isDarwin)
  , ldapSupport ? config.php.ldap or true
  , mhashSupport ? (config.php.mhash or true) && (versionOlder version "7.0")
  , mysqlSupport ? (config.php.mysql or true) && (!php7)
  , mysqlndSupport ? config.php.mysqlnd or true
  , mysqliSupport ? (config.php.mysqli or true) && (mysqlndSupport)
  , pdo_mysqlSupport ? (config.php.pdo_mysql or true) && (mysqlndSupport)
  , libxml2Support ? config.php.libxml2 or true
  , apxs2Support ? config.php.apxs2 or (!stdenv.isDarwin)
  , embedSupport ? config.php.embed or false
  , bcmathSupport ? config.php.bcmath or true
  , socketsSupport ? config.php.sockets or true
  , curlSupport ? config.php.curl or true
  , gettextSupport ? config.php.gettext or true
  , pcntlSupport ? config.php.pcntl or true
  , pdo_odbcSupport ? config.php.pdo_odbc or true
  , postgresqlSupport ? config.php.postgresql or true
  , pdo_pgsqlSupport ? config.php.pdo_pgsql or true
  , readlineSupport ? config.php.readline or true
  , sqliteSupport ? config.php.sqlite or true
  , soapSupport ? (config.php.soap or true) && (libxml2Support)
  , zlibSupport ? config.php.zlib or true
  , opensslSupport ? config.php.openssl or true
  , mbstringSupport ? config.php.mbstring or true
  , gdSupport ? config.php.gd or true
  , intlSupport ? config.php.intl or true
  , exifSupport ? config.php.exif or true
  , xslSupport ? config.php.xsl or false
  , mcryptSupport ? (config.php.mcrypt or true) && (versionOlder version "7.2")
  , bz2Support ? config.php.bz2 or false
  , zipSupport ? config.php.zip or true
  , ftpSupport ? config.php.ftp or true
  , fpmSupport ? config.php.fpm or true
  , gmpSupport ? config.php.gmp or true
  , mssqlSupport ? (config.php.mssql or (!stdenv.isDarwin)) && (!php7)
  , ztsSupport ? (config.php.zts or false) || (apxs2Support)
  , calendarSupport ? config.php.calendar or true
  , sodiumSupport ? (config.php.sodium or true) && (versionAtLeast version "7.2")
  , tidySupport ? (config.php.tidy or false)
  , argon2Support ? (config.php.argon2 or true) && (versionAtLeast version "7.2")
  , libzipSupport ? (config.php.libzip or true) && (versionAtLeast version "7.2")
  , phpdbgSupport ? config.php.phpdbg or true
  , cgiSupport ? config.php.cgi or true
  , cliSupport ? config.php.cli or true
  , pharSupport ? config.php.phar or true
  , xmlrpcSupport ? (config.php.xmlrpc or false) && (libxml2Support)
  , cgotoSupport ? config.php.cgoto or false
  , valgrindSupport ? (config.php.valgrind or true) && (versionAtLeast version "7.2")
  , ipv6Support ? config.php.ipv6 or true
  , pearSupport ? (config.php.pear or true) && (libxml2Support)
  }:

    let
      libmcrypt' = libmcrypt.override { disablePosixThreads = true; };
    in stdenv.mkDerivation {

      inherit version;

      pname = "php";

      enableParallelBuilding = true;

      nativeBuildInputs = [
        autoconf automake file flex libtool pkgconfig re2c
      ] ++ optional (versionOlder version "7.0") bison2
        ++ optional (versionAtLeast version "7.0") bison;

      buildInputs = [ ]
        ++ optional (versionOlder version "7.3") pcre
        ++ optional (versionAtLeast version "7.3") pcre2
        ++ optional (versionAtLeast version "7.4") oniguruma
        ++ optional withSystemd systemd
        ++ optionals imapSupport [ uwimap openssl pam ]
        ++ optionals curlSupport [ curl openssl ]
        ++ optionals ldapSupport [ openldap openssl ]
        ++ optionals gdSupport [ gd freetype libXpm libjpeg libpng libwebp ]
        ++ optionals opensslSupport [ openssl openssl.dev ]
        ++ optional apxs2Support apacheHttpd
        ++ optional (ldapSupport && stdenv.isLinux) cyrus_sasl
        ++ optional mhashSupport libmhash
        ++ optional zlibSupport zlib
        ++ optional libxml2Support libxml2
        ++ optional readlineSupport readline
        ++ optional sqliteSupport sqlite
        ++ optional postgresqlSupport postgresql
        ++ optional pdo_odbcSupport unixODBC
        ++ optional pdo_pgsqlSupport postgresql
        ++ optional gmpSupport gmp
        ++ optional gettextSupport gettext
        ++ optional (intlSupport && (versionOlder version "7.0")) icu60
        ++ optional (intlSupport && (versionAtLeast version "7.0")) icu
        ++ optional xslSupport libxslt
        ++ optional mcryptSupport libmcrypt'
        ++ optional bz2Support bzip2
        ++ optional (mssqlSupport && !stdenv.isDarwin) freetds
        ++ optional sodiumSupport libsodium
        ++ optional tidySupport html-tidy
        ++ optional argon2Support libargon2
        ++ optional libzipSupport libzip
        ++ optional valgrindSupport valgrind;

      CXXFLAGS = optional stdenv.cc.isClang "-std=c++11";

      configureFlags = [
        "--with-config-file-scan-dir=/etc/php.d"
      ]
      ++ optional (versionOlder version "7.3") "--with-pcre-regex=${pcre.dev} PCRE_LIBDIR=${pcre}"
      ++ optional ((versionAtLeast version "7.3") && (!versionAtLeast version "7.4")) "--with-pcre-regex=${pcre2.dev} PCRE_LIBDIR=${pcre2}"
      ++ optional (versionAtLeast version "7.4") "--with-external-pcre=${pcre2.dev} PCRE_LIBDIR=${pcre2}"
      ++ optional stdenv.isDarwin "--with-iconv=${libiconv}"
      ++ optional withSystemd "--with-fpm-systemd"
      ++ optionals imapSupport [
        "--with-imap=${uwimap}"
        "--with-imap-ssl"
      ]
      ++ optionals ldapSupport [
        "--with-ldap=/invalid/path"
        "LDAP_DIR=${openldap.dev}"
        "LDAP_INCDIR=${openldap.dev}/include"
        "LDAP_LIBDIR=${openldap.out}/lib"
      ]
      ++ optional (ldapSupport && stdenv.isLinux)   "--with-ldap-sasl=${cyrus_sasl.dev}"
      ++ optional apxs2Support "--with-apxs2=${apacheHttpd.dev}/bin/apxs"
      ++ optional embedSupport "--enable-embed"
      ++ optional mhashSupport "--with-mhash"
      ++ optional curlSupport "--with-curl=${curl.dev}"
      ++ optional zlibSupport "--with-zlib=${zlib.dev}"
      ++ optional (libxml2Support && (versionOlder version "7.4")) "--with-libxml-dir=${libxml2.dev}"
      ++ optional (!libxml2Support) [
        "--disable-dom"
        ( if (versionOlder version "7.4") then "--disable-libxml" else "--without-libxml" )
        "--disable-simplexml"
        "--disable-xml"
        "--disable-xmlreader"
        "--disable-xmlwriter"
        "--without-pear"
      ]
      ++ optional pcntlSupport "--enable-pcntl"
      ++ optional readlineSupport "--with-readline=${readline.dev}"
      ++ optional sqliteSupport "--with-pdo-sqlite=${sqlite.dev}"
      ++ optional postgresqlSupport "--with-pgsql=${postgresql}"
      ++ optional pdo_odbcSupport "--with-pdo-odbc=unixODBC,${unixODBC}"
      ++ optional pdo_pgsqlSupport "--with-pdo-pgsql=${postgresql}"
      ++ optional (pdo_mysqlSupport && mysqlndSupport) "--with-pdo-mysql=mysqlnd"
      ++ optional (mysqliSupport && mysqlndSupport) "--with-mysqli=mysqlnd"
      ++ optional (pdo_mysqlSupport || mysqliSupport) "--with-mysql-sock=/run/mysqld/mysqld.sock"
      ++ optional bcmathSupport "--enable-bcmath"
      ++ optionals gdSupport [
        ( if (versionOlder version "7.4")
          then [
            "--with-gd=${gd.dev}"
            ( if (versionAtLeast version "7.0") then "--with-webp-dir=${libwebp}" else null )
            "--with-jpeg-dir=${libjpeg.dev}"
            "--with-png-dir=${libpng.dev}"
            "--with-freetype-dir=${freetype.dev}"
            "--with-xpm-dir=${libXpm.dev}"
            "--enable-gd-jis-conv"
          ] else [
            "--enable-gd"
            "--with-external-gd=${gd.dev}"
            "--with-webp=${libwebp}"
            "--with-jpeg=${libjpeg.dev}"
            "--with-xpm=${libXpm.dev}"
            "--with-freetype=${freetype.dev}"
            "--enable-gd-jis-conv"
          ]
        )
      ]
      ++ optional gmpSupport "--with-gmp=${gmp.dev}"
      ++ optional soapSupport "--enable-soap"
      ++ optional socketsSupport "--enable-sockets"
      ++ optional opensslSupport "--with-openssl"
      ++ optional mbstringSupport "--enable-mbstring"
      ++ optional gettextSupport "--with-gettext=${gettext}"
      ++ optional intlSupport "--enable-intl"
      ++ optional exifSupport "--enable-exif"
      ++ optional xslSupport "--with-xsl=${libxslt.dev}"
      ++ optional mcryptSupport "--with-mcrypt=${libmcrypt'}"
      ++ optional bz2Support "--with-bz2=${bzip2.dev}"
      ++ optional (zipSupport && (versionOlder version "7.4")) "--enable-zip"
      ++ optional ftpSupport "--enable-ftp"
      ++ optional fpmSupport "--enable-fpm"
      ++ optional (mssqlSupport && !stdenv.isDarwin) "--with-mssql=${freetds}"
      ++ optional ztsSupport "--enable-maintainer-zts"
      ++ optional calendarSupport "--enable-calendar"
      ++ optional sodiumSupport "--with-sodium=${libsodium.dev}"
      ++ optional tidySupport "--with-tidy=${html-tidy}"
      ++ optional argon2Support "--with-password-argon2=${libargon2}"
      ++ optional (libzipSupport && (versionOlder version "7.4")) "--with-libzip=${libzip.dev}"
      ++ optional phpdbgSupport "--enable-phpdbg"
      ++ optional (!phpdbgSupport) "--disable-phpdbg"
      ++ optional (!cgiSupport) "--disable-cgi"
      ++ optional (!cliSupport) "--disable-cli"
      ++ optional (!pharSupport) "--disable-phar"
      ++ optional xmlrpcSupport "--with-xmlrpc"
      ++ optional cgotoSupport "--enable-re2c-cgoto"
      ++ optional valgrindSupport "--with-valgrind=${valgrind.dev}"
      ++ optional (!ipv6Support) "--disable-ipv6"
      ++ optional (pearSupport && libxml2Support) "--with-pear=$(out)/lib/php/pear";

      hardeningDisable = [ "bindnow" ];

      preConfigure = ''
        # Don't record the configure flags since this causes unnecessary
        # runtime dependencies
        for i in main/build-defs.h.in scripts/php-config.in; do
          substituteInPlace $i \
            --replace '@CONFIGURE_COMMAND@' '(omitted)' \
            --replace '@CONFIGURE_OPTIONS@' "" \
            --replace '@PHP_LDFLAGS@' ""
        done

        substituteInPlace ./build/libtool.m4 --replace /usr/bin/file ${file}/bin/file

        export EXTENSION_DIR=$out/lib/php/extensions

        ./buildconf --copy --force

        if test -f $src/genfiles; then
          ./genfiles
        fi
      '' + optionalString stdenv.isDarwin ''
        substituteInPlace configure --replace "-lstdc++" "-lc++"
      '';

      postInstall = ''
        test -d $out/etc || mkdir $out/etc
        cp php.ini-production $out/etc/php.ini
      '';

      postFixup = ''
        mkdir -p $dev/bin $dev/share/man/man1
        mv $out/bin/phpize $out/bin/php-config $dev/bin/
        mv $out/share/man/man1/phpize.1.gz \
           $out/share/man/man1/php-config.1.gz \
           $dev/share/man/man1/
      '';

      src = fetchurl {
        url = "https://www.php.net/distributions/php-${version}.tar.bz2";
        inherit sha256;
      };

      meta = with stdenv.lib; {
        description = "An HTML-embedded scripting language";
        homepage = https://www.php.net/;
        license = licenses.php301;
        maintainers = with maintainers; [ globin etu ];
        platforms = platforms.all;
        outputsToInstall = [ "out" "dev" ];
      };

      patches = if !php7 then [ ./patch/fix-paths-php5.patch ] else [ ./patch/fix-paths-php7.patch ] ++ extraPatches;

      stripDebugList = "bin sbin lib modules";

      outputs = [ "out" "dev" ];

    };

in {
  php56 = generic {
    version = "5.6.40";
    sha256 = "005s7w167dypl41wlrf51niryvwy1hfv53zxyyr3lm938v9jbl7z";

    extraPatches = [
     ./patch/php56/php5640-77540.patch # https://bugs.php.net/bug.php?id=77540
     ./patch/php56/php5640-77563.patch # https://bugs.php.net/bug.php?id=77563
     ./patch/php56/php5640-77630.patch # https://bugs.php.net/bug.php?id=77630
     ./patch/php56/php5640-76846.patch # https://bugs.php.net/bug.php?id=76846
     ./patch/php56/php5640-77753.patch # https://bugs.php.net/bug.php?id=77753
     ./patch/php56/php5640-77831.patch # https://bugs.php.net/bug.php?id=77831
     ./patch/php56/php5640-sqlite3-defensive.patch # Added sqlite3.defensive INI directive
     ./patch/php56/php5640-77950.patch # https://bugs.php.net/bug.php?id=77950
     ./patch/php56/php5640-77967.patch # https://bugs.php.net/bug.php?id=77967
     ./patch/php56/php5640-77988.patch # https://bugs.php.net/bug.php?id=77988
     ./patch/php56/php5640-78069.patch # https://bugs.php.net/bug.php?id=78069
     ./patch/php56/php5640-77919.patch # https://bugs.php.net/bug.php?id=77919
     ./patch/php56/php5640-78222.patch # https://bugs.php.net/bug.php?id=78222
     ./patch/php56/php5640-78256.patch # https://bugs.php.net/bug.php?id=78256
     ./patch/php56/php5640-75457.patch # https://bugs.php.net/bug.php?id=75457
     ./patch/php56/php5640-78380.patch # https://bugs.php.net/bug.php?id=78380
    ];
  };

  php71 = generic {
    version = "7.1.33";
    sha256 = "0jsgiwawlais8s1l38lz51h1x2ci5ildk0ksfdmkg6xpwbrfb9cm";

    # https://bugs.php.net/bug.php?id=76826
    extraPatches = optional stdenv.isDarwin ./patch/php71-darwin-isfinite.patch;
  };

  php72 = generic {
    version = "7.2.25";
    sha256 = "17kb7b3wpdmdhnlv23qc0vax0lp2gr1v7dxwdgs8g78gxnqkdcvw";

    # https://bugs.php.net/bug.php?id=76826
    extraPatches = optional stdenv.isDarwin ./patch/php72-darwin-isfinite.patch;
  };

  php73 = generic {
    version = "7.3.12";
    sha256 = "0fccmnrwwyy5zvhj8wbyqqlyqr7pr5v4pfiqriw0ahciz4lv05yk";

    # https://bugs.php.net/bug.php?id=76826
    extraPatches = optional stdenv.isDarwin ./patch/php73-darwin-isfinite.patch;
  };

  php74 = let
    version = "7.4.0RC6";
    sha256 = "1q20ax5mphypq7dwxd509lzca6m0rcxkzmcbkc6kg4bw6gvnjkyv";
  in (generic {
    inherit version sha256;
  }).overrideAttrs(oa: {
    src = fetchurl {
      url = "https://downloads.php.net/~derick/php-${version}.tar.bz2";
      inherit sha256;
    };
  });
}
