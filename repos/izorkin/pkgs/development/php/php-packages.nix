{ pkgs, fetchgit, php, openssl, libevent, libcouchbase }:

let
  self = with self; {
    buildPecl = import ./build-pecl.nix {
      inherit php;
      inherit (pkgs) stdenv autoreconfHook fetchurl file re2c;
    };

    # Wrap mkDerivation to prepend pname with "php-" to make names consistent
    # with how buildPecl does it and make the file easier to overview.
    mkDerivation = { pname, ... }@args: pkgs.stdenv.mkDerivation (args // {
      pname = "php-${pname}";
    });

    isPhp56 = pkgs.lib.versionOlder   php.version "7.0";
    isPhp71 = pkgs.lib.versionAtLeast php.version "7.1";
    isPhp72 = pkgs.lib.versionAtLeast php.version "7.2";
    isPhp73 = pkgs.lib.versionAtLeast php.version "7.3";
    isPhp74 = pkgs.lib.versionAtLeast php.version "7.4";
    isPhp80 = pkgs.lib.versionAtLeast php.version "8.0";

  apcu = if isPhp56 then apcu40 else apcu51;

  apcu40 = buildPecl {
    version = "4.0.11";
    pname = "apcu";

    sha256 = "002d1gklkf0z170wkbhmm2z1p9p5ghhq3q1r9k54fq1sq4p30ks5";

    buildInputs = with pkgs; [ pcre.dev ];

    meta.broken = !isPhp56;
  };

  apcu51 = buildPecl {
    version = "5.1.19";
    pname = "apcu";

    sha256 = "1q3c4y9jqh1yz5vps2iiz2x04vn0y1g5ibxg1x8zp7n7sncvqzw3";

    buildInputs = with pkgs; [ (if isPhp73 then pcre2.dev else pcre.dev) ];
    doCheck = true;
    checkTarget = "test";
    checkFlagsArray = ["REPORT_EXIT_STATUS=1" "NO_INTERACTION=1"];
    makeFlags = [ "phpincludedir=$(dev)/include" ];
    outputs = [ "out" "dev" ];

    meta.broken = isPhp56;
  };

  apcu_bc = buildPecl {
    version = "1.0.5";
    pname = "apcu_bc";

    sha256 = "0ma00syhk2ps9k9p02jz7rii6x3i2p986il23703zz5npd6y9n20";

    buildInputs = with pkgs; [ apcu (if isPhp73 then pcre2.dev else pcre.dev) ];

    meta.broken = (isPhp56 || isPhp80);
  };

  ast = buildPecl {
    version = "1.0.10";
    pname = "ast";

    sha256 = "13s5r1szd80g1mqickghdd38mvjkwss221322mmbrykcfgp4fs30";

    meta.broken = (isPhp56 || isPhp80);
  };

  box = mkDerivation rec {
    version = "2.7.5";
    pname = "box";

    src = pkgs.fetchurl {
      url = "https://github.com/box-project/box2/releases/download/${version}/box-${version}.phar";
      sha256 = "1zmxdadrv0i2l8cz7xb38gnfmfyljpsaz2nnkjzqzksdmncbgd18";
    };

    phases = [ "installPhase" ];
    nativeBuildInputs = with pkgs; [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      install -D $src $out/libexec/box/box.phar
      makeWrapper ${php}/bin/php $out/bin/box \
        --add-flags "-d phar.readonly=0 $out/libexec/box/box.phar"
    '';

    meta = with pkgs.lib; {
      description = "An application for building and managing Phars";
      license = licenses.mit;
      homepage = "https://box-project.github.io/box2/";
      maintainers = with maintainers; [ jtojnar ];
    };
  };

  composer = mkDerivation rec {
    version = "1.10.20";
    pname = "composer";

    src = pkgs.fetchurl {
      url = "https://getcomposer.org/download/${version}/composer.phar";
      sha256 = "139lf60my7gm7rxj67jwwknj1rhwa7njdpbm4aq7vq4lq4j102z7";
    };

    dontUnpack = true;

    nativeBuildInputs = with pkgs; [ makeWrapper ];

    installPhase = with pkgs; ''
      mkdir -p $out/bin
      install -D $src $out/libexec/composer/composer.phar
      makeWrapper ${php}/bin/php $out/bin/composer \
        --add-flags "$out/libexec/composer/composer.phar" \
        --prefix PATH : ${lib.makeBinPath [ unzip ]}
    '';

    meta = with pkgs.lib; {
      description = "Dependency Manager for PHP";
      license = licenses.mit;
      homepage = "https://getcomposer.org/";
      maintainers = with maintainers; [ globin offline ];
    };
  };

  composer2 = mkDerivation rec {
    version = "2.0.9";
    pname = "composer";

    src = pkgs.fetchurl {
      url = "https://getcomposer.org/download/${version}/composer.phar";
      sha256 = "1k7rp77jqz045jzgl3l5r3wnss5hnpxk66m2x4r9yfbyh2yabyi4";
    };

    dontUnpack = true;

    nativeBuildInputs = with pkgs; [ makeWrapper ];

    installPhase = with pkgs; ''
      mkdir -p $out/bin
      install -D $src $out/libexec/composer/composer.phar
      makeWrapper ${php}/bin/php $out/bin/composer \
        --add-flags "$out/libexec/composer/composer.phar" \
        --prefix PATH : ${lib.makeBinPath [ unzip ]}
    '';

    meta = with pkgs.lib; {
      description = "Dependency Manager for PHP";
      license = licenses.mit;
      homepage = "https://getcomposer.org/";
      maintainers = with maintainers; [ globin offline ];
    };
  };

  couchbase = buildPecl rec {
    version = "2.6.2";
    pname = "couchbase";

    buildInputs = with pkgs; [ libcouchbase zlib igbinary pcs ];

    src = pkgs.fetchFromGitHub {
      owner = "couchbase";
      repo = "php-couchbase";
      rev = "v${version}";
      sha256 = "0ymrymnz91qg9b2ns044qg46wc65dffhxx402wpx1b5cj2vr4ma3";
    };

    configureFlags = [ "--with-couchbase" ];

    patches = with pkgs; [
      (pkgs.writeText "php-couchbase.patch" ''
        --- a/config.m4
        +++ b/config.m4
        @@ -9,7 +9,7 @@ if test "$PHP_COUCHBASE" != "no"; then
             LIBCOUCHBASE_DIR=$PHP_COUCHBASE
           else
             AC_MSG_CHECKING(for libcouchbase in default path)
        -    for i in /usr/local /usr; do
        +    for i in ${libcouchbase}; do
               if test -r $i/include/libcouchbase/couchbase.h; then
                 LIBCOUCHBASE_DIR=$i
                 AC_MSG_RESULT(found in $i)
        @@ -154,6 +154,8 @@ COUCHBASE_FILES=" \
             igbinary_inc_path="$phpincludedir"
           elif test -f "$phpincludedir/ext/igbinary/igbinary.h"; then
             igbinary_inc_path="$phpincludedir"
        +  elif test -f "${igbinary.dev}/include/ext/igbinary/igbinary.h"; then
        +    igbinary_inc_path="${igbinary.dev}/include"
           fi
           if test "$igbinary_inc_path" = ""; then
             AC_MSG_WARN([Cannot find igbinary.h])
      '')
    ];

    meta.broken = isPhp74;
  };

  geoip = buildPecl {
    version = "1.1.1";
    pname = "geoip";

    sha256 = "01hgijn91an7gf0fva5fk3paag6lvfh7ynlv4if16ilx041mrl5j";

    configureFlags = with pkgs; [
      "--with-geoip=${geoip}"
    ];

    buildInputs = with pkgs; [ geoip ];

    meta.broken = isPhp80;
  };

  event = buildPecl {
    version = "3.0.2";
    pname = "event";

    sha256 = "1ws4l014z52vb23xbsfj6viwkf7fmh462af639xgbp0n6syf77dq";

    configureFlags = with pkgs; [
      "--with-event-libevent-dir=${libevent.dev}"
      "--with-event-core"
      "--with-event-extra"
      "--with-event-pthreads"
    ];

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [ openssl libevent ];

    meta = with pkgs.lib; {
      description = ''
        This is an extension to efficiently schedule I/O, time and signal based
        events using the best I/O notification mechanism available for specific platform.
      '';
      license = licenses.php301;
      homepage = "https://bitbucket.org/osmanov/pecl-event/";
    };
  };

  igbinary = if isPhp56 then igbinary20 else igbinary30;

  igbinary20 = buildPecl {
    version = "2.0.8";
    pname = "igbinary";

    sha256 = "105nyn703k9p9c7wwy6npq7xd9mczmmlhyn0gn2v2wz0f88spjxs";

    configureFlags = [
      "--enable-igbinary"
    ];

    makeFlags = [ "phpincludedir=$(dev)/include" ];
    outputs = [ "out" "dev" ];

    meta.broken = !isPhp56;
  };

  igbinary30 = buildPecl {
    version = "3.2.1";
    pname = "igbinary";

    sha256 = "1nskazizh9mz0q1dr2n1kq17y964p1lhb70942b5agivzp7j05k0";

    configureFlags = [
      "--enable-igbinary"
    ];

    makeFlags = [ "phpincludedir=$(dev)/include" ];
    outputs = [ "out" "dev" ];

    meta.broken = isPhp56;
  };

  imagick = buildPecl {
    version = "3.4.4";
    pname = "imagick";

    sha256 = "0xvhaqny1v796ywx83w7jyjyd0nrxkxf34w9zi8qc8aw8qbammcd";

    configureFlags = with pkgs; [
      "--with-imagick=${imagemagick.dev}"
    ];

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [ (if isPhp73 then pcre2.dev else pcre.dev) ];

    meta.broken = isPhp80;
  };

  mailparse = buildPecl {
    version = "3.1.1";
    pname = "mailparse";

    sha256 = "02nfjbgyjbr48rw6r46gd713hkxh7nghg2rcbr726zhzz182c3y7";

    meta.broken = isPhp56;
  };

  mcrypt = buildPecl {
    version = "1.0.4";
    pname = "mcrypt";

    sha256 = "03d09rzfx06jfg1dgchc3898gjbfq71izznws3f4hyldjmw3w5cq";

    configureFlags = with pkgs; [
      "--with-mcrypt=${libmcrypt}"
    ];

    buildInputs = with pkgs; [ libmcrypt ];

    meta.broken = !isPhp72;
  };

  memcache = if isPhp56 then memcache30 else (if isPhp80 then memcache80 else memcache40);

  memcache30 = buildPecl {
    version = "3.0.8";
    pname = "memcache";

    sha256 = "04c35rj0cvq5ygn2jgmyvqcb0k8d03v4k642b6i37zgv7x15pbic";

    configureFlags = with pkgs; [
      "--with-zlib-dir=${zlib.dev}"
    ];

    makeFlags = [ "CFLAGS=-fgnu89-inline" ];

    meta.broken = !isPhp56;
  };

  memcache40 = buildPecl {
    version = "4.0.5.2";
    pname = "memcache";

    sha256 = "0qzdm71800rsdkivfjpam0sz4gz4974bwjqp3xkh785f7f0nfxkv";

    configureFlags = with pkgs; [
      "--with-zlib-dir=${zlib.dev}"
    ];

    buildInputs = with pkgs; [ zlib ];

    meta.broken = (isPhp56 || isPhp80);
  };

  memcache80 = buildPecl {
    version = "8.0";
    pname = "memcache";

    sha256 = "159krw2ha1fpy3rph4pjrcd56w0had5f359v52vq47c3yzk37zny";

    configureFlags = with pkgs; [
      "--with-zlib-dir=${zlib.dev}"
    ];

    buildInputs = with pkgs; [ zlib ];

    meta.broken = !isPhp80;
  };

  memcached = if isPhp56 then memcached22 else memcached31;

  memcached22 = buildPecl {
    version = "2.2.0";
    pname = "memcached";

    sha256 = "0n4z2mp4rvrbmxq079zdsrhjxjkmhz6mzi7mlcipz02cdl7n1f8p";

    configureFlags = with pkgs; [
      "--with-zlib-dir=${zlib.dev}"
      "--with-libmemcached-dir=${libmemcached}"
    ];

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [ cyrus_sasl zlib ];

    meta.broken = !isPhp56;
  };

  memcached31 = buildPecl rec {
    version = "3.1.5";
    pname = "memcached";

    src = fetchgit {
      url = "https://github.com/php-memcached-dev/php-memcached";
      rev = "v${version}";
      sha256 = "01mbh2m3kfbdvih3c8g3g9h4vdd80r0i9g2z8b3lx3mi8mmcj380";
    };

    configureFlags = with pkgs; [
      "--with-zlib-dir=${zlib.dev}"
      "--with-libmemcached-dir=${libmemcached}"
    ];

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [ cyrus_sasl zlib ];

    meta.broken = isPhp56;
  };

  mongodb = if isPhp56 then mongodb17 else mongodb19;

  mongodb17 = buildPecl {
    pname = "mongodb";
    version = "1.7.5";

    sha256 = "0yf3h70iqdk3b8va4i15la8whq8q91gip6crh9ibxs0aiihhg2p4";

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [
      cyrus_sasl
      icu
      openssl
      snappy
      zlib
      (if isPhp73 then pcre2.dev else pcre.dev)
    ] ++ lib.optional (stdenv.isDarwin) darwin.apple_sdk.frameworks.Security;

    meta.broken = isPhp71;
  };

  mongodb19 = buildPecl {
    pname = "mongodb";
    version = "1.9.0";

    sha256 = "16mbw3p80qxsj86nmjbfch8wv6jaq8wbz4rlpmixvhj9nwbp37hs";

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [
      cyrus_sasl
      icu
      openssl
      snappy
      zlib
      (if isPhp73 then pcre2.dev else pcre.dev)
    ] ++ lib.optional (stdenv.isDarwin) darwin.apple_sdk.frameworks.Security;

    meta.broken = isPhp56;
  };

  pcov = buildPecl {
    version = "1.0.6";
    pname = "pcov";

    sha256 = "1psfwscrc025z8mziq69pcx60k4fbkqa5g2ia8lplb94mmarj0v1";

    buildInputs = with pkgs; [ (if isPhp73 then pcre2.dev else pcre.dev) ];

    meta.broken = isPhp56;
  };

  pcs = buildPecl {
    version = "1.3.7";
    pname = "pcs";

    sha256 = "097676akx2p6wvc58py2fjc3bv2x760z1g6mv0kh4wx5wr4n9zdx";

    meta.broken = isPhp80;
  };

  pdo_sqlsrv = if !isPhp73 then pdo_sqlsrv58 else pdo_sqlsrv59;

  pdo_sqlsrv58 = buildPecl {
    version = "5.8.1";
    pname = "pdo_sqlsrv";

    sha256 = "06ba4x34fgs092qq9w62y2afsm1nyasqiprirk4951ax9v5vcir0";

    buildInputs = with pkgs; [ unixODBC ];

    meta.broken = (isPhp56 || isPhp73);
  };

  pdo_sqlsrv59 = buildPecl {
    version = "5.9.0";
    pname = "pdo_sqlsrv";

    sha256 = "0n4cnkldvyp1lrpj18ky2ii2dcaa51dsmh8cspixm7w76dxl3khg";

    buildInputs = with pkgs; [ unixODBC ];

    meta.broken = !isPhp73;
  };

  php-cs-fixer = mkDerivation rec {
    version = "2.18.2";
    pname = "php-cs-fixer";

    src = pkgs.fetchurl {
      url = "https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/v${version}/php-cs-fixer.phar";
      sha256 = "13dsy34r1j4yxnw843mxww7s887jvxb3ancqdyidvjxzadxmp7g3";
    };

    phases = [ "installPhase" ];
    nativeBuildInputs = with pkgs; [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      install -D $src $out/libexec/php-cs-fixer/php-cs-fixer.phar
      makeWrapper ${php}/bin/php $out/bin/php-cs-fixer \
        --add-flags "$out/libexec/php-cs-fixer/php-cs-fixer.phar"
    '';

    meta = with pkgs.lib; {
      description = "A tool to automatically fix PHP coding standards issues";
      license = licenses.mit;
      homepage = "https://cs.symfony.com/";
      maintainers = with maintainers; [ jtojnar ];
    };
  };

  php-parallel-lint = mkDerivation rec {
    version = "1.0.0";
    pname = "php-parallel-lint";

    src = pkgs.fetchFromGitHub {
      owner = "JakubOnderka";
      repo = "PHP-Parallel-Lint";
      rev = "v${version}";
      sha256 = "16nv8yyk2z3l213dg067l6di4pigg5rd8yswr5xgd18jwbys2vnw";
    };

    nativeBuildInputs = with pkgs; [ makeWrapper ];
    buildInputs = [ composer box ];

    buildPhase = ''
      composer dump-autoload
      box build
    '';

    installPhase = ''
      mkdir -p $out/bin
      install -D parallel-lint.phar $out/libexec/php-parallel-lint/php-parallel-lint.phar
      makeWrapper ${php}/bin/php $out/bin/php-parallel-lint \
        --add-flags "$out/libexec/php-parallel-lint/php-parallel-lint.phar"
    '';

    meta = with pkgs.lib; {
      description = "This tool check syntax of PHP files faster than serial check with fancier output";
      license = licenses.bsd2;
      homepage = "https://github.com/JakubOnderka/PHP-Parallel-Lint";
      maintainers = with maintainers; [ jtojnar ];
    };
  };

  phpcbf = mkDerivation rec {
    version = "3.5.8";
    pname = "phpcbf";

    src = pkgs.fetchurl {
      url = "https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${version}/phpcbf.phar";
      sha256 = "15ci30yvw3p9zlmzsk9s4mxzb3wax3gl9p55slhf1bzwn1xxwyb0";
    };

    phases = [ "installPhase" ];
    nativeBuildInputs = with pkgs; [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      install -D $src $out/libexec/phpcbf/phpcbf.phar
      makeWrapper ${php}/bin/php $out/bin/phpcbf \
        --add-flags "$out/libexec/phpcbf/phpcbf.phar"
    '';

    meta = with pkgs.lib; {
      description = "PHP coding standard beautifier and fixer";
      license = licenses.bsd3;
      homepage = "https://github.com/squizlabs/PHP_CodeSniffer";
      maintainers = with maintainers; [ cmcdragonkai etu ];
    };
  };

  phpcs = mkDerivation rec {
    version = "3.5.8";
    pname = "phpcs";

    src = pkgs.fetchurl {
      url = "https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${version}/phpcs.phar";
      sha256 = "037mdnpbgd9xaj556pf14h02a4a6f5zzdg58p2z1sivxcygf8aka";
    };

    phases = [ "installPhase" ];
    nativeBuildInputs = with pkgs; [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      install -D $src $out/libexec/phpcs/phpcs.phar
      makeWrapper ${php}/bin/php $out/bin/phpcs \
        --add-flags "$out/libexec/phpcs/phpcs.phar"
    '';

    meta = with pkgs.lib; {
      description = "PHP coding standard tool";
      license = licenses.bsd3;
      homepage = "https://github.com/squizlabs/PHP_CodeSniffer";
      maintainers = with maintainers; [ javaguirre etu ];
    };
  };

  phpstan = mkDerivation rec {
    version = "0.12.71";
    pname = "phpstan";

    src = pkgs.fetchurl {
      url = "https://github.com/phpstan/phpstan/releases/download/${version}/phpstan.phar";
      sha256 = "0lssq5fzvdfxcimkgi5p0zpsbsbaz6fwm7as5w40qsyknbgky82m";
    };

    phases = [ "installPhase" ];
    nativeBuildInputs = with pkgs; [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      install -D $src $out/libexec/phpstan/phpstan.phar
      makeWrapper ${php}/bin/php $out/bin/phpstan \
        --add-flags "$out/libexec/phpstan/phpstan.phar"
    '';

    meta = with pkgs.lib; {
      description = "PHP Static Analysis Tool";
      longDescription = ''
        PHPStan focuses on finding errors in your code without actually running
        it. It catches whole classes of bugs even before you write tests for the
        code. It moves PHP closer to compiled languages in the sense that the
        correctness of each line of the code can be checked before you run the
        actual line.
      '';
      license = licenses.mit;
      homepage = "https://github.com/phpstan/phpstan";
      maintainers = with maintainers; [ etu ];
    };
  };

  pinba = if isPhp56 then pinba110 else (if isPhp73 then pinba112 else pinba111 );

  pinba110 = buildPecl {
    version = "1.1.0";
    pname = "pinba";

    src = pkgs.fetchFromGitHub {
      owner = "tony2001";
      repo = "pinba_extension";
      rev = "7e7cd25ebcd74234f058bfe350128238383c6b96";
      sha256 = "1866c82ypijcm44sbfygfzs0d3klj7xsyc40imzac7s9x1x4fp81";
    };

    meta = with pkgs.lib; {
      description = "PHP extension for Pinba";
      longDescription = ''
        Pinba is a MySQL storage engine that acts as a realtime monitoring and
        statistics server for PHP using MySQL as a read-only interface.
      '';
      homepage = "http://pinba.org/";

      broken = !isPhp56;
    };
  };

  pinba111 = buildPecl {
    version = "1.1.1";
    pname = "pinba";

    src = pkgs.fetchFromGitHub {
      owner = "tony2001";
      repo = "pinba_extension";
      rev = "RELEASE_1_1_1";
      sha256 = "1kdp7vav0y315695vhm3xifgsh6h6y6pny70xw3iai461n58khj5";
    };

    meta = with pkgs.lib; {
      description = "PHP extension for Pinba";
      longDescription = ''
        Pinba is a MySQL storage engine that acts as a realtime monitoring and
        statistics server for PHP using MySQL as a read-only interface.
      '';
      homepage = "http://pinba.org/";

      broken = (isPhp56 || isPhp73);
    };
  };

  pinba112 = buildPecl {
    version = "1.1.2";
    pname = "pinba";

    src = pkgs.fetchFromGitHub {
      owner = "tony2001";
      repo = "pinba_extension";
      rev = "98c01fb5cde068426aae61d239205db75c507cbf";
      sha256 = "0wqcqq6sb51wiawa37hbd1h9dbvmyyndzdvz87xqji7lpr9vn8jy";
    };

    meta = with pkgs.lib; {
      description = "PHP extension for Pinba";
      longDescription = ''
        Pinba is a MySQL storage engine that acts as a realtime monitoring and
        statistics server for PHP using MySQL as a read-only interface.
      '';
      homepage = "http://pinba.org/";

      broken = (isPhp56 || !isPhp73);
    };
  };

  protobuf = if isPhp56 then protobuf312 else protobuf314;

  protobuf312 = buildPecl {
    version = "3.12.4";
    pname = "protobuf";

    sha256 = "109nyjym1c9x5f462wr1ilzv37bs57vridn9plq0vzam0drnp0mq";

    buildInputs = with pkgs; [ pcre.dev ];

    meta = with pkgs.lib; {
      description = ''
        Google's language-neutral, platform-neutral, extensible mechanism for serializing structured data.
      '';
      license = licenses.bsd3;
      homepage = "https://developers.google.com/protocol-buffers";

      broken = !isPhp56;
    };
  };

  protobuf314 = buildPecl {
    version = "3.14.0";
    pname = "protobuf";

    sha256 = "1ldc4s28hq61cfg8l4c06pgicj0ng7k37f28a0dnnbs7xkr7cibd";

    buildInputs = with pkgs; [ (if isPhp73 then pcre2.dev else pcre.dev) ];

    meta = with pkgs.lib; {
      description = ''
        Google's language-neutral, platform-neutral, extensible mechanism for serializing structured data.
      '';
      license = licenses.bsd3;
      homepage = "https://developers.google.com/protocol-buffers";

      broken = (isPhp56 || isPhp80);
    };
  };

  psalm = mkDerivation rec {
    version = "4.4.1";
    pname = "psalm";

    src = pkgs.fetchurl {
      url = "https://github.com/vimeo/psalm/releases/download/${version}/psalm.phar";
      sha256 = "1p4668ihcdswasyap37vzkj4302rx4241c8686gdkk75yw0a06p2";
    };

    phases = [ "installPhase" ];
    nativeBuildInputs = with pkgs; [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      install -D $src $out/libexec/psalm/psalm.phar
      makeWrapper ${php}/bin/php $out/bin/psalm \
        --add-flags "$out/libexec/psalm/psalm.phar"
    '';

    meta = with pkgs.lib; {
      description = "A static analysis tool for finding errors in PHP applications";
      license = licenses.mit;
      homepage = "https://github.com/vimeo/psalm";
    };
  };

  psysh = mkDerivation rec {
    version = "0.10.6";
    pname = "psysh";

    src = pkgs.fetchurl {
      url = "https://github.com/bobthecow/psysh/releases/download/v${version}/psysh-v${version}.tar.gz";
      sha256 = "133iyhw73snmbwwgs8wb2988p30yvlwka1pflqaidi62gdd03bdw";
    };

    phases = [ "installPhase" ];
    nativeBuildInputs = with pkgs; [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      tar -xzf $src -C $out/bin
      chmod +x $out/bin/psysh
      wrapProgram $out/bin/psysh
    '';

    meta = with pkgs.lib; {
      description = "PsySH is a runtime developer console, interactive debugger and REPL for PHP.";
      license = licenses.mit;
      homepage = "https://psysh.org/";
      maintainers = with maintainers; [ caugner ];
    };
  };

  pthreads = if isPhp56 then pthreads20 else (if isPhp73 then pthreads32-dev else (if isPhp72 then pthreads32 else pthreads31));

  pthreads20 = buildPecl {
    version = "2.0.10";
    pname = "pthreads";

    sha256 = "1xlcb1b1g10jd0xhm3c01a06yqpb5qln47pd1k522138324qvpwb";

    buildInputs = with pkgs; [ pcre.dev ];

    meta.broken = !isPhp56;
  };

  pthreads31 = buildPecl {
    version = "3.1.6-dev";
    pname = "pthreads";

    src = pkgs.fetchFromGitHub {
      owner = "krakjoe";
      repo = "pthreads";
      rev = "527286336ffcf5fffb285f1bfeb100bb8bf5ec32";
      sha256 = "0p2kkngmnw4lk2lshgq7hx91wqn21yjxzqlx90xcv94ysvffspl5";
    };

    buildInputs = with pkgs; [ pcre.dev ];

    meta.broken = (!isPhp71 || isPhp72 || isPhp73);
  };

  pthreads32 = buildPecl rec {
    version = "3.2.0";
    pname = "pthreads";

    src = pkgs.fetchFromGitHub {
      owner = "krakjoe";
      repo = "pthreads";
      rev = "v${version}";
      sha256 = "17hypm75d4w7lvz96jb7s0s87018yzmmap0l125d5fd7abnhzfvv";
    };

    buildInputs = with pkgs; [ pcre.dev ];

    meta.broken = (!isPhp72 || isPhp73);
  };

  pthreads32-dev = buildPecl {
    version = "3.2.0-dev";
    pname = "pthreads";

    src = pkgs.fetchFromGitHub {
      owner = "krakjoe";
      repo = "pthreads";
      rev = "4d1c2483ceb459ea4284db4eb06646d5715e7154";
      sha256 = "07kdxypy0bgggrfav2h1ccbv67lllbvpa3s3zsaqci0gq4fyi830";
    };

    buildInputs = with pkgs; [ pcre2.dev ];

    meta.broken = (!isPhp73 || isPhp74);
  };

  redis = if isPhp56 then redis43 else redis50;

  redis43 = buildPecl {
    version = "4.3.0";
    pname = "redis";

    sha256 = "18hvll173mlp6dk6xvgajkjf4min8f5gn809nr1ahq4r6kn4rw60";

    meta.broken = !isPhp56;
  };

  redis50 = buildPecl {
    version = "5.3.3";
    pname = "redis";

    sha256 = "1w4jzm80r3zdns2w7njw774cbzk1v8wa5j9hk8im5kb4w5hr2y1p";

    meta.broken = isPhp56;
  };

  sqlsrv = if !isPhp73 then sqlsrv58 else sqlsrv59;

  sqlsrv58 = buildPecl {
    version = "5.8.1";
    pname = "sqlsrv";

    sha256 = "0c9a6ghch2537vi0274vx0mn6nb1xg2qv7nprnf3xdfqi5ww1i9r";

    buildInputs = with pkgs; [ unixODBC ];

    meta.broken = (isPhp56 || isPhp73);
  };

  sqlsrv59 = buildPecl {
    version = "5.9.0";
    pname = "sqlsrv";

    sha256 = "1css440b4qrbblmcswd5wdr2v1rjxlj2iicbmvjq9fg81028w40a";

    buildInputs = with pkgs; [ unixODBC ];

    meta.broken = !isPhp73;
  };

  snuffleupagus = buildPecl rec {
    version = "0.7.0";
    pname = "snuffleupagus";

    src = pkgs.fetchurl {
      url = "https://github.com/jvoisin/snuffleupagus/archive/v${version}.tar.gz";
      sha256 = "17qiy2c9bqrb0fk236mawd1vy47n3z8jv7iz031366nvb032y49a";
    };

    sourceRoot = "snuffleupagus-${version}/src";

    buildInputs = with pkgs; [ pcre.dev pcre2.dev ];

    meta.broken = isPhp56;
  };

  spidermonkey = buildPecl {
    version = "1.0.0";
    pname = "spidermonkey";

    sha256 = "1ywrsp90w6rlgq3v2vmvp2zvvykkgqqasab7h9bf3vgvgv3qasbg";

    configureFlags = with pkgs; [
      "--with-spidermonkey=${spidermonkey_1_8_5}"
    ];

    buildInputs = with pkgs; [ spidermonkey_1_8_5 ];

    meta.broken = !isPhp56;
  };

  xcache = buildPecl rec {
    version = "3.2.0";
    pname = "xcache";

    src = pkgs.fetchurl {
      url = "https://xcache.lighttpd.net/pub/Releases/${version}/${pname}.tar.bz2";
      sha256 = "1gbcpw64da9ynjxv70jybwf9y88idm01kb16j87vfagpsp5s64kx";
    };

    doCheck = true;
    checkTarget = "test";

    configureFlags = [
      "--enable-xcache"
      "--enable-xcache-coverager"
      "--enable-xcache-optimizer"
      "--enable-xcache-assembler"
      "--enable-xcache-encoder"
      "--enable-xcache-decoder"
    ];

    buildInputs = with pkgs; [ m4 ];

    meta.broken = !isPhp56;
  };

  xdebug = if isPhp56 then xdebug25 else (if isPhp72 then xdebug30 else xdebug29);

  xdebug25 = buildPecl {
    version = "2.5.5";
    pname = "xdebug";

    sha256 = "197i1fcspbrdxki6rljvpjdxzhyaxl7nlihhiqcyfkjipkr8n43j";

    doCheck = true;
    checkTarget = "test";

    meta.broken = !isPhp56;
  };

  xdebug29 = buildPecl {
    version = "2.9.8";
    pname = "xdebug";

    sha256 = "12igfrdfisqfmfqpc321g93pm2w1y7h24bclmxjrjv6rb36bcmgm";

    doCheck = true;
    checkTarget = "test";

    meta.broken = (isPhp56 || isPhp72);
  };

  xdebug30 = buildPecl {
    version = "3.0.2";
    pname = "xdebug";

    sha256 = "05sfgkw55ym7mg0b54l9x3i9598kf2bkp4z3sdl1hd31q3g4cv89";

    doCheck = true;
    checkTarget = "test";

    meta.broken = !isPhp72;
  };

  yaml = if isPhp56 then yaml13 else yaml22;

  yaml13 = buildPecl {
    version = "1.3.2";
    pname = "yaml";

    sha256 = "16jr5v3pff3f1yd61hh4pb279ivb7np1kf8mhvfw16g0fsvx33js";

    configureFlags = with pkgs; [
      "--with-yaml=${libyaml}"
    ];

    nativeBuildInputs = with pkgs; [ pkg-config ];

    meta.broken = !isPhp56;
  };

  yaml22 = buildPecl {
    version = "2.2.1";
    pname = "yaml";

    sha256 = "06bqgp4y38npr6digi00ily1ivyz4sfxzlnxkc4zs99ffm7d0yp1";

    configureFlags = with pkgs; [
      "--with-yaml=${libyaml}"
    ];

    nativeBuildInputs = with pkgs; [ pkg-config ];

    meta.broken = isPhp56;
  };

  zmq = buildPecl {
    version = "1.1.3";
    pname = "zmq";

    sha256 = "1kj487vllqj9720vlhfsmv32hs2dy2agp6176mav6ldx31c3g4n4";

    configureFlags = with pkgs; [
      "--with-zmq=${zeromq}"
    ];

    nativeBuildInputs = with pkgs; [ pkg-config ];

    meta.broken = isPhp73;
  };
}; in self
