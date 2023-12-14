{ lib, stdenv, fetchFromGitHub, which
, pcre2
, withPython2 ? false, python2
, withPython3 ? true, python3, ncurses
, withPHP56 ? false, php56
, withPHP71 ? false, php71
, withPHP72 ? false, php72
, withPHP73 ? true, php73
, withPHP74 ? false, php74
, withPHP80 ? false, php80
, withPHP81 ? false, php81
, withPHP82 ? false, php82
, withPerl536 ? false, perl536
, withPerl538 ? true, perl538
, withRuby_3_1 ? true, ruby_3_1
, withRuby_3_2 ? false, ruby_3_2
, withRuby_3_3 ? false, ruby_3_3
, withSSL ? true, openssl ? null
, withIPv6 ? true
, withDebug ? false
}:

with lib;

stdenv.mkDerivation rec {
  pname = "unit";
  version = "1.31.1";

  src = fetchFromGitHub {
    owner = "nginx";
    repo = pname;
    rev = "${version}";
    hash = "sha256-6hecOCEC2MeJJieOOamEf8ytpEVAGs5mB0H16lJDciU=";
  };

  nativeBuildInputs = [ which ];

  buildInputs = [ pcre2.dev ]
    ++ optional withPython2 python2
    ++ optionals withPython3 [ python3 ncurses ]
    ++ optional withPHP56 php56
    ++ optional withPHP71 php71
    ++ optional withPHP72 php72
    ++ optional withPHP73 php73
    ++ optional withPHP74 php74
    ++ optional withPHP80 php80
    ++ optional withPHP81 php81
    ++ optional withPHP82 php82
    ++ optional withPerl536 perl536
    ++ optional withPerl538 perl538
    ++ optional withRuby_3_1 ruby_3_1
    ++ optional withRuby_3_2 ruby_3_2
    ++ optional withRuby_3_3 ruby_3_3
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
    ${optionalString withPHP81      "./configure php    --module=php81    --config=${php81.dev}/bin/php-config    --lib-path=${php81}/lib"}
    ${optionalString withPHP82      "./configure php    --module=php82    --config=${php82.dev}/bin/php-config    --lib-path=${php82}/lib"}
    ${optionalString withPerl536    "./configure perl   --module=perl536  --perl=${perl536}/bin/perl"}
    ${optionalString withPerl538    "./configure perl   --module=perl538  --perl=${perl538}/bin/perl"}
    ${optionalString withRuby_3_1   "./configure ruby   --module=ruby31   --ruby=${ruby_3_1}/bin/ruby"}
    ${optionalString withRuby_3_2   "./configure ruby   --module=ruby32   --ruby=${ruby_3_2}/bin/ruby"}
    ${optionalString withRuby_3_3   "./configure ruby   --module=ruby33   --ruby=${ruby_3_3}/bin/ruby"}
  '';

  postInstall = ''
    rm -rd $out/var
  '';

  meta = {
    description = "Dynamic web and application server, designed to run applications in multiple languages.";
    homepage    = "https://unit.nginx.org/";
    license     = licenses.asl20;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ izorkin ];
  };
}
