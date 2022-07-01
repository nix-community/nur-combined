{ config, lib, stdenv, fetchFromGitHub
, autoconf, automake, file, flex, libtool, pkg-config, re2c
, bison2, bison, php-pearweb-phars
, apacheHttpd, libargon2, systemd, system-sendmail, valgrind
, freetds, bzip2, curl, openssl
, gd, freetype, libXpm, libavif, libjpeg, libpng, libwebp
, gettext, gmp, libiconv, uwimap, pam
, icu60, icu67, icu69
, openldap, cyrus_sasl, libxml2, libmcrypt, pcre, pcre2
, unixODBC, postgresql, sqlite, readline, html-tidy
, libxslt, zlib, libzip, libsodium, oniguruma
}:

with lib;

let
  php7 = versionAtLeast version "7.0";
  generic =
  { version
  , sha256
  , rev ? null
  , extraPatches ? []

  # Sapi flags
  , apxs2Support ? config.php.apxs2 or (!stdenv.isDarwin)
  , cgiSupport ? config.php.cgi or true
  , cliSupport ? config.php.cli or true
  , embedSupport ? config.php.embed or false
  , fpmSupport ? config.php.fpm or true
  , phpdbgSupport ? config.php.phpdbg or true

  # Misc flags
  , argon2Support ? (config.php.argon2 or true) && (versionAtLeast version "7.2")
  , cgotoSupport ? config.php.cgoto or false
  , ipv6Support ? config.php.ipv6 or true
  , pearSupport ? (config.php.pear or true) && (libxml2Support)
  , systemdSupport ? config.php.systemd or stdenv.isLinux
  , valgrindSupport ? (config.php.valgrind or true) && (versionAtLeast version "7.2")
  , ztsSupport ? (config.php.zts or false) || (apxs2Support)

  # Extension flags only in 5.6
  , mssqlSupport ? (config.php.mssql or (!stdenv.isDarwin)) && (!php7)

  # Extension flags in 5.6 and higher
  , bcmathSupport ? config.php.bcmath or true
  , bz2Support ? config.php.bz2 or true
  , calendarSupport ? config.php.calendar or true
  , curlSupport ? config.php.curl or true
  , exifSupport ? config.php.exif or true
  , ftpSupport ? config.php.ftp or true
  , gdSupport ? config.php.gd or true
  , gettextSupport ? config.php.gettext or true
  , gmpSupport ? config.php.gmp or true
  , mhashSupport ? config.php.mhash or true
  , iconvSupport ? config.php.iconv or true
  , imapSupport ? config.php.imap or (!stdenv.isDarwin)
  , intlSupport ? config.php.intl or true
  , ldapSupport ? config.php.ldap or true
  , libxml2Support ? config.php.libxml2 or true
  , mbstringSupport ? config.php.mbstring or true
  , mcryptSupport ? (config.php.mcrypt or true) && (versionOlder version "7.2")
  , mysqliSupport ? (config.php.mysqli or true) && (mysqlndSupport)
  , mysqlndSupport ? config.php.mysqlnd or true
  , opensslSupport ? config.php.openssl or true
  , pcntlSupport ? config.php.pcntl or true
  , pdo_mysqlSupport ? (config.php.pdo_mysql or true) && (mysqlndSupport)
  , pdo_odbcSupport ? config.php.pdo_odbc or true
  , pdo_pgsqlSupport ? config.php.pdo_pgsql or true
  , sqliteSupport ? config.php.sqlite or true
  , pgsqlSupport ? config.php.pgsql or true
  , pharSupport ? config.php.phar or true
  , readlineSupport ? config.php.readline or true
  , soapSupport ? (config.php.soap or true) && (libxml2Support)
  , socketsSupport ? config.php.sockets or true
  , tidySupport ? (config.php.tidy or false)
  , xmlrpcSupport ? (config.php.xmlrpc or false) && (libxml2Support)
  , xslSupport ? config.php.xsl or false
  , zipSupport ? config.php.zip or true
  , libzipSupport ? (config.php.libzip or true) && (versionAtLeast version "7.2")
  , zlibSupport ? config.php.zlib or true

  # Extension flags in 7.2 and higher
  , sodiumSupport ? (config.php.sodium or true) && (versionAtLeast version "7.2")
  }:

    let
      libmcrypt' = libmcrypt.override { disablePosixThreads = true; };
      pcre' = if (versionAtLeast version "7.3") then pcre2 else pcre;
      icu' = if (versionOlder version "7.0") then icu60 else (if versionAtLeast version "8.0" then icu69 else (if versionAtLeast version "7.3" then icu69 else icu67));

    in stdenv.mkDerivation {

      inherit version;

      pname = "php";

      enableParallelBuilding = true;

      nativeBuildInputs = [
        autoconf automake file flex libtool pkg-config re2c
      ] ++ optional (versionOlder version "7.0") bison2
        ++ optional (versionAtLeast version "7.0") bison;

      buildInputs =
        # PCRE extension
        [ pcre' ]

        # Sapi flags
        ++ optional apxs2Support apacheHttpd

        # Misc flags
        ++ optional argon2Support libargon2
        ++ optional systemdSupport systemd
        ++ optional valgrindSupport valgrind

        # Extension flags only in 5.6
        ++ optional (mssqlSupport && !stdenv.isDarwin) freetds

        # Extension flags in 5.6 and higher
        ++ optional bz2Support bzip2
        ++ optionals curlSupport [ curl openssl ]
        ++ optionals gdSupport [ gd freetype libXpm libjpeg libpng libwebp ]
        ++ optional gettextSupport gettext
        ++ optional gmpSupport gmp
        ++ optional iconvSupport libiconv
        ++ optionals imapSupport [ uwimap openssl pam ]
        ++ optional intlSupport icu'
        ++ optionals ldapSupport [ openldap openssl ]
        ++ optional (ldapSupport && stdenv.isLinux) cyrus_sasl
        ++ optional libxml2Support libxml2
        ++ optional mcryptSupport libmcrypt'
        ++ optionals opensslSupport [ openssl openssl.dev ]
        ++ optional pdo_odbcSupport unixODBC
        ++ optional pdo_pgsqlSupport postgresql
        ++ optional sqliteSupport sqlite
        ++ optional pgsqlSupport postgresql
        ++ optional readlineSupport readline
        ++ optional tidySupport html-tidy
        ++ optional xslSupport libxslt
        ++ optional zlibSupport zlib
        ++ optional libzipSupport libzip

        # Extension flags in 7.2 and higher
        ++ optional sodiumSupport libsodium

        # Extension flags in 7.4 and higher
        ++ optional (versionAtLeast version "7.4") oniguruma;

      CXXFLAGS = optionalString stdenv.cc.isClang "-std=c++11";

      configureFlags = [
        "--with-config-file-scan-dir=/etc/php.d"
      ]

      # PCRE
      ++ optionals (versionOlder version "7.3") [ "--with-pcre-regex=${pcre'.dev}" ]
      ++ optionals (versions.majorMinor version == "7.3") [ "--with-pcre-regex=${pcre'.dev}" ]
      ++ optionals (versionAtLeast version "7.4") [ "--with-external-pcre=${pcre'.dev}" ]
      ++ [ "PCRE_LIBDIR=${pcre'}" ]

      # Enable sapis
      ++ optional apxs2Support "--with-apxs2=${apacheHttpd.dev}/bin/apxs"
      ++ optional (!cgiSupport) "--disable-cgi"
      ++ optional (!cliSupport) "--disable-cli"
      ++ optional embedSupport "--enable-embed"
      ++ optional fpmSupport "--enable-fpm"
      ++ optional phpdbgSupport "--enable-phpdbg"
      ++ optional (!phpdbgSupport) "--disable-phpdbg"

      # Misc flags
      ++ optional argon2Support "--with-password-argon2=${libargon2}"
      ++ optional cgotoSupport "--enable-re2c-cgoto"
      ++ optional (!ipv6Support) "--disable-ipv6"
      ++ optional (pearSupport && libxml2Support) "--with-pear"
      ++ optional systemdSupport "--with-fpm-systemd"
      ++ optional valgrindSupport "--with-valgrind=${valgrind.dev}"
      ++ optional (ztsSupport && (versionOlder version "8.0")) "--enable-maintainer-zts"
      ++ optional (ztsSupport && (versionAtLeast version "8.0")) "--enable-zts"

      # Sendmail
      ++ [ "PROG_SENDMAIL=${system-sendmail}/bin/sendmail" ]

      # Enable extensions only in 5.6
      ++ optional (mssqlSupport && !stdenv.isDarwin) "--with-mssql=${freetds}"

      # Enable Extensions in 5.6 and higher
      ++ optional bcmathSupport "--enable-bcmath"
      ++ optional bz2Support "--with-bz2=${bzip2.dev}"
      ++ optional calendarSupport "--enable-calendar"
      ++ optional curlSupport "--with-curl=${curl.dev}"
      ++ optional exifSupport "--enable-exif"
      ++ optional ftpSupport "--enable-ftp"
      ++ optionals (gdSupport && versionOlder version "7.4") [
        "--with-gd=${gd.dev}"
        (if (versionAtLeast version "7.0") then "--with-webp-dir=${libwebp}" else null)
        "--with-jpeg-dir=${libjpeg.dev}"
        "--with-png-dir=${libpng.dev}"
        "--with-freetype-dir=${freetype.dev}"
        "--with-xpm-dir=${libXpm.dev}"
        "--enable-gd-jis-conv"
      ]
      ++ optionals (gdSupport && versionAtLeast version "7.4") [
        "--enable-gd"
        "--with-external-gd=${gd.dev}"
        (if (versionAtLeast version "8.1") then "--with-avif=${libavif}" else null)
        "--with-webp=${libwebp}"
        "--with-jpeg=${libjpeg.dev}"
        "--with-xpm=${libXpm.dev}"
        "--with-freetype=${freetype.dev}"
        "--enable-gd-jis-conv"
      ]
      ++ optional gettextSupport "--with-gettext=${gettext}"
      ++ optional gmpSupport "--with-gmp=${gmp.dev}"
      ++ optional mhashSupport "--with-mhash"
      ++ optional (iconvSupport && stdenv.isDarwin) "--with-iconv=${libiconv}"
      ++ optional (!iconvSupport) "--without-iconv"
      ++ optionals imapSupport [
        "--with-imap=${uwimap}"
        "--with-imap-ssl"
      ]
      ++ optional intlSupport "--enable-intl"
      ++ optionals ldapSupport [
        "--with-ldap=/invalid/path"
        "LDAP_DIR=${openldap.dev}"
        "LDAP_INCDIR=${openldap.dev}/include"
        "LDAP_LIBDIR=${openldap.out}/lib"
      ]
      ++ optional (ldapSupport && stdenv.isLinux) "--with-ldap-sasl=${cyrus_sasl.dev}"
      ++ optional (libxml2Support && (versionOlder version "7.4")) "--with-libxml-dir=${libxml2.dev}"
      ++ optional (!libxml2Support) [
        "--disable-dom"
        (if (versionOlder version "7.4") then "--disable-libxml" else "--without-libxml")
        "--disable-simplexml"
        "--disable-xml"
        "--disable-xmlreader"
        "--disable-xmlwriter"
        "--without-pear"
      ]
      ++ optional mbstringSupport "--enable-mbstring"
      ++ optional mcryptSupport "--with-mcrypt=${libmcrypt'}"
      ++ optional (mysqliSupport && mysqlndSupport) "--with-mysqli=mysqlnd"
      ++ optional opensslSupport "--with-openssl"
      ++ optional pcntlSupport "--enable-pcntl"
      ++ optional (pdo_mysqlSupport && mysqlndSupport) "--with-pdo-mysql=mysqlnd"
      ++ optional (pdo_mysqlSupport || mysqliSupport) "--with-mysql-sock=/run/mysqld/mysqld.sock"
      ++ optional pdo_odbcSupport "--with-pdo-odbc=unixODBC,${unixODBC}"
      ++ optional pdo_pgsqlSupport "--with-pdo-pgsql=${postgresql}"
      ++ optional sqliteSupport "--with-pdo-sqlite=${sqlite.dev}"
      ++ optional pgsqlSupport "--with-pgsql=${postgresql}"
      ++ optional (!pharSupport) "--disable-phar"
      ++ optional readlineSupport "--with-readline=${readline.dev}"
      ++ optional soapSupport "--enable-soap"
      ++ optional socketsSupport "--enable-sockets"
      ++ optional tidySupport "--with-tidy=${html-tidy}"
      ++ optional xmlrpcSupport "--with-xmlrpc"
      ++ optional xslSupport "--with-xsl=${libxslt.dev}"
      ++ optional (zipSupport && (versionOlder version "7.4")) "--enable-zip"
      ++ optional (zipSupport && (versionAtLeast version "7.4")) "--with-zip"
      ++ optional (libzipSupport && (versionOlder version "7.4")) "--with-libzip=${libzip.dev}"
      ++ optional zlibSupport "--with-zlib=${zlib.dev}"

      # Enable extensions in 7.2 and higher
      ++ optional sodiumSupport "--with-sodium=${libsodium.dev}";

      hardeningDisable = [ "bindnow" ];

      postPatch = ''
        # Don't record the configure flags since this causes unnecessary runtime dependencies
        for i in main/build-defs.h.in scripts/php-config.in; do
          substituteInPlace $i \
            --replace '@CONFIGURE_COMMAND@' '(omitted)' \
            --replace '@CONFIGURE_OPTIONS@' "" \
            --replace '@PHP_LDFLAGS@' ""
        done

        substituteInPlace ./build/libtool.m4 --replace "/usr/bin/file" "${file}/bin/file"
      '' + optionalString (versionOlder version "7.4") ''
        # https://bugs.php.net/bug.php?id=79159
        substituteInPlace ./acinclude.m4 --replace "AC_PROG_YACC" "AC_CHECK_PROG(YACC, bison, bison)"
      '' + optionalString stdenv.isDarwin ''
        substituteInPlace ./configure --replace "-lstdc++" "-lc++"
      '';

      preConfigure = ''
        export EXTENSION_DIR=$out/lib/php/extensions
      '' + optionalString (versionOlder version "7.4") ''
        ./buildconf --copy --force
        ./genfiles
      '' + optionalString (versionAtLeast version "7.4") ''
        ./buildconf --force
        ./scripts/dev/genfiles
      '';

      preInstall = lib.optionalString pearSupport ''
        cp ${php-pearweb-phars}/install-pear-nozlib.phar $TMPDIR/php-src-${version}/pear/install-pear-nozlib.phar
      '';

      postFixup = ''
        cp php.ini-production $out/etc/php.ini
        mkdir -p $dev/bin $dev/share/man/man1
        mv $out/bin/phpize $out/bin/php-config $dev/bin/
        mv $out/share/man/man1/phpize.1.gz \
           $out/share/man/man1/php-config.1.gz \
           $dev/share/man/man1/
      '';

      src = fetchFromGitHub {
        name = "php-src-${version}";
        owner = "php";
        repo = "php-src";
        rev = "php-${version}";
        inherit sha256;
      };

      patches = if !php7 then [ ./patch/fix-paths-php5.patch ] else [ ./patch/fix-paths-php7.patch ] ++ extraPatches;

      separateDebugInfo = true;

      outputs = [ "out" "dev" ];

      meta = with lib; {
        description = "An HTML-embedded scripting language";
        homepage = "https://www.php.net/";
        license = licenses.php301;
        maintainers = with maintainers; [ globin etu ];
        platforms = platforms.all;
        outputsToInstall = [ "out" "dev" ];
      };
    };

in {
  php56 = generic {
    version = "5.6.40";
    sha256 = "0svjffwnwvvvsg5ja24v4kpfyycs5f8zqnc2bbmgm968a0vdixn2";

    extraPatches = [
      # PKG_CONFIG need not be a relative path
      ./patch/fix-paths-pkgconfig-php56.patch
      # mysqlnd fix patch for MariaDB
      ./patch/php56/php5640-mysqlnd-fix.patch
      # Added sqlite3.defensive INI directive
      ./patch/php56/php5640-sqlite3-defensive.patch
      # Openssl cert updates
      ./patch/php56/php5640-php-openssl-cert.patch
      # Backport security bug patches
      ./patch/php56/php5640-75457.patch
      ./patch/php56/php5640-76488.patch
      ./patch/php56/php5640-76846.patch
      ./patch/php56/php5640-77423.patch
      ./patch/php56/php5640-77540.patch
      ./patch/php56/php5640-77563.patch
      ./patch/php56/php5640-77630.patch
      ./patch/php56/php5640-77753.patch
      ./patch/php56/php5640-77831.patch
      ./patch/php56/php5640-77919.patch
      ./patch/php56/php5640-77950.patch
      ./patch/php56/php5640-77967.patch
      ./patch/php56/php5640-77988.patch
      ./patch/php56/php5640-78069.patch
      ./patch/php56/php5640-78222.patch
      ./patch/php56/php5640-78256.patch
      ./patch/php56/php5640-78380.patch
      ./patch/php56/php5640-78599.patch
      ./patch/php56/php5640-78793.patch
      ./patch/php56/php5640-78862.patch
      ./patch/php56/php5640-78863.patch
      ./patch/php56/php5640-78875.patch
      ./patch/php56/php5640-78878.patch
      ./patch/php56/php5640-78910.patch
      ./patch/php56/php5640-79037.patch
      ./patch/php56/php5640-79082.patch
      ./patch/php56/php5640-79099.patch
      ./patch/php56/php5640-79221.patch
      ./patch/php56/php5640-79282.patch
      ./patch/php56/php5640-79329.patch
      ./patch/php56/php5640-79330.patch
      ./patch/php56/php5640-79465.patch
      ./patch/php56/php5640-79699.patch
      ./patch/php56/php5640-79797.patch
      ./patch/php56/php5640-79877.patch
      ./patch/php56/php5640-79971.patch
      ./patch/php56/php5640-80672.patch
      ./patch/php56/php5640-80710.patch
      ./patch/php56/php5640-81026.patch
      ./patch/php56/php5640-81122.patch
      ./patch/php56/php5640-81211.patch
      ./patch/php56/php5640-81719.patch
      ./patch/php56/php5640-81720.patch
    ];
  };

  php71 = generic {
    version = "7.1.33";
    sha256 = "1lz90pyvqxwmi7z2pgr8zc05hss11m61xaqy4d86wh80yra3m5rg";

    # https://bugs.php.net/bug.php?id=76826
    extraPatches = [
      # PKG_CONFIG need not be a relative path
      ./patch/fix-paths-pkgconfig-php71.patch
      # mysqlnd fix patch for MariaDB
      ./patch/php71/php7133-mysqlnd-fix.patch
      # Openssl cert updates
      ./patch/php71/php7133-php-openssl-cert.patch
      # Backport security bug patches
      ./patch/php71/php7133-76452.patch
      ./patch/php71/php7133-77423.patch
      ./patch/php71/php7133-77569.patch
      ./patch/php71/php7133-78793.patch
      ./patch/php71/php7133-78862.patch
      ./patch/php71/php7133-78863.patch
      ./patch/php71/php7133-78875.patch
      ./patch/php71/php7133-78876.patch
      ./patch/php71/php7133-78878.patch
      ./patch/php71/php7133-78910.patch
      ./patch/php71/php7133-79037.patch
      ./patch/php71/php7133-79082.patch
      ./patch/php71/php7133-79091.patch
      ./patch/php71/php7133-79099.patch
      ./patch/php71/php7133-79221.patch
      ./patch/php71/php7133-79282.patch
      ./patch/php71/php7133-79329.patch
      ./patch/php71/php7133-79330.patch
      ./patch/php71/php7133-79465.patch
      ./patch/php71/php7133-79601.patch
      ./patch/php71/php7133-79699.patch
      ./patch/php71/php7133-79797.patch
      ./patch/php71/php7133-79877.patch
      ./patch/php71/php7133-79971.patch
      ./patch/php71/php7133-80672.patch
      ./patch/php71/php7133-80710.patch
      ./patch/php71/php7133-81026.patch
      ./patch/php71/php7133-81122.patch
      ./patch/php71/php7133-81211.patch
      ./patch/php71/php7133-81719.patch
      ./patch/php71/php7133-81720.patch
    ] 
      # https://bugs.php.net/bug.php?id=76826
      ++ optional stdenv.isDarwin ./patch/php71-darwin-isfinite.patch;
  };

  php72 = generic {
    version = "7.2.34";
    sha256 = "1v3m0krif0f4146hrn3cra78g1pagwmcwmg4lfdvm9rfynf4qkjj";

    extraPatches = [
      # PKG_CONFIG need not be a relative path
      ./patch/fix-paths-pkgconfig-php72.patch
      # mysqlnd fix patch for MariaDB
      ./patch/php72/php72-mysqlnd-fix.patch
      # Backport security bug patches
      ./patch/php72/php7234-76452.patch
      ./patch/php72/php7234-77423.patch
      ./patch/php72/php7234-79971.patch
      ./patch/php72/php7234-80672.patch
      ./patch/php72/php7234-80710.patch
      ./patch/php72/php7234-81026.patch
      ./patch/php72/php7234-81122.patch
      ./patch/php72/php7234-81211.patch
      ./patch/php72/php7234-81719.patch
      ./patch/php72/php7234-81720.patch
    ]
      # https://bugs.php.net/bug.php?id=76826
      ++ optional stdenv.isDarwin ./patch/php72-darwin-isfinite.patch;
  };

  php73 = generic {
    version = "7.3.33";
    sha256 = "sha256-wES+R9Mp384hoAYmDaA8X/KodeqOufF5WEf+0m1Ypz4=";

    extraPatches = [
      # PKG_CONFIG need not be a relative path
      ./patch/fix-paths-pkgconfig-php73.patch
      # Fix for pcre2 10.38
      ./patch/php73/php7331-pcre1038.patch
      # Backport security bug patches
      ./patch/php73/php7331-81719.patch
      ./patch/php73/php7331-81720.patch
    ]
      # https://bugs.php.net/bug.php?id=76826
      ++ optional stdenv.isDarwin ./patch/php73-darwin-isfinite.patch;
  };

  php74 = generic {
    version = "7.4.30";
    sha256 = "sha256-qF30+STnI4iW2nCL+jCJPAiPq/dahyL8BuESzsTzBbk=";
  };

  php80 = generic {
    version = "8.0.20";
    sha256 = "sha256-LXNadNMKjuzGFvHGyRPLDbEJ1jo9aAqwd8BDUpfA2Qk=";
  };

  php81 = generic {
    version = "8.1.7";
    sha256 = "sha256-gztwTpDbTzGdiRZoyylYNz5GOD+OjFCx7fXVFMyk1yE=";
  };
}
