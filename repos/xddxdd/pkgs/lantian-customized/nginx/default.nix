{
  lib,
  nginxMainline,
  nginxModules,
  ja4-nginx-module,
  nginx-auth-jwt,
  nginx-oidc,
  ngx_http_js_challenge_module,
  stream-echo-nginx-module,
  zstd-nginx-module,
  liburing,
  openssl-oqs-provider,
  python3,
  # extra args to make nixpkgs happy
  modules ? [ ],
}:

let
  # nixpkgs marks some modules as dynamic (loaded at runtime); keep everything
  # compiled into the nginx binary as the OpenResty-based variant did
  staticModule =
    mod:
    mod.overrideAttrs (_: {
      passthru = (mod.passthru or { }) // {
        dynamic = false;
      };
    });

  oqs-lookup = import ./oqs-lookup.nix {
    inherit lib openssl-oqs-provider python3;
  };
in
(nginxMainline.override {
  withImageFilter = true;
  modules = [
    (staticModule nginxModules.geoip2)
    (staticModule nginxModules.vts)
    (staticModule nginxModules.sts)
    (staticModule nginxModules.stream-sts)
    (staticModule nginxModules.brotli)
    ja4-nginx-module
    nginx-auth-jwt
    nginx-oidc
    ngx_http_js_challenge_module
    stream-echo-nginx-module
    zstd-nginx-module
    (staticModule (
      nginxModules.njs.overrideAttrs (old: {
        preConfigure =
          lib.replaceString
            ''configureFlags="''${configureFlags/--add-module=*nginx-mod-njs-${old.version}/&/nginx}"''
            ''configureFlags=("''${configureFlags[@]/--add-module=*nginx-mod-njs-${old.version}/&/nginx}")''
            old.preConfigure;
      })
    ))
  ];
}).overrideAttrs
  (old: {
    pname = "nginx-lantian";
    name = "nginx-lantian-${old.version}";
    __structuredAttrs = true;
    strictDeps = true;

    patches = old.patches ++ [
      ./patches/use-openssl-md5-sha1.patch
      ./patches/nginx-plain.patch
      ./patches/nginx-plain-proxy.patch
      ./patches/nginx-gemini.patch
      ./patches/nginx-oqs-curves.patch
      ./patches/nginx-binary-remote-network.patch
      ./patches/nginx-ja4.patch
      ./patches/nginx-http2-fingerprint.patch
      ./patches/nginx-io-uring.patch
      ./patches/nginx-ktls-lingering-close.patch
    ];

    postPatch = old.postPatch + ''
      install -Dm644 ${oqs-lookup}/oqs_lookup.c src/event/ngx_event_openssl_oqs_lookup.c
    '';

    buildInputs = old.buildInputs ++ [ liburing ];

    configureFlags = old.configureFlags ++ [
      "--with-http_plain_module"
      "--with-http_gemini_module"
    ];

    passthru = old.passthru // {
      inherit modules oqs-lookup;
    };

    meta = old.meta // {
      description = "Web server (nginx mainline) with Lan Tian modifications";
      maintainers = with lib.maintainers; [ xddxdd ];
    };
  })
