{ stdenv, fetchFromGitHub, which
, ncurses
, withPython27 ? false, python27
, withPython35 ? false, python35
, withPython36 ? false, python36
, withPython37 ? true, python37
, withPython38 ? false, python38
, withPHP56 ? false, php56
, withPHP71 ? false, php71
, withPHP72 ? false, php72
, withPHP73 ? true, php73
, withPHP74 ? false, php74
, withPerl528 ? false, perl528
, withPerl530 ? true, perl530
, withPerldevel ? false, perldevel
, withRuby_2_4 ? false, ruby_2_4
, withRuby_2_5 ? false, ruby_2_5
, withRuby_2_6 ? true, ruby_2_6
, withSSL ? true, openssl ? null
, withIPv6 ? true
, withDebug ? false
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  version = "1.13.0";
  pname = "unit";

  src = fetchFromGitHub {
    owner = "nginx";
    repo = "unit";
    rev = "${version}";
    sha256 = "1b5il05isq5yvnx2qpnihsrmj0jliacvhrm58i87d48anwpv1k8q";
  };

  nativeBuildInputs = [ which ];

  buildInputs = [ ]
    ++ optional withPython27 python27
    ++ optional withPython35 python35
    ++ optional withPython36 python36
    ++ optional withPython37 python37
    ++ optional withPython38 python38
    ++ optional (withPython35 || withPython36 || withPython37 || withPython38) ncurses
    ++ optional withPHP56 php56
    ++ optional withPHP71 php71
    ++ optional withPHP72 php72
    ++ optional withPHP73 php73
    ++ optional withPHP74 php74
    ++ optional withPerl528 perl528
    ++ optional withPerl530 perl530
    ++ optional withPerldevel perldevel
    ++ optional withRuby_2_4 ruby_2_4
    ++ optional withRuby_2_5 ruby_2_5
    ++ optional withRuby_2_6 ruby_2_6
    ++ optional withSSL openssl;

  configureFlags = [
    "--control=unix:/run/unit/control.unit.sock"
    "--pid=/run/unit/unit.pid"
    "--user=unit"
    "--group=unit"
  ] ++ optional withSSL     [ "--openssl" ]
    ++ optional (!withIPv6) [ "--no-ipv6" ]
    ++ optional withDebug   [ "--debug" ];

  postConfigure = ''
    ${optionalString withPython27   "./configure python --module=python27 --config=${python27}/bin/python2.7-config   --lib-path=${python27}/lib"}
    ${optionalString withPython35   "./configure python --module=python35 --config=${python35}/bin/python3.5m-config  --lib-path=${python35}/lib"}
    ${optionalString withPython36   "./configure python --module=python36 --config=${python36}/bin/python3.6m-config  --lib-path=${python36}/lib"}
    ${optionalString withPython37   "./configure python --module=python37 --config=${python37}/bin/python3.7m-config  --lib-path=${python37}/lib"}
    ${optionalString withPython38   "./configure python --module=python38 --config=${python38}/bin/python3.8-config   --lib-path=${python38}/lib"}
    ${optionalString withPHP56      "./configure php    --module=php56    --config=${php56.dev}/bin/php-config        --lib-path=${php56}/lib"}
    ${optionalString withPHP71      "./configure php    --module=php71    --config=${php71.dev}/bin/php-config        --lib-path=${php71}/lib"}
    ${optionalString withPHP72      "./configure php    --module=php72    --config=${php72.dev}/bin/php-config        --lib-path=${php72}/lib"}
    ${optionalString withPHP73      "./configure php    --module=php73    --config=${php73.dev}/bin/php-config        --lib-path=${php73}/lib"}
    ${optionalString withPHP74      "./configure php    --module=php74    --config=${php74.dev}/bin/php-config        --lib-path=${php74}/lib"}
    ${optionalString withPerl528    "./configure perl   --module=perl528  --perl=${perl528}/bin/perl"}
    ${optionalString withPerl530    "./configure perl   --module=perl530  --perl=${perl530}/bin/perl"}
    ${optionalString withPerldevel  "./configure perl   --module=perldev  --perl=${perldevel}/bin/perl"}
    ${optionalString withRuby_2_4   "./configure ruby   --module=ruby24   --ruby=${ruby_2_4}/bin/ruby"}
    ${optionalString withRuby_2_5   "./configure ruby   --module=ruby25   --ruby=${ruby_2_5}/bin/ruby"}
    ${optionalString withRuby_2_6   "./configure ruby   --module=ruby26   --ruby=${ruby_2_6}/bin/ruby"}
  '';

  meta = {
    description = "Dynamic web and application server, designed to run applications in multiple languages.";
    homepage    = https://unit.nginx.org/;
    license     = licenses.asl20;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ izorkin ];
  };
}
