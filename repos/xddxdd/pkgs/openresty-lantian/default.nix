{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation rec {
  pname = "openresty-lantian";
  nginxVersion = "1.19.9";
  version = "${nginxVersion}.1";

  srcs = [
    (pkgs.fetchzip {
      url = "https://openresty.org/download/openresty-${version}.tar.gz";
      sha256 = "07bj41j9nvxmbhshfs0bzhykv11wcygqvc6qkh7cfsjiiywxd5xi";
      name = "openresty";
    })

    (pkgs.fetchhg {
      url = "https://hg.nginx.org/nginx-quic";
      rev = "7603284f7af5";
      sha256 = "009d2yp0wf87wi426mbxdqhiwrrwrlcqwdppbaxz6z0859wcsrgn";
      name = "nginx-quic";
    })

    (pkgs.fetchFromGitHub rec {
      owner = "google";
      repo = "ngx_brotli";
      rev = "9aec15e2aa6feea2113119ba06460af70ab3ea62";
      sha256 = "02hfvfa6milj40qc2ikpb9f95sxqvxk4hly3x74kqhysbdi06hhv";
      name = repo;
    })

    (pkgs.fetchFromGitHub rec {
      owner = "google";
      repo = "brotli";
      rev = "e61745a6b7add50d380cfd7d3883dd6c62fc2c71";
      sha256 = "0xyp85h12sknl4pxg1x8lgx8simzhdv73h4a8c1m7gyslsny386g";
      name = repo;
    })

    (pkgs.fetchFromGitHub rec {
      owner = "openresty";
      repo = "stream-echo-nginx-module";
      rev = "b7b76b853131b6fa7579d20c2816b4b6abb16bea";
      sha256 = "0w648vhgdd0c39iz80fkvsv22w8idh8b598zk3f37sxxxpynzdj3";
      name = repo;
    })

    (pkgs.fetchFromGitHub rec {
      owner = "tokers";
      repo = "zstd-nginx-module";
      rev = "d082422df33a5ff84a29afe7b74967a7106f49ac";
      sha256 = "0p3n6plvz7bvdd0gzawlwkpm8r837gvrny7v6dfmwm77c1wlq1y7";
      name = repo;
    })

    (pkgs.fetchFromGitHub rec {
      owner = "vozlt";
      repo = "nginx-module-vts";
      rev = "3c6cf41315bfcb48c35a3a0be81ddba6d0d01dac";
      sha256 = "0ib2vj744zxbn5md7a14pr0f2bm85nkdsv91is7macs0gb9gkxr1";
      name = repo;
    })

    (pkgs.fetchFromGitHub rec {
      owner = "vozlt";
      repo = "nginx-module-sts";
      rev = "06ea32162654401b08e5e486155b9a2981623298";
      sha256 = "1q1wzf127gzn05ms34r2d0sfrpf5imc14rxa7011gbxgrqq1dm8y";
      name = repo;
    })

    (pkgs.fetchFromGitHub rec {
      owner = "vozlt";
      repo = "nginx-module-stream-sts";
      rev = "54494ccd33ddfeb1b458409caf1261d16ba31c27";
      sha256 = "1jdj1kik6l3rl9nyx61xkqk7hmqbncy0rrqjz3dmjqsz92y8zaya";
      name = repo;
    })
  ];

  sourceRoot = "openresty";

  patchModStreamEcho = ./patches/stream-echo-nginx-module.patch;

  patchUseOpensslMd5Sha1 = pkgs.fetchurl {
    url = "https://github.com/kn007/patch/raw/master/use_openssl_md5_sha1.patch";
    sha256 = "1db5mjkxl6vxg4pic4v6g8bi8q9v5psj8fbjmjls1nfvxpz6nhvr";
  };
  patchBoringsslOcsp = pkgs.fetchurl {
    url = "https://github.com/kn007/patch/raw/master/Enable_BoringSSL_OCSP.patch";
    sha256 = "0rnlss41h0s2qwjxsq0gyjb3h6mik5x4j5pfka7fvw43k4c0rbad";
  };

  patchHpackDyntls = ./patches/patch-nginx/nginx-hpack-dyntls.patch;
  patchDisableOpensslCheck = ./patches/patch-nginx/nginx-disable-openssl-check.patch;
  patchQuicDisableTcpNodelay = ./patches/patch-nginx/nginx-quic-disable-tcp-nodelay.patch;
  patchPlain = ./patches/patch-nginx/nginx-plain-quic-aware.patch;
  patchPlainProxy = ./patches/patch-nginx/nginx-plain-proxy.patch;
  patchNixEtag = pkgs.substituteAll {
    src = ./patches/patch-nginx/nix-etag-1.15.4.patch;
    preInstall = ''
      export nixStoreDir="$NIX_STORE" nixStoreDirLen="''${#NIX_STORE}"
    '';
  };
  patchNixSkipCheckLogsPath = ./patches/patch-nginx/nix-skip-check-logs-path.patch;

  liboqs = pkgs.callPackage ../liboqs {};
  boringssl = pkgs.callPackage ../boringssl-oqs {};

  enableParallelBuilding = true;

  nativeBuildInputs = [
    pkgs.git
  ];

  buildInputs = [
    liboqs
    boringssl

    pkgs.zlib
    pkgs.pcre
    pkgs.gd
    pkgs.zstd
    pkgs.perl
  ];

  postUnpack = ''
    export BUILDROOT=$(pwd)
    chmod -R 755 .
    patchShebangs .

    rm -rf $BUILDROOT/openresty/bundle/nginx-${nginxVersion}
    cp -r $BUILDROOT/hg-archive-nginx-quic $BUILDROOT/openresty/bundle/nginx-${nginxVersion}

    cd $BUILDROOT/openresty/bundle/nginx-${nginxVersion}
    ln -s ./auto/configure ./configure
    patch -p1 < ${patchUseOpensslMd5Sha1}
    patch -p1 < ${patchBoringsslOcsp}
    patch -p1 < ${patchHpackDyntls}
    patch -p1 < ${patchDisableOpensslCheck}
    patch -p1 < ${patchQuicDisableTcpNodelay}
    patch -p1 < ${patchPlain}
    patch -p1 < ${patchPlainProxy}
    patch -p1 < ${patchNixEtag}
    patch -p1 < ${patchNixSkipCheckLogsPath}

    cd $BUILDROOT/stream-echo-nginx-module
    patch -p1 < ${patchModStreamEcho}

    cd $BUILDROOT

    rm -rf $BUILDROOT/ngx_brotli/deps/brotli
    ln -s $BUILDROOT/brotli $BUILDROOT/ngx_brotli/deps/brotli
  '';

  preconfigure = ''
    export CFLAGS="-I${boringssl}/include -I${liboqs}/include"
    export LDFLAGS="-L${boringssl}/build/ssl -L${boringssl}/build/crypto -L${liboqs}/lib"
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
    "--with-http_v3_module"
    "--with-http_quic_module"
    "--with-stream"
    "--with-stream_realip_module"
    "--with-stream_ssl_module"
    "--with-stream_ssl_preread_module"
    "--with-stream_quic_module"
    "--add-module=../ngx_brotli"
    "--add-module=../stream-echo-nginx-module"
    "--add-module=../zstd-nginx-module"
    "--add-module=../nginx-module-vts"
    "--add-module=../nginx-module-sts"
    "--add-module=../nginx-module-stream-sts"
    "--with-openssl=${boringssl}"
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

  postConfigure = ''
    sed -i 's/libcrypto.a/libcrypto.a -loqs/g' build/nginx-${nginxVersion}/objs/Makefile
  '';

  meta = with pkgs.lib; {
    description = "OpenResty with Lan Tian modifications";
    homepage    = "https://openquantumsafe.org";
    license = with licenses; [ openssl isc mit bsd3 ];
  };
}
