{ lib, stdenv

, fetchurl

, installShellFiles
, removeReferencesTo

, pcre
, zlib
, openssl
, libxml2
, libxslt
, libxcrypt
, gd
, geoip

, withDebug ? false
, withKTLS ? true
, withStream ? true
, withPerl ? true, perl
, withSlice ? false
, modules ? [ ]
}:
stdenv.mkDerivation rec {
  pname = "freenginx";
  version = "1.27.3";

  src = fetchurl {
    url = "https://freenginx.org/download/freenginx-${version}.tar.gz";
    hash = "sha256-kfBxUBFBOp0NTToBzjb+9jkb8y12RG6CZYKLrbQkxhc=";
  };

  nativeBuildInputs = [
    installShellFiles
    removeReferencesTo
  ];

  buildInputs = [ pcre zlib openssl libxml2 libxslt libxcrypt gd geoip ]
    ++ lib.optionals withPerl [ perl ]
    ++ lib.concatMap (mod: mod.inputs or [ ]) modules;

  configureFlags = [
    "--sbin-path=bin/nginx"
    "--with-http_ssl_module"
    "--with-http_v2_module"
    "--with-http_v3_module"
    "--with-http_realip_module"
    "--with-http_addition_module"
    "--with-http_xslt_module"
    "--with-http_sub_module"
    "--with-http_dav_module"
    "--with-http_flv_module"
    "--with-http_mp4_module"
    "--with-http_gunzip_module"
    "--with-http_gzip_static_module"
    "--with-http_auth_request_module"
    "--with-http_random_index_module"
    "--with-http_secure_link_module"
    "--with-http_degradation_module"
    "--with-http_stub_status_module"
    "--with-threads"
    "--with-pcre-jit"
    "--http-log-path=/var/log/nginx/access.log"
    "--error-log-path=/var/log/nginx/error.log"
    "--pid-path=/var/log/nginx/nginx.pid"
    "--http-client-body-temp-path=/tmp/nginx_client_body"
    "--http-proxy-temp-path=/tmp/nginx_proxy"
    "--http-fastcgi-temp-path=/tmp/nginx_fastcgi"
    "--http-uwsgi-temp-path=/tmp/nginx_uwsgi"
    "--http-scgi-temp-path=/tmp/nginx_scgi"
  ] ++ lib.optionals withDebug [
    "--with-debug"
  ] ++ lib.optionals withKTLS [
    "--with-openssl-opt=enable-ktls"
  ] ++ lib.optionals withStream [
    "--with-stream"
    "--with-stream_realip_module"
    "--with-stream_ssl_module"
    "--with-stream_ssl_preread_module"
  ] ++ lib.optionals withPerl [
    "--with-http_perl_module"
    "--with-perl=${perl}/bin/perl"
    "--with-perl_modules_path=lib/perl5"
  ] ++ lib.optionals withSlice [
    "--with_http_slice_module"
  ] ++ lib.optionals (with stdenv.hostPlatform; isLinux || isFreeBSD) [
    "--with-file-aio"
  ] ++ lib.optionals (gd != null) [
    "--with-http_image_filter_module"
  ] ++ lib.optionals (geoip != null) [
    "--with-http_geoip_module"
  ] ++ lib.optionals (withStream && geoip != null) [
    "--with-stream_geoip_module"
  ] ++ map (mod: "--add-module=${mod.src}") modules;

  env.NIX_CFLAGS_COMPILE = toString ([
    "-I${libxml2.dev}/include/libxml2"
    "-Wno-error=implicit-fallthrough"
  ] ++ lib.optionals (stdenv.cc.isGNU && lib.versionAtLeast stdenv.cc.version "11") [
    "-Wno-error=stringop-overread"
  ]);

  configurePlatforms = [ ];

  preConfigure = ''
    setOutputFlag=
  '' + lib.concatMapStringsSep "\n" (mod: mod.preConfigure or "") modules;

  patches = [
    ./nix-skip-check-logs-path.patch
  ];

  hardeningEnable = lib.optional (!stdenv.isDarwin) "pie";

  enableParallelBuilding = true;

  preInstall = ''
    installManPage man/nginx.8
  '';

  postInstall = lib.concatMapStringsSep "\n" (mod:
    "remove-references-to -t ${mod.src} $out/bin/nginx"
  ) modules;

  passthru = {
    inherit modules;
  };

  meta = {
    description = "A reverse proxy and lightweight webserver";
    mainProgram = "nginx";
    homepage    = "http://freenginx.org";
    license     = lib.licenses.bsd2;
    platforms   = lib.platforms.all;
  };
}
