{ config, lib, stdenv, fetchFromGitHub
, autoconf, automake, file, flex, libtool, pkgconfig, re2c
, bison2, bison, php-pearweb-phars
, apacheHttpd, libargon2, systemd, valgrind
, freetds, bzip2, curl, openssl
, gd, freetype, libXpm, libjpeg, libpng, libwebp
, gettext, gmp, libiconv, uwimap, pam, icu60, icu
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
  , iconvSupport ? (config.php.iconv or true) && (versionOlder version "8.0")
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
      icu' = if (versionAtLeast version "7.0") then icu else icu60;

    in stdenv.mkDerivation {

      inherit version;

      pname = "php";

      enableParallelBuilding = true;

      nativeBuildInputs = [
        autoconf automake file flex libtool pkgconfig re2c
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
      ++ optional (pearSupport && libxml2Support) "--with-pear=$(out)/lib/php/pear"
      ++ optional systemdSupport "--with-fpm-systemd"
      ++ optional valgrindSupport "--with-valgrind=${valgrind.dev}"
      ++ optional (ztsSupport && (versionOlder version "8.0")) "--enable-maintainer-zts"
      ++ optional (ztsSupport && (versionAtLeast version "8.0")) "--enable-zts"

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
      ++ optional sodiumSupport "--with-sodium=${libsodium.dev}"

      # Disable extensions in 8.0
      ++ optional (versionAtLeast version "8.0") "--without-iconv";

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
        rev = (if (versionAtLeast version "8.0") then "${rev}" else "php-${version}");
        inherit sha256;
      };

      patches = if !php7 then [ ./patch/fix-paths-php5.patch ] else [ ./patch/fix-paths-php7.patch ] ++ extraPatches;

      separateDebugInfo = true;

      outputs = [ "out" "dev" ];

      meta = with stdenv.lib; {
        description = "An HTML-embedded scripting language";
        homepage = https://www.php.net/;
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
     ./patch/fix-paths-pkgconfig-php56.patch # PKG_CONFIG need not be a relative path
     ./patch/php56/php5640-75457.patch # https://bugs.php.net/bug.php?id=75457
     ./patch/php56/php5640-76846.patch # https://bugs.php.net/bug.php?id=76846
     ./patch/php56/php5640-77540.patch # https://bugs.php.net/bug.php?id=77540
     ./patch/php56/php5640-77563.patch # https://bugs.php.net/bug.php?id=77563
     ./patch/php56/php5640-77630.patch # https://bugs.php.net/bug.php?id=77630
     ./patch/php56/php5640-77753.patch # https://bugs.php.net/bug.php?id=77753
     ./patch/php56/php5640-77831.patch # https://bugs.php.net/bug.php?id=77831
     ./patch/php56/php5640-77919.patch # https://bugs.php.net/bug.php?id=77919
     ./patch/php56/php5640-77950.patch # https://bugs.php.net/bug.php?id=77950
     ./patch/php56/php5640-77967.patch # https://bugs.php.net/bug.php?id=77967
     ./patch/php56/php5640-77988.patch # https://bugs.php.net/bug.php?id=77988
     ./patch/php56/php5640-78069.patch # https://bugs.php.net/bug.php?id=78069
     ./patch/php56/php5640-78222.patch # https://bugs.php.net/bug.php?id=78222
     ./patch/php56/php5640-78256.patch # https://bugs.php.net/bug.php?id=78256
     ./patch/php56/php5640-78380.patch # https://bugs.php.net/bug.php?id=78380
     ./patch/php56/php5640-78599.patch # https://bugs.php.net/bug.php?id=78599
     ./patch/php56/php5640-78793.patch # https://bugs.php.net/bug.php?id=78793
     ./patch/php56/php5640-78862.patch # https://bugs.php.net/bug.php?id=78862
     ./patch/php56/php5640-78863.patch # https://bugs.php.net/bug.php?id=78863
     ./patch/php56/php5640-78878.patch # https://bugs.php.net/bug.php?id=78878
     ./patch/php56/php5640-78910.patch # https://bugs.php.net/bug.php?id=78910
     ./patch/php56/php5640-79037.patch # https://bugs.php.net/bug.php?id=79037
     ./patch/php56/php5640-79082.patch # https://bugs.php.net/bug.php?id=79082
     ./patch/php56/php5640-79099.patch # https://bugs.php.net/bug.php?id=79099
     ./patch/php56/php5640-79221.patch # https://bugs.php.net/bug.php?id=79221
     ./patch/php56/php5640-79282.patch # https://bugs.php.net/bug.php?id=79282
     ./patch/php56/php5640-79329.patch # https://bugs.php.net/bug.php?id=79329
     ./patch/php56/php5640-php-openssl-cert.patch # Openssl cert updates
     ./patch/php56/php5640-sqlite3-defensive.patch # Added sqlite3.defensive INI directive
    ];
  };

  php71 = generic {
    version = "7.1.33";
    sha256 = "1lz90pyvqxwmi7z2pgr8zc05hss11m61xaqy4d86wh80yra3m5rg";

    # https://bugs.php.net/bug.php?id=76826
    extraPatches = [
      ./patch/fix-paths-pkgconfig-php71.patch # PKG_CONFIG need not be a relative path
      ./patch/php71/php7133-77569.patch # https://bugs.php.net/bug.php?id=77569
      ./patch/php71/php7133-78793.patch # https://bugs.php.net/bug.php?id=78793
      ./patch/php71/php7133-78862.patch # https://bugs.php.net/bug.php?id=78862
      ./patch/php71/php7133-78863.patch # https://bugs.php.net/bug.php?id=78863
      ./patch/php71/php7133-78878.patch # https://bugs.php.net/bug.php?id=78878
      ./patch/php71/php7133-78910.patch # https://bugs.php.net/bug.php?id=78910
      ./patch/php71/php7133-79037.patch # https://bugs.php.net/bug.php?id=79037
      ./patch/php71/php7133-79082.patch # https://bugs.php.net/bug.php?id=79082
      ./patch/php71/php7133-79091.patch # https://bugs.php.net/bug.php?id=79091
      ./patch/php71/php7133-79099.patch # https://bugs.php.net/bug.php?id=79099
      ./patch/php71/php7133-79221.patch # https://bugs.php.net/bug.php?id=79221
      ./patch/php71/php7133-79282.patch # https://bugs.php.net/bug.php?id=79282
      ./patch/php71/php7133-79329.patch # https://bugs.php.net/bug.php?id=79329
      ./patch/php71/php7133-php-openssl-cert.patch # Openssl cert updates
    ] 
      # https://bugs.php.net/bug.php?id=76826
      ++ optional stdenv.isDarwin ./patch/php71-darwin-isfinite.patch;
  };

  php72 = generic {
    version = "7.2.31";
    sha256 = "1z7h3j343x0k2y5ji7vv6rmim98kgz950mvd6nys5rvcq2a89pj5";

    extraPatches = [
      ./patch/fix-paths-pkgconfig-php72.patch # PKG_CONFIG need not be a relative path
    ]
      # https://bugs.php.net/bug.php?id=76826
      ++ optional stdenv.isDarwin ./patch/php72-darwin-isfinite.patch;
  };

  php73 = generic {
    version = "7.3.19";
    sha256 = "1vcx5as2wl1wz5hg1fg78l4ixfwhsf7znr7vrs0avljcibv843vc";

    extraPatches = [
      ./patch/fix-paths-pkgconfig-php73.patch # PKG_CONFIG need not be a relative path
    ]
      # https://bugs.php.net/bug.php?id=76826
      ++optional stdenv.isDarwin ./patch/php73-darwin-isfinite.patch;
  };

  php74 = generic {
    version = "7.4.7";
    sha256 = "0hgf6671wlpm8l14l14dig5mp3kb3daraidds4pza2l4q7lvyb9b";
  };

  php80 = generic {
    version = "8.0.0-dev-2020.06.03";
    rev = "698bd59fb53ac5132600f9df242c715d01002033";
    sha256 = "15a8favlhzvr51pa0h94flnnw5rwiz82j0q027yaczdp69a1p95i";
  };
}
