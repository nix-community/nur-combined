{ pkgs, fetchgit, php }:

let
  self = with self; {
    buildPecl = import ./build-pecl.nix {
      inherit php;
      inherit (pkgs) stdenv autoreconfHook fetchurl;
    };

  apcu = buildPecl {
    name = "apcu-4.0.11";
    sha256 = "002d1gklkf0z170wkbhmm2z1p9p5ghhq3q1r9k54fq1sq4p30ks5";
    buildInputs = [ pkgs.pcre ];
  };

  couchbase = buildPecl rec {
    name = "couchbase-${version}";
    version = "2.5.0";

    buildInputs = [ pkgs.libcouchbase pkgs.zlib igbinary pcs ];

    src = pkgs.fetchFromGitHub {
      owner = "couchbase";
      repo = "php-couchbase";
      rev = "v${version}";
      sha256 = "1ii34i4m1gs0rdxgx6ic4g2frbb6dmljir74zwhkzrnaxxzh4558";
    };

    configureFlags = [ "--with-couchbase" ];

    patches = [
      (pkgs.writeText "php-couchbase.patch" ''
        --- a/config.m4
        +++ b/config.m4
        @@ -9,7 +9,7 @@ if test "$PHP_COUCHBASE" != "no"; then
             LIBCOUCHBASE_DIR=$PHP_COUCHBASE
           else
             AC_MSG_CHECKING(for libcouchbase in default path)
        -    for i in /usr/local /usr; do
        +    for i in ${pkgs.libcouchbase}; do
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
  };

  igbinary = buildPecl {
    name = "igbinary-2.0.7";

    configureFlags = [ "--enable-igbinary" ];

    makeFlags = [ "phpincludedir=$(dev)/include" ];

    outputs = [ "out" "dev" ];

    sha256 = "00gq205g2yq4psisla5wg1l0igm5b28gkx88xzgmffhgpn8wxp8c";
  };

  imagick = buildPecl {
    name = "imagick-3.4.3";
    sha256 = "0z2nc92xfc5axa9f2dy95rmsd2c81q8cs1pm4anh0a50x9g5ng0z";
    configureFlags = "--with-imagick=${pkgs.imagemagick.dev}";
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = [ pkgs.pcre ];
  };

  memcache = buildPecl {
    name = "memcache-3.0.8";

    sha256 = "04c35rj0cvq5ygn2jgmyvqcb0k8d03v4k642b6i37zgv7x15pbic";

    configureFlags = "--with-zlib-dir=${pkgs.zlib.dev}";

    makeFlags = [ "CFLAGS=-fgnu89-inline" ];
  };

  memcached = buildPecl {
    name = "memcached-2.2.0";

    sha256 = "0n4z2mp4rvrbmxq079zdsrhjxjkmhz6mzi7mlcipz02cdl7n1f8p";

    configureFlags = [
      "--with-zlib-dir=${pkgs.zlib.dev}"
      "--with-libmemcached-dir=${pkgs.libmemcached}"
    ];

    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = with pkgs; [ cyrus_sasl zlib ];
  };

  pcs = buildPecl rec {
    name = "pcs-1.3.3";

    sha256 = "0d4p1gpl8gkzdiv860qzxfz250ryf0wmjgyc8qcaaqgkdyh5jy5p";
  };

  spidermonkey = buildPecl rec {
    name = "spidermonkey-1.0.0";

    sha256 = "1ywrsp90w6rlgq3v2vmvp2zvvykkgqqasab7h9bf3vgvgv3qasbg";

    configureFlags = [
      "--with-spidermonkey=${pkgs.spidermonkey_1_8_5}"
    ];

    buildInputs = [ pkgs.spidermonkey_1_8_5 ];
  };

  xdebug = buildPecl {
    name = "xdebug-2.3.3";

    sha256 = "1qyz1imkr9k3sk4h4w2rslhsa4phk0y51x4lphnj8v8k4fdx0yxj";

    doCheck = true;
    checkTarget = "test";
  };

  yaml = buildPecl {
    name = "yaml-1.3.1";

    sha256 = "1fbmgsgnd6l0d4vbjaca0x9mrfgl99yix5yf0q0pfcqzfdg4bj8q";

    configureFlags = [
      "--with-yaml=${pkgs.libyaml}"
    ];

    nativeBuildInputs = [ pkgs.pkgconfig ];
  };

  zmq = buildPecl {
    name = "zmq-1.1.3";

    sha256 = "1kj487vllqj9720vlhfsmv32hs2dy2agp6176mav6ldx31c3g4n4";

    configureFlags = [
      "--with-zmq=${pkgs.zeromq}"
    ];

    nativeBuildInputs = [ pkgs.pkgconfig ];
  };

  xcache = buildPecl rec {
    name = "xcache-${version}";

    version = "3.2.0";

    src = pkgs.fetchurl {
      url = "http://xcache.lighttpd.net/pub/Releases/${version}/${name}.tar.bz2";
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

    buildInputs = [ pkgs.m4 ];
  };

  #pthreads requires a build of PHP with ZTS (Zend Thread Safety) enabled
  #--enable-maintainer-zts or --enable-zts on Windows
  pthreads = buildPecl {
    name = "pthreads-2.0.10";
    sha256 = "1xlcb1b1g10jd0xhm3c01a06yqpb5qln47pd1k522138324qvpwb";
    buildInputs = [ pkgs.pcre.dev ];
  };

  geoip = buildPecl {
    name = "geoip-1.1.1";
    sha256 = "01hgijn91an7gf0fva5fk3paag6lvfh7ynlv4if16ilx041mrl5j";

    configureFlags = [ "--with-geoip=${pkgs.geoip}" ];

    buildInputs = [ pkgs.geoip ];
  };

  redis = buildPecl {
    name = "redis-2.2.8";
    sha256 = "1ddijx6r798hsxxqr5vskknv8nh1knx5rdh7axj8z132vr93flzw";
  };

  composer = pkgs.stdenv.mkDerivation rec {
    name = "composer-${version}";
    version = "1.7.2";

    src = pkgs.fetchurl {
      url = "https://getcomposer.org/download/${version}/composer.phar";
      sha256 = "03km8qw3nshj7qzk5pidziha2ldx1l2yxhh2s7vpg25f9782hd7c";
    };

    unpackPhase = ":";

    buildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      install -D $src $out/libexec/composer/composer.phar
      makeWrapper ${php}/bin/php $out/bin/composer \
        --add-flags "$out/libexec/composer/composer.phar"
    '';

    meta = with pkgs.lib; {
      description = "Dependency Manager for PHP";
      license = licenses.mit;
      homepage = https://getcomposer.org/;
      maintainers = with maintainers; [ globin offline ];
    };
  };

  box = pkgs.stdenv.mkDerivation rec {
    name = "box-${version}";
    version = "2.7.5";

    src = pkgs.fetchurl {
      url = "https://github.com/box-project/box2/releases/download/${version}/box-${version}.phar";
      sha256 = "1zmxdadrv0i2l8cz7xb38gnfmfyljpsaz2nnkjzqzksdmncbgd18";
    };

    phases = [ "installPhase" ];
    buildInputs = [ pkgs.makeWrapper ];

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

  php-cs-fixer = pkgs.stdenv.mkDerivation rec {
    name = "php-cs-fixer-${version}";
    version = "2.12.2";

    src = pkgs.fetchurl {
      url = "https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/v${version}/php-cs-fixer.phar";
      sha256 = "19cq04x1wi489259vyad15zy6y0k3qd7dj77pcf74gxqw92hgg5c";
    };

    phases = [ "installPhase" ];
    buildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      install -D $src $out/libexec/php-cs-fixer/php-cs-fixer.phar
      makeWrapper ${php}/bin/php $out/bin/php-cs-fixer \
        --add-flags "$out/libexec/php-cs-fixer/php-cs-fixer.phar"
    '';

    meta = with pkgs.lib; {
      description = "A tool to automatically fix PHP coding standards issues";
      license = licenses.mit;
      homepage = http://cs.sensiolabs.org/;
      maintainers = with maintainers; [ jtojnar ];
    };
  };

  php-parallel-lint = pkgs.stdenv.mkDerivation rec {
    name = "php-parallel-lint-${version}";
    version = "1.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "JakubOnderka";
      repo = "PHP-Parallel-Lint";
      rev = "v${version}";
      sha256 = "16nv8yyk2z3l213dg067l6di4pigg5rd8yswr5xgd18jwbys2vnw";
    };

    buildInputs = [ pkgs.makeWrapper composer box ];

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

  phpcs = pkgs.stdenv.mkDerivation rec {
    name = "phpcs-${version}";
    version = "3.3.1";

    src = pkgs.fetchurl {
      url = "https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${version}/phpcs.phar";
      sha256 = "0kw1ffr688wbcip2hmr7yi7bpdf4kzwh22yvxw17lyddzq6vrqaw";
    };

    phases = [ "installPhase" ];
    buildInputs = [ pkgs.makeWrapper ];

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

  phpcbf = pkgs.stdenv.mkDerivation rec {
    name = "phpcbf-${version}";
    version = "3.3.1";

    src = pkgs.fetchurl {
      url = "https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${version}/phpcbf.phar";
      sha256 = "0q75h8y4rbysyzh3i5nzqqln2d8592p0sz6y11rr2hz0g9qw4gim";
    };

    phases = [ "installPhase" ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

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

  psysh = pkgs.stdenv.mkDerivation rec {
    name = "psysh-${version}";
    version = "0.9.6";

    src = pkgs.fetchurl {
      url = "https://github.com/bobthecow/psysh/releases/download/v${version}/psysh-v${version}.tar.gz";
      sha256 = "06icmyn7v229mpfplqj76kjnp1gh4ns0nrxa7bsckyqhzi425kc6";
    };

    phases = [ "installPhase" ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      tar -xzf $src -C $out/bin
      wrapProgram $out/bin/psysh
    '';

    meta = with pkgs.lib; {
      description = "PsySH is a runtime developer console, interactive debugger and REPL for PHP.";
      license = licenses.mit;
      homepage = https://psysh.org/;
      maintainers = with maintainers; [ caugner ];
    };
  };
}; in self
