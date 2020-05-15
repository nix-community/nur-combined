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

      CXXFLAGS = optionalString stdenv.cc.isClang "-std=c++11";

      configureFlags = [
        "--with-config-file-scan-dir=/etc/php.d"
      ]
      ++ optionals (versionOlder version "7.3") [ "--with-pcre-regex=${pcre.dev}" "PCRE_LIBDIR=${pcre}" ]
      ++ optionals (versions.majorMinor version == "7.3") [ "--with-pcre-regex=${pcre2.dev}" "PCRE_LIBDIR=${pcre2}" ]
      ++ optionals (versionAtLeast version "7.4") [ "--with-external-pcre=${pcre2.dev}" "PCRE_LIBDIR=${pcre2}" ]
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
      ++ optional (ldapSupport && stdenv.isLinux) "--with-ldap-sasl=${cyrus_sasl.dev}"
      ++ optional apxs2Support "--with-apxs2=${apacheHttpd.dev}/bin/apxs"
      ++ optional embedSupport "--enable-embed"
      ++ optional mhashSupport "--with-mhash"
      ++ optional curlSupport "--with-curl=${curl.dev}"
      ++ optional zlibSupport "--with-zlib=${zlib.dev}"
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
      ++ optionals (gdSupport && versionAtLeast version "7.4") [
        "--enable-gd"
        "--with-external-gd=${gd.dev}"
        "--with-webp=${libwebp}"
        "--with-jpeg=${libjpeg.dev}"
        "--with-xpm=${libXpm.dev}"
        "--with-freetype=${freetype.dev}"
        "--enable-gd-jis-conv"
      ] ++ optionals (gdSupport && versionOlder version "7.4") [
        "--with-gd=${gd.dev}"
        (if (versionAtLeast version "7.0") then "--with-webp-dir=${libwebp}" else null)
        "--with-jpeg-dir=${libjpeg.dev}"
        "--with-png-dir=${libpng.dev}"
        "--with-freetype-dir=${freetype.dev}"
        "--with-xpm-dir=${libXpm.dev}"
        "--enable-gd-jis-conv"
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
      ++ optional (zipSupport && (versionAtLeast version "7.4")) "--with-zip"
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
    sha256 = "0jsgiwawlais8s1l38lz51h1x2ci5ildk0ksfdmkg6xpwbrfb9cm";

    # https://bugs.php.net/bug.php?id=76826
    extraPatches = [
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
    sha256 = "0057x1s43f9jidmrl8daka6wpxclxc1b1pm5cjbz616p8nbmb9qv";

    # https://bugs.php.net/bug.php?id=76826
    extraPatches = optional stdenv.isDarwin ./patch/php72-darwin-isfinite.patch;
  };

  php73 = generic {
    version = "7.3.18";
    sha256 = "19787fjz3p195dhq0bk7dcn76m6vyl2ng12zawxiamzbbpv237bl";

    # https://bugs.php.net/bug.php?id=76826
    extraPatches = optional stdenv.isDarwin ./patch/php73-darwin-isfinite.patch;
  };

  php74 = generic {
    version = "7.4.6";
    sha256 = "0j133pfwa823d4jhx2hkrrzjl4hswvz00b1z58r5c82xd5sr9vd6";
  };
}
