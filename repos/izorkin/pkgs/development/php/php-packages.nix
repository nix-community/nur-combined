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

  apcu = if isPhp56 then apcu40 else apcu51;

  #apcu40 = assert isPhp56; buildPecl {
  apcu40 = buildPecl {
    version = "4.0.11";
    pname = "apcu";

    sha256 = "002d1gklkf0z170wkbhmm2z1p9p5ghhq3q1r9k54fq1sq4p30ks5";

    buildInputs = with pkgs; [ pcre.dev ];

    meta.broken = !isPhp56;
  };

  #apcu51 = assert !isPhp56; buildPecl {
  apcu51 = buildPecl {
    version = "5.1.18";
    pname = "apcu";

    sha256 = "0ayykd4hfvdzk7qnr5k6yq5scwf6rb2i05xscfv76q5dmkkynvfl";

    buildInputs = with pkgs; [ (if isPhp73 then pcre2.dev else pcre.dev) ];
    doCheck = true;
    checkTarget = "test";
    checkFlagsArray = ["REPORT_EXIT_STATUS=1" "NO_INTERACTION=1"];
    makeFlags = [ "phpincludedir=$(dev)/include" ];
    outputs = [ "out" "dev" ];

    meta.broken = isPhp56;
  };

  #apcu_bc = assert !isPhp56; buildPecl {
  apcu_bc = buildPecl {
    version = "1.0.5";
    pname = "apcu_bc";

    sha256 = "0ma00syhk2ps9k9p02jz7rii6x3i2p986il23703zz5npd6y9n20";

    buildInputs = with pkgs; [ apcu (if isPhp73 then pcre2.dev else pcre.dev) ];

    meta.broken = isPhp56;
  };

  #ast = assert !isPhp56; buildPecl {
  ast = buildPecl {
    version = "1.0.6";
    pname = "ast";

    sha256 = "07k32p5nrmcmmr4ibm3z7qza42mcfhx4i65hdc826qmbsl27nd3h";

    meta.broken = isPhp56;
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
      homepage = https://box-project.github.io/box2/;
      maintainers = with maintainers; [ jtojnar ];
    };
  };

  composer = mkDerivation rec {
    version = "1.10.6";
    pname = "composer";

    src = pkgs.fetchurl {
      url = "https://getcomposer.org/download/${version}/composer.phar";
      sha256 = "0yzfzgg9qlc388g91bdg7y7rp1q8vqb5hkwykwmr1n1lv8dsrg99";
    };

    unpackPhase = ":";

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
      homepage = https://getcomposer.org/;
      maintainers = with maintainers; [ globin offline ];
    };
  };

  #couchbase = assert !isPhp74; buildPecl rec {
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
  };

  event = buildPecl {
    version = "2.5.6";
    pname = "event";

    sha256 = "16qxdpm55birp7vpwjcbx35a5c1rfz1bcvqg4jm2k5y85vdjnwfz";

    configureFlags = with pkgs; [
      "--with-event-libevent-dir=${libevent.dev}"
      "--with-event-core"
      "--with-event-extra"
      "--with-event-pthreads"
    ];

    nativeBuildInputs = with pkgs; [ pkgconfig ];
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

  #igbinary20 = assert isPhp56; buildPecl {
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

  #igbinary30 = assert !isPhp56; buildPecl {
  igbinary30 = buildPecl {
    version = "3.1.2";
    pname = "igbinary";

    sha256 = "02x93x0iqsfbcaavbf2aqb1yikfxgq0zximhyx1fv5skmmyk52z7";

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

    nativeBuildInputs = with pkgs; [ pkgconfig ];
    buildInputs = with pkgs; [ (if isPhp73 then pcre2.dev else pcre.dev) ];
  };

  #mailparse = assert !isPhp56; assert !isPhp73; buildPecl {
  mailparse = buildPecl {
    version = "3.1.0";
    pname = "mailparse";

    sha256 = "168wrg99y4ggq04kpryaka2x3zr6vn39979kyna4s6zrgdpcckvd";

    meta.broken = isPhp56;
  };

  memcache = if isPhp56 then memcache30 else memcache40;

  #memcache = assert isPhp56; buildPecl {
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

    meta.broken = isPhp56;
  };

  memcached = if isPhp56 then memcached22 else memcached31;

  #memcached22 = assert isPhp56; buildPecl {
  memcached22 = buildPecl {
    version = "2.2.0";
    pname = "memcached";

    sha256 = "0n4z2mp4rvrbmxq079zdsrhjxjkmhz6mzi7mlcipz02cdl7n1f8p";

    configureFlags = with pkgs; [
      "--with-zlib-dir=${zlib.dev}"
      "--with-libmemcached-dir=${libmemcached}"
    ];

    nativeBuildInputs = with pkgs; [ pkgconfig ];
    buildInputs = with pkgs; [ cyrus_sasl zlib ];

    meta.broken = !isPhp56;
  };

  #memcached31 = assert !isPhp56; buildPecl rec {
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

    nativeBuildInputs = with pkgs; [ pkgconfig ];
    buildInputs = with pkgs; [ cyrus_sasl zlib ];

    meta.broken = isPhp56;
  };

  mongodb = buildPecl {
    pname = "mongodb";
    version = "1.7.4";

    sha256 = "16l5ls45licfji3cv87n1rc9y7bvqh7hwnh7bgqczmnpc3l8pv0w";

    nativeBuildInputs = with pkgs; [ pkgconfig ];
    buildInputs = with pkgs; [
      cyrus_sasl
      icu
      openssl
      snappy
      zlib
      (if isPhp73 then pcre2.dev else pcre.dev)
    ] ++ lib.optional (stdenv.isDarwin) darwin.apple_sdk.frameworks.Security;
  };

  #pcov = assert !isPhp56; buildPecl {
  pcov = buildPecl {
    version = "1.0.6";
    pname = "pcov";

    sha256 = "1psfwscrc025z8mziq69pcx60k4fbkqa5g2ia8lplb94mmarj0v1";

    buildInputs = with pkgs; [ (if isPhp73 then pcre2.dev else pcre.dev) ];

    meta.broken = isPhp56;
  };

  #pcs = assert !isPhp74; buildPecl {
  pcs = buildPecl {
    version = "1.3.3";
    pname = "pcs";

    sha256 = "0d4p1gpl8gkzdiv860qzxfz250ryf0wmjgyc8qcaaqgkdyh5jy5p";

    meta.broken = isPhp74;
  };

  #pdo_sqlsrv = assert !isPhp56; assert isPhp74; buildPecl {
  pdo_sqlsrv = buildPecl {
    version = "5.8.1";
    pname = "pdo_sqlsrv";

    sha256 = "06ba4x34fgs092qq9w62y2afsm1nyasqiprirk4951ax9v5vcir0";

    buildInputs = with pkgs; [ unixODBC ];

    meta.broken = isPhp56;
  };

  php-cs-fixer = mkDerivation rec {
    version = "2.16.3";
    pname = "php-cs-fixer";

    src = pkgs.fetchurl {
      url = "https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/v${version}/php-cs-fixer.phar";
      sha256 = "195j61qbgbdn5xi0l6030mklji8m7fan2kf3446a1m2n4df3f5hb";
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
      homepage = https://cs.sensiolabs.org/;
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
      homepage = https://github.com/JakubOnderka/PHP-Parallel-Lint;
      maintainers = with maintainers; [ jtojnar ];
    };
  };

  phpcbf = mkDerivation rec {
    version = "3.5.4";
    pname = "phpcbf";

    src = pkgs.fetchurl {
      url = "https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${version}/phpcbf.phar";
      sha256 = "18x7fk59l821pivw1i2r868y78qgs0qk47b9il1smwi6plwyyflr";
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
      homepage = https://squizlabs.github.io/PHP_CodeSniffer/;
      maintainers = with maintainers; [ cmcdragonkai etu ];
    };
  };

  phpcs = mkDerivation rec {
    version = "3.5.5";
    pname = "phpcs";

    src = pkgs.fetchurl {
      url = "https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${version}/phpcs.phar";
      sha256 = "0jl038l55cmzn5ml61qkv4z1w4ri0h3v7h00pcb04xhz3gznlbsa";
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
      homepage = https://squizlabs.github.io/PHP_CodeSniffer/;
      maintainers = with maintainers; [ javaguirre etu ];
    };
  };

  phpstan = mkDerivation rec {
    version = "0.12.25";
    pname = "phpstan";

    src = pkgs.fetchurl {
      url = "https://github.com/phpstan/phpstan/releases/download/${version}/phpstan.phar";
      sha256 = "1a864v7fxpv5kp24nkvczrir3ldl6wxvaq85rd391ppa8ahdhvdd";
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
      homepage = https://github.com/phpstan/phpstan;
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

  #pinba111 = assert !isPhp56; assert !isPhp73; buildPecl {
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

  #pinba112 = assert !isPhp56; assert isPhp73; buildPecl {
  pinba112 = buildPecl {
    version = "1.1.2-dev";
    pname = "pinba";

    src = pkgs.fetchFromGitHub {
      owner = "tony2001";
      repo = "pinba_extension";
      rev = "edbc313f1b4fb8407bf7d5acf63fbb0359c7fb2e";
      sha256 = "02sljqm6griw8ccqavl23f7w1hp2zflcv24lpf00k6pyrn9cwx80";
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

  #protobuf = assert isPhp74; buildPecl {
  protobuf = buildPecl {
    version = "3.12.2";
    pname = "protobuf";

    sha256 = "1jqi9pxm895s74w9zv1qyv0f11vh3skha3zf48vfxsvv00kljk0z";

    buildInputs = with pkgs; [ (if isPhp73 then pcre2.dev else pcre.dev) ];

    meta = with pkgs.lib; {
      description = ''
        Google's language-neutral, platform-neutral, extensible mechanism for serializing structured data.
      '';
      license = licenses.bsd3;
      homepage = "https://developers.google.com/protocol-buffers/";
    };
  };

  psalm = mkDerivation rec {
    version = "3.11.5";
    pname = "psalm";

    src = pkgs.fetchurl {
      url = "https://github.com/vimeo/psalm/releases/download/${version}/psalm.phar";
      sha256 = "005cziqkq54326w7rm4vscscnrz1gjp2gjk08dx9kwabpcykbhsz";
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
      homepage = https://github.com/vimeo/psalm;
    };
  };

  psysh = mkDerivation rec {
    version = "0.10.4";
    pname = "psysh";

    src = pkgs.fetchurl {
      url = "https://github.com/bobthecow/psysh/releases/download/v${version}/psysh-v${version}.tar.gz";
      sha256 = "005xh5rz12bsy9yvzzr69zpr0p7v4sh6cafhpinpfrvbwfq068f1";
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
      homepage = https://psysh.org/;
      maintainers = with maintainers; [ caugner ];
    };
  };

  pthreads = if isPhp56 then pthreads20 else (if isPhp73 then pthreads32-dev else (if isPhp72 then pthreads32 else pthreads31));

  #pthreads20 = assert isPhp56; buildPecl {
  pthreads20 = buildPecl {
    version = "2.0.10";
    pname = "pthreads";

    sha256 = "1xlcb1b1g10jd0xhm3c01a06yqpb5qln47pd1k522138324qvpwb";

    buildInputs = with pkgs; [ pcre.dev ];

    meta.broken = !isPhp56;
  };

  #pthreads31 = assert isPhp71; assert !isPhp72; buildPecl {
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

  #pthreads32 = assert isPhp72; assert !isPhp73; buildPecl rec {
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

  #pthreads32-dev = assert isPhp73; assert !isPhp74; buildPecl {
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

  #redis43 = assert isPhp56; buildPecl {
  redis43 = buildPecl {
    version = "4.3.0";
    pname = "redis";

    sha256 = "18hvll173mlp6dk6xvgajkjf4min8f5gn809nr1ahq4r6kn4rw60";

    meta.broken = !isPhp56;
  };

  #redis50 = assert !isPhp56; buildPecl {
  redis50 = buildPecl {
    version = "5.2.2";
    pname = "redis";

    sha256 = "04dadrzdrsl2wnbsyn5qn9wpagh5sxqbfhz9fcc7cj6sr2g2crcr";

    meta.broken = isPhp56;
  };

  #sqlsrv = assert !isPhp56; assert !isPhp74; buildPecl {
  sqlsrv = buildPecl {
    version = "5.8.1";
    pname = "sqlsrv";

    sha256 = "0c9a6ghch2537vi0274vx0mn6nb1xg2qv7nprnf3xdfqi5ww1i9r";

    buildInputs = with pkgs; [ unixODBC ];

    meta.broken = isPhp56;
  };

  #spidermonkey = assert isPhp56; buildPecl {
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

  #xcache = assert isPhp56; buildPecl rec {
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

  xdebug = if isPhp56 then xdebug25 else xdebug29;

  #xdebug25 = assert isPhp56; buildPecl {
  xdebug25 = buildPecl {
    version = "2.5.5";
    pname = "xdebug";

    sha256 = "197i1fcspbrdxki6rljvpjdxzhyaxl7nlihhiqcyfkjipkr8n43j";

    doCheck = true;
    checkTarget = "test";

    meta.broken = !isPhp56;
  };

  #xdebug29 = assert !isPhp56; buildPecl {
  xdebug29 = buildPecl {
    version = "2.9.6";
    pname = "xdebug";

    sha256 = "0m748qkfy5i95dvsf4mwy6i3arxgpnsj1md878winj868w0vc0xb";

    doCheck = true;
    checkTarget = "test";

    meta.broken = isPhp56;
  };

  yaml = if isPhp56 then yaml13 else yaml20;

  #yaml13 = assert isPhp56; buildPecl {
  yaml13 = buildPecl {
    version = "1.3.2";
    pname = "yaml";

    sha256 = "16jr5v3pff3f1yd61hh4pb279ivb7np1kf8mhvfw16g0fsvx33js";

    configureFlags = with pkgs; [
      "--with-yaml=${libyaml}"
    ];

    nativeBuildInputs = with pkgs; [ pkgconfig ];

    meta.broken = !isPhp56;
  };

  #yaml20 = assert !isPhp56; buildPecl {
  yaml20 = buildPecl {
    version = "2.1.0";
    pname = "yaml";

    sha256 = "0rmn2irzny24ivzc09ss46s2s48i0zy2cww7ikphljqbfx6zdjss";

    configureFlags = with pkgs; [
      "--with-yaml=${libyaml}"
    ];

    nativeBuildInputs = with pkgs; [ pkgconfig ];

    meta.broken = isPhp56;
  };

  #zmq = assert !isPhp73; buildPecl {
  zmq = buildPecl {
    version = "1.1.3";
    pname = "zmq";

    sha256 = "1kj487vllqj9720vlhfsmv32hs2dy2agp6176mav6ldx31c3g4n4";

    configureFlags = with pkgs; [
      "--with-zmq=${zeromq}"
    ];

    nativeBuildInputs = with pkgs; [ pkgconfig ];

    meta.broken = isPhp73;
  };
}; in self
