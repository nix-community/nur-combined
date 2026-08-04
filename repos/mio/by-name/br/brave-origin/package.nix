{ pkgs }:

# Build Brave from source in an FHS environment.
#
# Usage:
#   BUILD_DIR=$PWD/scratch-build nix run .#brave-origin
#
# Env knobs:
#   BUILD_DIR    - checkout root (default: $HOME/brave-build)
#   SYNC_ONLY=1  - stop after sync/hooks
#   SKIP_SYNC=1  - skip sync/hooks and go straight to compile
#   MAX_RETRIES  - sync retry count on transient failures (default: 20)

let
  httplib2WithSocks = pkgs.python3.pkgs.httplib2.overrideAttrs (old: {
    propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ pkgs.python3.pkgs.pysocks ];
    postInstall = (old.postInstall or "") + ''
      sitepkgs=$out/lib/${pkgs.python3.libPrefix}/site-packages
      printf '%s\n' \
        'try:' \
        '    from socks import *' \
        '    from socks import socksocket, setdefaultproxy, wrapmodule' \
        'except ImportError:' \
        '    pass' \
        > "$sitepkgs/httplib2/socks.py"
    '';
  });

  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      (ps.toPythonModule httplib2WithSocks)
      pysocks
      requests
      six
      setuptools
      pip
      fido2
      packaging
      pyyaml
    ]
  );

  curlShimC = pkgs.writeText "curl-gnutls-shim.c" ''
    #define _GNU_SOURCE
    #include <dlfcn.h>
    #include <stdio.h>
    #include <stdlib.h>
    static void *curl_h;
    static void ensure(void) {
      if (curl_h) return;
      curl_h = dlopen("libcurl.so.4", RTLD_NOW | RTLD_LOCAL);
      if (!curl_h) { fprintf(stderr, "libcurl-gnutls shim: %s\n", dlerror()); abort(); }
    }
    static void *must_dlsym(const char *name) {
      ensure();
      void *s = dlsym(curl_h, name);
      if (!s) { fprintf(stderr, "libcurl-gnutls shim dlsym(%s): %s\n", name, dlerror()); abort(); }
      return s;
    }
    #define WRAP_V(name, ret, proto, args) \
      ret name##_gnutls proto; \
      __asm__(".symver " #name "_gnutls," #name "@CURL_GNUTLS_3"); \
      ret name##_gnutls proto { typedef ret (*fn_t) proto; static fn_t fn; if (!fn) fn = (fn_t)must_dlsym(#name); return fn args; }
    #define WRAP_VOID(name, proto, args) \
      void name##_gnutls proto; \
      __asm__(".symver " #name "_gnutls," #name "@CURL_GNUTLS_3"); \
      void name##_gnutls proto { typedef void (*fn_t) proto; static fn_t fn; if (!fn) fn = (fn_t)must_dlsym(#name); fn args; }
    WRAP_VOID(curl_easy_cleanup, (void *curl), (curl))
    WRAP_V(curl_easy_getinfo, int, (void *curl, int info, void *param), (curl, info, param))
    WRAP_V(curl_easy_init, void *, (void), ())
    WRAP_V(curl_easy_perform, int, (void *curl), (curl))
    WRAP_VOID(curl_easy_reset, (void *curl), (curl))
    WRAP_V(curl_easy_setopt, int, (void *curl, int option, void *param), (curl, option, param))
    WRAP_V(curl_easy_strerror, const char *, (int code), (code))
    WRAP_VOID(curl_formfree, (void *form), (form))
    WRAP_V(curl_global_init, int, (long flags), (flags))
    WRAP_V(curl_multi_add_handle, int, (void *multi, void *curl), (multi, curl))
    WRAP_V(curl_multi_cleanup, int, (void *multi), (multi))
    WRAP_V(curl_multi_info_read, void *, (void *multi, int *msgs), (multi, msgs))
    WRAP_V(curl_multi_init, void *, (void), ())
    WRAP_V(curl_multi_perform, int, (void *multi, int *running), (multi, running))
    WRAP_V(curl_multi_remove_handle, int, (void *multi, void *curl), (multi, curl))
    WRAP_V(curl_multi_setopt, int, (void *multi, int option, void *param), (multi, option, param))
    WRAP_V(curl_multi_strerror, const char *, (int code), (code))
    WRAP_V(curl_multi_timeout, int, (void *multi, long *timeout), (multi, timeout))
    WRAP_V(curl_multi_wait, int, (void *multi, void *extra_fds, unsigned int extra_nfds, int timeout_ms, int *numfds), (multi, extra_fds, extra_nfds, timeout_ms, numfds))
    WRAP_V(curl_slist_append, void *, (void *list, const char *data), (list, data))
    WRAP_VOID(curl_slist_free_all, (void *list), (list))
    WRAP_V(curl_version_info, void *, (int age), (age))
  '';

  curlShimMap = pkgs.writeText "curl-gnutls.map" ''
    CURL_GNUTLS_3 {
      global: curl_*;
      local: *;
    };
  '';

  fhsEnv = pkgs.buildFHSEnv {
    name = "brave-build-env";
    targetPkgs =
      pkgs': with pkgs'; [
        git
        pythonEnv
        nodejs
        pnpm
        ninja
        pkg-config
        gn
        curl
        curlWithGnuTls
        wget
        cacert
        bash
        coreutils
        which
        lsb-release
        gcc
        binutils
        glib
        glib.dev
        nss
        nspr
        atk
        at-spi2-atk
        cups
        dbus
        pango
        cairo
        libxkbcommon
        libxkbcommon.dev
        libx11
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxrandr
        libxtst
        libxcb
        alsa-lib
        mesa
        libgbm
        libdrm
        udev
        libusb1
        fontconfig
        freetype
        expat
        zlib
        openssl
        glibc
      ];
    runScript = "bash";
  };

  buildScript = pkgs.writeShellScriptBin "build-brave-origin-from-source" ''
    set -euo pipefail

    BUILD_DIR="''${BUILD_DIR:-$HOME/brave-build}"
    export BUILD_DIR
    MAX_RETRIES="''${MAX_RETRIES:-20}"
    SYNC_ONLY="''${SYNC_ONLY:-0}"
    SKIP_SYNC="''${SKIP_SYNC:-0}"

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    echo "==> Build directory: $BUILD_DIR"

    export DEPOT_TOOLS_UPDATE=0
    export GIT_SSL_CAINFO="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    export CURL_CA_BUNDLE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

    VENV_DIR="$BUILD_DIR/.brave-python-venv"
    if [ ! -x "$VENV_DIR/bin/python3" ] || ! "$VENV_DIR/bin/python3" -c 'import httplib2, socks, yaml' >/dev/null 2>&1; then
      echo "==> Creating writable Python venv at $VENV_DIR"
      rm -rf "$VENV_DIR"
      ${pkgs.python3}/bin/python3 -m venv "$VENV_DIR"
      "$VENV_DIR/bin/python3" -m pip -q --disable-pip-version-check install -U pip \
        httplib2 pysocks requests six setuptools packaging fido2 pyyaml >/dev/null
      sitepkgs=$(echo "$VENV_DIR"/lib/python*/site-packages)
      printf '%s\n' \
        'try:' \
        '    from socks import *' \
        '    from socks import socksocket, setdefaultproxy, wrapmodule' \
        'except ImportError:' \
        '    pass' \
        > "$sitepkgs/httplib2/socks.py"
    fi
    export VIRTUAL_ENV="$VENV_DIR"
    export PYTHONPATH="$(echo "$VENV_DIR"/lib/python*/site-packages)''${PYTHONPATH:+:$PYTHONPATH}"

    SHIM_DIR="$BUILD_DIR/.libshim"
    if [ ! -f "$SHIM_DIR/libcurl-gnutls.so.4" ]; then
      echo "==> Building libcurl-gnutls shim for Chromium cargo"
      mkdir -p "$SHIM_DIR"
      cp "${curlShimC}" "$SHIM_DIR/curl_gnutls_shim.c"
      cp "${curlShimMap}" "$SHIM_DIR/curl_gnutls.map"
      gcc -shared -fPIC -o "$SHIM_DIR/libcurl-gnutls.so.4" \
        "$SHIM_DIR/curl_gnutls_shim.c" -ldl \
        -Wl,--version-script="$SHIM_DIR/curl_gnutls.map" \
        -Wl,-soname,libcurl-gnutls.so.4
    fi
    export LD_LIBRARY_PATH="$SHIM_DIR:/usr/lib64:/usr/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

    echo "==> 1. Setting up depot_tools..."
    if [ ! -d depot_tools ]; then
      git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    fi
    export PATH="$VENV_DIR/bin:$BUILD_DIR/depot_tools:$PATH"

    echo "==> 2. Cloning brave-core..."
    mkdir -p src
    if [ ! -d src/brave ]; then
      git clone https://github.com/brave/brave-core.git src/brave
    fi

    # Patch DEPS without runtime Python script.
    if [ -f src/brave/DEPS ] && grep -q "no-warn-script-location', 'pip'" src/brave/DEPS; then
      echo "==> Patching src/brave/DEPS update_pip hook for Nix"
      sed -i \
        "s|\\['python3', '-m', 'pip', '-q', '--disable-pip-version-check', 'install', '-U', '--no-warn-script-location', 'pip'\\],|['true'],  # nurpkgs: skip pip self-upgrade (Nix store is read-only)|" \
        src/brave/DEPS
    fi

    cd src/brave

    if [ "$SKIP_SYNC" = "1" ]; then
      echo "==> SKIP_SYNC=1 set; skipping sync/hooks"
    else
      if [ -f "$BUILD_DIR/src/DEPS" ] && [ -d "$BUILD_DIR/src/.git" ]; then
        SYNC_CMD=(pnpm run sync)
        echo "==> 3. Resuming with: ''${SYNC_CMD[*]}"
      else
        SYNC_CMD=(pnpm run init)
        echo "==> 3. Fresh checkout with: ''${SYNC_CMD[*]}"
      fi

      attempt=1
      while true; do
        echo "==> sync attempt $attempt/$MAX_RETRIES..."
        if "''${SYNC_CMD[@]}"; then
          echo "==> sync succeeded"
          break
        fi
        if [ "$attempt" -ge "$MAX_RETRIES" ]; then
          echo "==> sync failed after $MAX_RETRIES attempts" >&2
          exit 1
        fi
        sleep_secs=$((attempt < 8 ? (1 << attempt) : 300))
        echo "==> sync failed; sleeping ''${sleep_secs}s before retry..."
        sleep "$sleep_secs"
        attempt=$((attempt + 1))
        SYNC_CMD=(pnpm run sync)
      done
    fi

    if [ "$SYNC_ONLY" = "1" ]; then
      echo "==> SYNC_ONLY=1 set; skipping compile"
      exit 0
    fi

    echo "==> 4. Building brave (this will take many hours)..."
    pnpm run build
    echo "==> Build complete! Binary: $BUILD_DIR/src/out/Component/brave"
  '';
in
pkgs.writeShellScriptBin "brave-origin-build" ''
  exec ${fhsEnv}/bin/brave-build-env ${buildScript}/bin/build-brave-origin-from-source "$@"
''
