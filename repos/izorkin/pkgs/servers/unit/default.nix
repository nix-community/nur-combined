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
, withPerl ? true, perl
, withRuby_3_1 ? true, ruby_3_1
, withRuby_3_2 ? false, ruby_3_2
, withRuby_3_3 ? false, ruby_3_3
, withSSL ? true, openssl ? null
, withIPv6 ? true
, withDebug ? false
}:

stdenv.mkDerivation rec {
  pname = "unit";
  version = "1.35.0";

  src = fetchFromGitHub {
    owner = "nginx";
    repo = pname;
    rev = "${version}";
    hash = "sha256-0cMtU7wmy8GFKqxS8fXPIrMljYXBHzoxrUJCOJSzLMA=";
  };

  nativeBuildInputs = [ which ];

  buildInputs = [ pcre2.dev ]
    ++ lib.optional withPython2 python2
    ++ lib.optionals withPython3 [ python3 ncurses ]
    ++ lib.optional withPHP56 php56
    ++ lib.optional withPHP71 php71
    ++ lib.optional withPHP72 php72
    ++ lib.optional withPHP73 php73
    ++ lib.optional withPHP74 php74
    ++ lib.optional withPHP80 php80
    ++ lib.optional withPHP81 php81
    ++ lib.optional withPHP82 php82
    ++ lib.optional withPerl perl
    ++ lib.optional withRuby_3_1 ruby_3_1
    ++ lib.optional withRuby_3_2 ruby_3_2
    ++ lib.optional withRuby_3_3 ruby_3_3
    ++ lib.optional withSSL openssl;

  configureFlags = [
    "--control=unix:/run/unit/control.unit.sock"
    "--pid=/run/unit/unit.pid"
    "--user=unit"
    "--group=unit"
  ] ++ lib.optional withSSL [ "--openssl" ]
    ++ lib.optional (!withIPv6) [ "--no-ipv6" ]
    ++ lib.optional withDebug [ "--debug" ];

  postConfigure = ''
    ${lib.optionalString withPython2 "./configure python --module=python2 --config=python2-config --lib-path=${python2}/lib"}
    ${lib.optionalString withPython3 "./configure python --module=python3 --config=python3-config --lib-path=${python3}/lib"}
    ${lib.optionalString withPHP56 "./configure php --module=php56 --config=${php56.dev}/bin/php-config --lib-path=${php56}/lib"}
    ${lib.optionalString withPHP71 "./configure php --module=php71 --config=${php71.dev}/bin/php-config --lib-path=${php71}/lib"}
    ${lib.optionalString withPHP72 "./configure php --module=php72 --config=${php72.dev}/bin/php-config --lib-path=${php72}/lib"}
    ${lib.optionalString withPHP73 "./configure php --module=php73 --config=${php73.dev}/bin/php-config --lib-path=${php73}/lib"}
    ${lib.optionalString withPHP74 "./configure php --module=php74 --config=${php74.dev}/bin/php-config --lib-path=${php74}/lib"}
    ${lib.optionalString withPHP80 "./configure php --module=php80 --config=${php80.dev}/bin/php-config --lib-path=${php80}/lib"}
    ${lib.optionalString withPHP81 "./configure php --module=php81 --config=${php81.dev}/bin/php-config --lib-path=${php81}/lib"}
    ${lib.optionalString withPHP82 "./configure php --module=php82 --config=${php82.dev}/bin/php-config --lib-path=${php82}/lib"}
    ${lib.optionalString withPerl "./configure perl --module=perl --perl=${perl}/bin/perl"}
    ${lib.optionalString withRuby_3_1 "./configure ruby --module=ruby31 --ruby=${ruby_3_1}/bin/ruby"}
    ${lib.optionalString withRuby_3_2 "./configure ruby --module=ruby32 --ruby=${ruby_3_2}/bin/ruby"}
    ${lib.optionalString withRuby_3_3 "./configure ruby --module=ruby33 --ruby=${ruby_3_3}/bin/ruby"}
  '';

  postInstall = ''
    rm -rd $out/var
  '';

  meta = {
    description = "Dynamic web and application server, designed to run applications in multiple languages.";
    homepage = "https://unit.nginx.org/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ izorkin ];
  };
}
