{ stdenv, fetchFromGitHub, which
, withPython2 ? false, python2
, withPython3 ? true, python3, ncurses
, withPHP56 ? false, php56
, withPHP71 ? false, php71
, withPHP72 ? false, php72
, withPHP73 ? true, php73
, withPHP74 ? false, php74
, withPHP80 ? false, php80
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
  version = "1.18.0";
  pname = "unit";

  src = fetchFromGitHub {
    owner = "nginx";
    repo = "unit";
    rev = "${version}";
    sha256 = "0r2l3ra63qjjbpjzrmx75jp9fvz83yis4j3qxqdnmxm77psykwy8";
  };

  nativeBuildInputs = [ which ];

  buildInputs = [ ]
    ++ optional withPython2 python2
    ++ optionals withPython3 [ python3 ncurses ]
    ++ optional withPHP56 php56
    ++ optional withPHP71 php71
    ++ optional withPHP72 php72
    ++ optional withPHP73 php73
    ++ optional withPHP74 php74
    ++ optional withPHP80 php80
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
    ${optionalString withPython2    "./configure python --module=python2  --config=python2-config  --lib-path=${python2}/lib"}
    ${optionalString withPython3    "./configure python --module=python3  --config=python3-config  --lib-path=${python3}/lib"}
    ${optionalString withPHP56      "./configure php    --module=php56    --config=${php56.dev}/bin/php-config    --lib-path=${php56}/lib"}
    ${optionalString withPHP71      "./configure php    --module=php71    --config=${php71.dev}/bin/php-config    --lib-path=${php71}/lib"}
    ${optionalString withPHP72      "./configure php    --module=php72    --config=${php72.dev}/bin/php-config    --lib-path=${php72}/lib"}
    ${optionalString withPHP73      "./configure php    --module=php73    --config=${php73.dev}/bin/php-config    --lib-path=${php73}/lib"}
    ${optionalString withPHP74      "./configure php    --module=php74    --config=${php74.dev}/bin/php-config    --lib-path=${php74}/lib"}
    ${optionalString withPHP80      "./configure php    --module=php80    --config=${php80.dev}/bin/php-config    --lib-path=${php80}/lib"}
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
