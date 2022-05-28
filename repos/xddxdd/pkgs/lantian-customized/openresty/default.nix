{ lib
, sources
, stdenv
, fetchzip
, fetchFromGitHub
, fetchurl
, substituteAll
, git
, zlib
, pcre
, gd
, zstd
, perl
, liboqs
, openssl-oqs
, libxcrypt
, modules ? [ ]
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "openresty-lantian";
  nginxVersion = "1.21.4";
  version = "${nginxVersion}.1";

  src = fetchzip {
    url = "https://openresty.org/download/openresty-${version}.tar.gz";
    sha256 = "sha256-ZnNePXzcbNv1ZE2lD4Gcy7mBe54LjJFb3iEKojR6Whs=";
    name = "openresty";
  };

  sourceRoot = "openresty";

  patchModStreamEcho = ./patches/stream-echo-nginx-module.patch;

  patchUseOpensslMd5Sha1 = fetchurl {
    url = "https://github.com/kn007/patch/raw/master/use_openssl_md5_sha1.patch";
    sha256 = "1db5mjkxl6vxg4pic4v6g8bi8q9v5psj8fbjmjls1nfvxpz6nhvr";
  };

  patchHpackDyntls = fetchurl {
    url = "https://raw.githubusercontent.com/kn007/patch/f0b8ebd76924eb9c573c8056792b7f1d6f79d684/nginx.patch";
    sha256 = "0dp2lcyxcv41lcridny6fbc2yr95s2sx0bd2bxs59p437d3dm7qp";
  };

  patchPlain = ./patches/nginx-plain.patch;
  patchPlainProxy = ./patches/nginx-plain-proxy.patch;
  patchNixEtag = substituteAll {
    src = ./patches/nix-etag-1.15.4.patch;
    preInstall = ''
      export nixStoreDir="$NIX_STORE" nixStoreDirLen="''${#NIX_STORE}"
    '';
  };
  patchNixSkipCheckLogsPath = ./patches/nix-skip-check-logs-path.patch;

  enableParallelBuilding = true;

  nativeBuildInputs = [
    git
  ];

  buildInputs = [
    liboqs
    openssl-oqs
    libxcrypt

    zlib
    pcre
    gd
    zstd
    perl
  ];

  postUnpack =
    let
      extraSrcs = [
        "brotli"
        "nginx-module-stream-sts"
        "nginx-module-sts"
        "nginx-module-vts"
        "ngx_brotli"
        "stream-echo-nginx-module"
        "zstd-nginx-module"
      ];

      patch = p: ''
        echo ${p} && patch -p1 < ${p}
      '';
    in
    builtins.concatStringsSep "\n"
      (builtins.map
        (k: ''
          cp -r ${sources."${k}".src} ${k}
        '')
        extraSrcs)
    + ''
      export BUILDROOT=$(pwd)
      chmod -R 755 .
      patchShebangs .

      cd $BUILDROOT/openresty/bundle/nginx-${nginxVersion}
      ${patch patchUseOpensslMd5Sha1}
      ${patch patchHpackDyntls}
      ${patch patchPlain}
      ${patch patchPlainProxy}
      ${patch patchNixEtag}
      ${patch patchNixSkipCheckLogsPath}

      cd $BUILDROOT/stream-echo-nginx-module
      ${patch patchModStreamEcho}

      cd $BUILDROOT

      rm -rf $BUILDROOT/ngx_brotli/deps/brotli
      ln -s $BUILDROOT/brotli $BUILDROOT/ngx_brotli/deps/brotli
    '';

  configureFlags = [
    "--with-threads"
    "--with-file-aio"
    "--with-pcre-jit"
    "--with-http_addition_module"
    "--with-http_auth_request_module"
    "--with-http_gunzip_module"
    "--with-http_gzip_static_module"
    "--with-http_image_filter_module"
    "--with-http_realip_module"
    "--with-http_plain_module"
    "--with-http_ssl_module"
    "--with-http_stub_status_module"
    "--with-http_sub_module"
    "--with-http_v2_module"
    "--with-http_v2_hpack_enc"
    "--with-stream"
    "--with-stream_realip_module"
    "--with-stream_ssl_module"
    "--with-stream_ssl_preread_module"
    "--add-module=../ngx_brotli"
    "--add-module=../stream-echo-nginx-module"
    "--add-module=../zstd-nginx-module"
    "--add-module=../nginx-module-vts"
    "--add-module=../nginx-module-sts"
    "--add-module=../nginx-module-stream-sts"
    "--without-http_encrypted_session_module" # Conflict with quic stuff

    # NixOS paths
    "--http-log-path=/var/log/nginx/access.log"
    "--error-log-path=/var/log/nginx/error.log"
    "--pid-path=/var/log/nginx/nginx.pid"
    "--http-client-body-temp-path=/var/cache/nginx/client_body"
    "--http-proxy-temp-path=/var/cache/nginx/proxy"
    "--http-fastcgi-temp-path=/var/cache/nginx/fastcgi"
    "--http-uwsgi-temp-path=/var/cache/nginx/uwsgi"
    "--http-scgi-temp-path=/var/cache/nginx/scgi"
  ];

  postInstall = ''
    find $out/ -type f -executable -exec strip --strip-all {} \;
    ln -s $out/luajit/bin/luajit $out/bin/luajit-openresty
    ln -s $out/nginx/sbin/nginx $out/bin/nginx
    ln -s $out/nginx/conf $out/conf
    ln -s $out/nginx/html $out/html
  '';

  passthru = {
    modules = modules;
  };

  meta = with lib; {
    description = "OpenResty with Lan Tian modifications";
    homepage = "https://openresty.org";
    license = licenses.bsd2;
  };
}
