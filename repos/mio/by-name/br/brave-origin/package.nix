{ lib, pkgs }:

# Build Brave from source using an FHS environment.
# FHS provides /usr/bin/env and lets depot_tools, gclient, vpython3 work correctly.
#
# Usage:
#   BUILD_DIR=$PWD/scratch-build nix run .#brave-origin
#
# Env knobs:
#   BUILD_DIR   - checkout root (default: $HOME/brave-build)
#   SYNC_ONLY=1 - stop after gclient/pnpm sync (skip compile)
#   SKIP_SYNC=1 - skip sync/hooks and go straight to compile
#   MAX_RETRIES - sync retry count on transient failures (default: 20)

let
  # depot_tools uses `import httplib2.socks` which requires a socks.py file
  # INSIDE the httplib2 package dir (bundled in old versions, removed in modern).
  # We patch the nixpkgs httplib2 to inject a shim that re-exports PySocks.
  httplib2WithSocks = pkgs.python3.pkgs.httplib2.overrideAttrs (old: {
    propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ pkgs.python3.pkgs.pysocks ];
    postInstall = (old.postInstall or "") + ''
            sitepkgs=$out/lib/${pkgs.python3.libPrefix}/site-packages
            cat > $sitepkgs/httplib2/socks.py << 'SOCKSEOF'
      # shim: re-export PySocks as httplib2.socks for depot_tools compatibility
      try:
          from socks import *
          from socks import socksocket, setdefaultproxy, wrapmodule
      except ImportError:
          pass
      SOCKSEOF
    '';
  });

  # Python env with all modules depot_tools needs
  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      (ps.toPythonModule httplib2WithSocks)
      ps.pysocks
      ps.requests
      ps.six
      ps.setuptools
      ps.pip
      ps.fido2
      ps.packaging
      ps.pyyaml
    ]
  );

  fhsEnv = pkgs.buildFHSEnv {
    name = "brave-build-env";
    targetPkgs =
      pkgs: with pkgs; [
        # Core build tools
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
        # Compiler toolchain
        gcc
        binutils
        # C/C++ libraries for Chromium
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
        # X11
        libx11
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxrandr
        libxtst
        libxcb
        # Other system libs
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

        # Tell depot_tools not to self-update. Do NOT set VPYTHON_BYPASS: Brave
        # hooks need vpython3 to provide modules such as PyYAML.
        export DEPOT_TOOLS_UPDATE=0
        # SSL certs
        export GIT_SSL_CAINFO="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        export CURL_CA_BUNDLE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

        # Isolated writable venv: Brave hooks run `pip install -U pip`, which cannot
        # write into the Nix store python used by buildFHSEnv.
        VENV_DIR="$BUILD_DIR/.brave-python-venv"
        if [ ! -x "$VENV_DIR/bin/python3" ] || ! "$VENV_DIR/bin/python3" -c 'import httplib2, socks, yaml' 2>/dev/null; then
          echo "==> Creating isolated writable Python venv at $VENV_DIR"
          rm -rf "$VENV_DIR"
          ${pkgs.python3}/bin/python3 -m venv "$VENV_DIR"
          "$VENV_DIR/bin/python3" -m pip -q --disable-pip-version-check install -U pip \
            httplib2 pysocks requests six setuptools packaging fido2 pyyaml >/dev/null
          sitepkgs="$("$VENV_DIR/bin/python3" -c 'import site; print(site.getsitepackages()[0])')"
          cat > "$sitepkgs/httplib2/socks.py" << 'SOCKSEOF'
    try:
        from socks import *
        from socks import socksocket, setdefaultproxy, wrapmodule
    except ImportError:
        pass
    SOCKSEOF
        fi
        export VIRTUAL_ENV="$VENV_DIR"
        export PYTHONPATH="$("$VENV_DIR/bin/python3" -c 'import site; print(site.getsitepackages()[0])')''${PYTHONPATH:+:$PYTHONPATH}"

        # Chromium's prebuilt cargo needs Debian-style libcurl-gnutls.so.4 (CURL_GNUTLS_3).
        # Provide a tiny dlsym shim that forwards to Nix's libcurl.so.4.
        SHIM_DIR="$BUILD_DIR/.libshim"
        if [ ! -f "$SHIM_DIR/libcurl-gnutls.so.4" ]; then
          echo "==> Building libcurl-gnutls.so.4 shim for Chromium cargo"
          mkdir -p "$SHIM_DIR"
          cat > "$SHIM_DIR/curl_gnutls_shim.c" << 'SHIMEOF'
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
    SHIMEOF
          cat > "$SHIM_DIR/curl_gnutls.map" << 'MAPEOF'
    CURL_GNUTLS_3 {
      global: curl_*;
      local: *;
    };
    MAPEOF
          gcc -shared -fPIC -o "$SHIM_DIR/libcurl-gnutls.so.4" "$SHIM_DIR/curl_gnutls_shim.c" \
            -ldl -Wl,--version-script="$SHIM_DIR/curl_gnutls.map" -Wl,-soname,libcurl-gnutls.so.4
        fi
        export LD_LIBRARY_PATH="$SHIM_DIR:/usr/lib64:/usr/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

        # Step 1: depot_tools
        echo "==> 1. Setting up depot_tools..."
        if [ ! -d depot_tools ]; then
          git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
        fi
        export PATH="$VENV_DIR/bin:$BUILD_DIR/depot_tools:$PATH"

        # Step 2: brave-core in the right place
        echo "==> 2. Cloning brave-core..."
        mkdir -p src
        if [ ! -d src/brave ]; then
          git clone https://github.com/brave/brave-core.git src/brave
        fi

        # Skip Brave's pip self-upgrade hook (Nix store python is immutable)
        if [ -f src/brave/DEPS ] && grep -q "no-warn-script-location', 'pip'" src/brave/DEPS; then
          echo "==> Patching src/brave/DEPS update_pip hook for Nix"
          ${pkgs.python3}/bin/python3 - <<'PY'
    from pathlib import Path
    import os
    p = Path(os.environ["BUILD_DIR"]) / "src/brave/DEPS"
    text = p.read_text()
    old = "['python3', '-m', 'pip', '-q', '--disable-pip-version-check', 'install', '-U', '--no-warn-script-location', 'pip']"
    new = "['true'],  # nurpkgs: skip pip self-upgrade (Nix store is read-only)"
    # Keep a single trailing comma after the action value by stripping any leftover
    text2 = text.replace(old + ",", new, 1) if (old + ",") in text else text.replace(old, new, 1)
    if text2 != text:
        p.write_text(text2)
    PY
        fi

        cd src/brave

        if [ "$SKIP_SYNC" = "1" ]; then
          echo "==> SKIP_SYNC=1 set; skipping sync/hooks"
        else
          # Prefer resume (sync) once chromium src exists; full init otherwise.
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
            # Exponential backoff capped at 5 minutes (helps with googlesource 429)
            sleep_secs=$(( attempt < 8 ? (1 << attempt) : 300 ))
            echo "==> sync failed; sleeping ''${sleep_secs}s before retry..."
            sleep "$sleep_secs"
            attempt=$((attempt + 1))
            # After first failure, always resume via sync (init is not idempotent-friendly)
            SYNC_CMD=(pnpm run sync)
          done
        fi

        if [ "$SYNC_ONLY" = "1" ]; then
          echo "==> SYNC_ONLY=1 set; skipping compile"
          exit 0
        fi

        # Step 4: compile
        echo "==> 4. Building brave (this will take many hours)..."
        pnpm run build

        echo "==> Build complete! Binary: $BUILD_DIR/src/out/Component/brave"
  '';
in
pkgs.writeShellScriptBin "brave-origin-build" ''
  exec ${fhsEnv}/bin/brave-build-env ${buildScript}/bin/build-brave-origin-from-source "$@"
''
