# Adapted from ilysenko/codex-desktop-linux; see LICENSE.upstream.
# Regenerate with scripts/sync-project-inputs.py computer-use.
{ pkgs }:
let
  pins = pkgs.lib.importJSON ./sources.json;
  system = pkgs.stdenv.hostPlatform.system;
  lib = pkgs.lib;
  nixLinuxFeatures = import ./features.nix { inherit lib; };
  upstreamPins = builtins.fromJSON (builtins.readFile ./upstream-linux-packages.json);
  codexVersion = upstreamPins.version;
  officialPackage = {
    x86_64-linux = {
      architecture = "amd64";
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/${upstreamPins.amd64.repositoryPath}";
      hash = upstreamPins.amd64.sri;
    };
    aarch64-linux = {
      architecture = "arm64";
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/${upstreamPins.arm64.repositoryPath}";
      hash = upstreamPins.arm64.sri;
    };
  }.${system};
  officialRuntimePaths = {
    x86_64-linux = {
      sky = "resources/cua_node/lib/node_modules/@oai/sky/bin/linux/sky_linux_x64";
      extensionHost = "resources/plugins/openai-bundled/plugins/chrome/extension-host/linux/x64/extension-host";
    };
    aarch64-linux = {
      sky = "resources/cua_node/lib/node_modules/@oai/sky/bin/linux/sky_linux_arm64";
      extensionHost = "resources/plugins/openai-bundled/plugins/chrome/extension-host/linux/arm64/extension-host";
    };
  }.${system};
  upstreamDeb = pkgs.fetchurl {
    inherit (officialPackage) url hash;
    name = "chatgpt_${codexVersion}_${officialPackage.architecture}.deb";
  };
  flakeSourceCommit = pins.desktop.rev;
  flakeSourceRemote = "https://github.com/ilysenko/codex-desktop-linux.git";
  flakeSourceDateEpoch = toString (pins.desktop.lastModified);
  sourceRoot = pkgs.fetchFromGitHub { inherit (pins.desktop) owner repo rev hash; };
  runtimeLibraries = with pkgs; [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    graphite2
    gtk3
    libdrm
    libgbm
    libglvnd
    libnotify
    libusb1
    libxkbcommon
    mesa
    nspr
    nss
    openssl
    pango
    pipewire
    systemd
    stdenv.cc.cc.lib
    tpm2-tss
    wayland
    xz
    zstd
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXScrnSaver
    libXtst
    libxcb
    libxcrypt-legacy
    zlib
  ];
  runtimeLibraryPath = lib.concatStringsSep ":" [
    "${pkgs.addDriverRunpath.driverLink}/lib"
    (lib.makeLibraryPath runtimeLibraries)
  ];
  curlWithGnuTlsCompat = (pkgs.curl.override {
    gnutlsSupport = true;
    http3Support = false;
    opensslSupport = false;
  }).overrideAttrs (previousAttrs: {
    postPatch = (previousAttrs.postPatch or "") + ''
      substituteInPlace lib/libcurl.vers.in \
        --replace-fail \
          'CURL_@CURL_LIBCURL_VERSIONED_SYMBOLS_PREFIX@@CURL_LIBCURL_VERSIONED_SYMBOLS_SONAME@' \
          'CURL_GNUTLS_3'
    '';
  });
  # The primary runtime's headless LibreOffice links libcurl.so.4 with
  # CURL_OPENSSL_4 symbol versions, while its Git links
  # libcurl-gnutls.so.4. The stock curl must precede the GnuTLS-compat
  # build so libcurl.so.4 resolves to OpenSSL versions and only the
  # distinct libcurl-gnutls.so.4 name reaches the compat build.
  workspaceRuntimeLibraries = runtimeLibraries ++ [
    pkgs.fontconfig
    pkgs.freetype
    pkgs.lcms2.out
    pkgs.curl.out
    curlWithGnuTlsCompat.out
  ];
  workspaceRuntimeLibraryPath = lib.concatStringsSep ":" [
    "${pkgs.addDriverRunpath.driverLink}/lib"
    (lib.makeLibraryPath workspaceRuntimeLibraries)
  ];
  baseRuntimePackages = with pkgs; [
    bash
    coreutils
    curl
    findutils
    gawk
    gnugrep
    gnused
    libnotify
    nodejs
    procps
    python3
    systemd
    util-linux
    xdg-utils
  ];
  featureRuntimePackages = featureIds:
    lib.optionals (lib.elem "appshots" featureIds) [ pkgs.xinput pkgs.xmodmap ]
    ++ lib.optionals (lib.elem "global-dictation" featureIds) [
      pkgs.xdotool
      pkgs.xinput
      pkgs.xmodmap
    ]
    ++ lib.optionals
      (
        lib.elem "read-aloud" featureIds || lib.elem "read-aloud-mcp" featureIds
      ) [ pkgs.alsa-utils ]
    ++ lib.optionals (lib.elem "computer-use-linux" featureIds) [ pkgs.glib ]
    ++ lib.optionals (lib.elem "account-switcher" featureIds) [ pkgs.libsecret ];
  runtimePathFor = featureIds:
    lib.makeBinPath (lib.unique (
      baseRuntimePackages ++ featureRuntimePackages featureIds
    ));
  genericRuntimeInterpreter = {
    x86_64-linux = "/lib64/ld-linux-x86-64.so.2";
    aarch64-linux = "/lib/ld-linux-aarch64.so.1";
  }.${system};
  dynamicLinker = pkgs.stdenv.cc.bintools.dynamicLinker;
  mkNixosBwrap = { realBwrap, runtimeInterpreter ? genericRuntimeInterpreter }:
    let
      source = pkgs.writeText "codex-desktop-nixos-bwrap.c" ''
        #define _XOPEN_SOURCE 700
        #include <errno.h>
        #include <stdio.h>
        #include <stdlib.h>
        #include <string.h>
        #include <unistd.h>

        static const char *real_bwrap = "${realBwrap}";
        static const char *generic_interpreter = "${runtimeInterpreter}";
        static const char *nix_ld = "${pkgs.nix-ld}/libexec/nix-ld";
        static const char *dynamic_linker = "${dynamicLinker}";
        static const char *runtime_library_path = "${workspaceRuntimeLibraryPath}";

        int main(int argc, char **argv) {
          int separator = -1;
          for (int index = 1; index < argc; index++) {
            if (strcmp(argv[index], "--") == 0) {
              separator = index;
              break;
            }
          }
          if (separator < 0) {
            execv(real_bwrap, argv);
            perror("execv real bubblewrap");
            return 127;
          }

          char *mount_destination = realpath(generic_interpreter, NULL);
          if (mount_destination == NULL) {
            if (errno == ENOENT) {
              fprintf(stderr,
                      "codex-desktop: generic interpreter %s is unavailable; "
                      "cached generic runtimes remain disabled\n",
                      generic_interpreter);
              execv(real_bwrap, argv);
              perror("execv real bubblewrap");
              return 127;
            }
            perror("resolve generic interpreter");
            return 127;
          }

          const int extra_count = 9;
          char **rewritten = calloc((size_t)argc + (size_t)extra_count + 1,
                                    sizeof(*rewritten));
          if (rewritten == NULL) {
            perror("allocate bubblewrap arguments");
            return 127;
          }

          int output = 0;
          for (int index = 0; index < separator; index++) {
            rewritten[output++] = argv[index];
          }
          rewritten[output++] = "--ro-bind";
          rewritten[output++] = (char *)nix_ld;
          rewritten[output++] = mount_destination;
          rewritten[output++] = "--setenv";
          rewritten[output++] = "NIX_LD";
          rewritten[output++] = (char *)dynamic_linker;
          rewritten[output++] = "--setenv";
          rewritten[output++] = "NIX_LD_LIBRARY_PATH";
          rewritten[output++] = (char *)runtime_library_path;
          for (int index = separator; index < argc; index++) {
            rewritten[output++] = argv[index];
          }
          rewritten[output] = NULL;
          execv(real_bwrap, rewritten);
          perror("execv real bubblewrap");
          return 127;
        }
      '';
    in
    pkgs.runCommandCC "codex-desktop-nixos-bwrap" { } ''
      mkdir -p "$out/bin"
      "$CC" -std=c11 -O2 -Wall -Wextra -Werror \
        -o "$out/bin/bwrap" ${source}
    '';
  nixosBwrap = mkNixosBwrap {
    realBwrap = "${pkgs.bubblewrap}/bin/bwrap";
  };
  nixRuntimeLauncher = pkgs.writeShellScript "codex-desktop-nix-runtime-launcher" ''
    set -euo pipefail
    [ "$#" -gt 0 ]
    if [[ -e /etc/NIXOS ]]; then
      export PATH="${nixosBwrap}/bin:''${PATH-}"
    fi
    exec "$@"
  '';
  gsettingsSchemaPackages = with pkgs; [ gsettings-desktop-schemas gtk3 ];
  gsettingsSchemaRoot = package:
    lib.removeSuffix "/glib-2.0/schemas" (pkgs.glib.getSchemaPath package);
  gsettingsSchemaDataDirs =
    lib.concatMapStringsSep ":" gsettingsSchemaRoot gsettingsSchemaPackages;
  xdgDefaultDataDirs = "/usr/local/share:/usr/share";
  emptyFeaturesConfig = pkgs.writeText "empty-features.json" ''{"enabled":[]}'';
  helperWorkspaceSource = pkgs.runCommand "codex-helper-workspace" { } ''
    mkdir -p "$out"
    cp -r ${sourceRoot}/{Cargo.toml,Cargo.lock,computer-use-linux,read-aloud-linux,record-replay-linux,updater} "$out/"
  '';
  staticCratesFetchurl = args: pkgs.fetchurl (args // {
    # The pinned nixpkgs importCargoLock fetcher still uses the crates.io
    # API endpoint, which rejects its fetches with HTTP 403. Rewrite only
    # that fetcher's URLs to the equivalent immutable CDN endpoint; the
    # fixed-output derivation still verifies every Cargo.lock checksum.
    url = lib.replaceStrings
      [ "https://crates.io/api/v1/crates" ]
      [ "https://static.crates.io/crates" ]
      args.url;
  });
  staticCratesImportCargoLock = pkgs.rustPlatform.importCargoLock.override {
    fetchurl = staticCratesFetchurl;
  };
  staticCratesBuildRustPackage = pkgs.rustPlatform.buildRustPackage.override {
    importCargoLock = staticCratesImportCargoLock;
  };

  mkWorkspaceHelpers = featureIds:
    let
      computerUseEnabled = lib.elem "computer-use-linux" featureIds;
      readAloudEnabled = lib.elem "read-aloud-mcp" featureIds;
      recordReplayBackendEnabled =
        lib.elem "chronicle-skysight" featureIds || lib.elem "record-and-replay" featureIds;
      cargoPackages =
        lib.optionals computerUseEnabled [ "codex-computer-use-linux" ]
        ++ lib.optionals readAloudEnabled [ "codex-read-aloud-linux" ]
        ++ lib.optionals recordReplayBackendEnabled [ "codex-record-replay-linux" ];
      expectedBinaries =
        lib.optionals computerUseEnabled [ "codex-computer-use-linux" "codex-computer-use-cosmic" ]
        ++ lib.optionals readAloudEnabled [ "codex-read-aloud-linux" ]
        ++ lib.optionals recordReplayBackendEnabled [ "codex-record-replay-linux" ];
    in
    if cargoPackages == [ ] then null else
    staticCratesBuildRustPackage {
      pname = "codex-desktop-feature-helpers";
      version = "0.1.0";
      src = helperWorkspaceSource;
      cargoLock.lockFile = ./Cargo.lock;
      cargoBuildFlags = lib.concatMap (package: [ "-p" package ]) cargoPackages;
      doCheck = false;
      installPhase = ''
        runHook preInstall
        mkdir -p "$out/bin"
        release="target/''${CARGO_BUILD_TARGET:-${pkgs.stdenv.hostPlatform.rust.rustcTarget}}/release"
        test -d "$release" || release=target/release
        ${lib.concatMapStringsSep "\n" (binary: ''
          test -x "$release/${binary}"
          install -m0755 "$release/${binary}" "$out/bin/${binary}"
        '') expectedBinaries}
        runHook postInstall
      '';
    };
  globalDictationHelper = staticCratesBuildRustPackage {
    pname = "codex-global-dictation-linux";
    version = "0.1.0";
    src = "${sourceRoot}/global-dictation-linux";
    cargoLock.lockFile = ./global-dictation-Cargo.lock;
    doCheck = false;
  };
  mcpReaperHelper = staticCratesBuildRustPackage {
    pname = "codex-mcp-helper-reaper";
    version = "0.1.0";
    src = "${sourceRoot}/linux-features/mcp-helper-reaper/reaper";
    cargoLock.lockFile = ./mcp-reaper-Cargo.lock;
    doCheck = false;
  };
  watchboundArtifacts = builtins.fromJSON (
    builtins.readFile ./watchbound-artifacts.json
  );
  watchboundVersion = watchboundArtifacts.version;
  watchboundSourceArchive = pkgs.fetchurl {
    name = "watchbound-${watchboundArtifacts.source.revision}.tar.gz";
    inherit (watchboundArtifacts.source) url sha256;
  };
  watchboundWrapperArchive = pkgs.fetchurl {
    name = "watchbound-${watchboundVersion}.tgz";
    inherit (watchboundArtifacts.packages.wrapper) url sha256;
  };
  watchboundLoaderArchive = pkgs.fetchurl {
    name = "watchbound-node-${watchboundVersion}.tgz";
    inherit (watchboundArtifacts.packages.loader) url sha256;
  };
  watchboundSource = pkgs.runCommandLocal "watchbound-${watchboundVersion}-source"
    {
      nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ];
    } ''
    mkdir -p "$out"
    tar -xzf ${watchboundSourceArchive} -C "$out" --strip-components=1
    chmod -R u+w "$out"
    for manifest in "$out/package.json" "$out/js/package.json" "$out/node/package.json"; do
      substituteInPlace "$manifest" \
        --replace-fail '"version": "0.0.0-development"' '"version": "${watchboundVersion}"'
    done
    substituteInPlace "$out/js/package.json" \
      --replace-fail '"@gadicc/watchbound-node": "workspace:0.0.0-development"' \
        '"@gadicc/watchbound-node": "workspace:${watchboundVersion}"'
    substituteInPlace "$out/Cargo.toml" \
      --replace-fail 'version = "0.0.0-development"' 'version = "${watchboundVersion}"'
    substituteInPlace "$out/Cargo.lock" \
      --replace-fail 'version = "0.0.0-development"' 'version = "${watchboundVersion}"'
    substituteInPlace "$out/pnpm-lock.yaml" \
      --replace-fail 'specifier: workspace:0.0.0-development' \
        'specifier: workspace:${watchboundVersion}'
  '';
  watchboundTarget = {
    x86_64-linux = {
      id = "linux-x64-gnu";
      rustTarget = "x86_64-unknown-linux-gnu";
      binary = "watchbound.linux-x64-gnu.node";
      electronArch = "x64";
    };
    aarch64-linux = {
      id = "linux-arm64-gnu";
      rustTarget = "aarch64-unknown-linux-gnu";
      binary = "watchbound.linux-arm64-gnu.node";
      electronArch = "arm64";
    };
  }.${system};
  watchboundNative = staticCratesBuildRustPackage {
    pname = "watchbound-native-${watchboundTarget.id}";
    version = watchboundVersion;
    src = watchboundSource;
    cargoLock.lockFile = ./watchbound-Cargo.lock;
    cargoBuildFlags = [ "-p" "watchbound-node" ];
    doCheck = false;
    installPhase = ''
      runHook preInstall
      release="target/''${CARGO_BUILD_TARGET:-${watchboundTarget.rustTarget}}/release"
      test -f "$release/libwatchbound_node.so" || release=target/release
      test -f "$release/libwatchbound_node.so"
      install -Dm0555 "$release/libwatchbound_node.so" \
        "$out/lib/${watchboundTarget.binary}"
      runHook postInstall
    '';
  };
  watchboundPackage = pkgs.stdenv.mkDerivation {
    pname = "watchbound-node-package-${watchboundTarget.id}";
    version = watchboundVersion;
    src = watchboundSource;
    nativeBuildInputs = [ pkgs.gnutar pkgs.gzip pkgs.nodejs_24 ];
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      node scripts/generate-nix-package.mjs \
        --target ${watchboundTarget.id} \
        --artifact ${watchboundNative}/lib/${watchboundTarget.binary} \
        --output "$out"
      rm -rf \
        "$out/lib/node_modules/watchbound" \
        "$out/lib/node_modules/@gadicc/watchbound-node"
      mkdir -p \
        "$out/lib/node_modules/watchbound" \
        "$out/lib/node_modules/@gadicc/watchbound-node"
      tar -xzf ${watchboundWrapperArchive} \
        -C "$out/lib/node_modules/watchbound" --strip-components=1
      tar -xzf ${watchboundLoaderArchive} \
        -C "$out/lib/node_modules/@gadicc/watchbound-node" --strip-components=1
      node ${sourceRoot}/linux-features/directory-only-working-tree-watch/watchbound-package.js \
        --verify-controlled-package-root "$out/lib/node_modules" ${watchboundTarget.electronArch}
      runHook postInstall
    '';
  };
  mkCodexDesktop =
    { linuxFeatureIds ? [ ]
    , enableComputerUseUi ? false
    ,
    }:
    let
      userFeatureIds = nixLinuxFeatures.normalize (
        linuxFeatureIds ++ lib.optional enableComputerUseUi "computer-use-linux"
      );
      internalNixFeatureIds = [ "nix-store-bundled-marketplace-permissions" ];
      effectiveFeatureIds = nixLinuxFeatures.normalizeAll (
        userFeatureIds ++ internalNixFeatureIds
      );
      recordReplayBackendEnabled =
        lib.elem "chronicle-skysight" effectiveFeatureIds
        || lib.elem "record-and-replay" effectiveFeatureIds;
      workspaceHelpers = mkWorkspaceHelpers effectiveFeatureIds;
      watchboundEnabled = lib.elem "directory-only-working-tree-watch" effectiveFeatureIds;
      codexMicroEnabled = lib.elem "codex-micro" effectiveFeatureIds;
      featuresConfig = pkgs.writeText "codex-linux-features.json" (builtins.toJSON {
        enabled = effectiveFeatureIds;
      });
      suffix = if userFeatureIds == [ ] then "" else "-${lib.concatStringsSep "-" userFeatureIds}";
    in
    pkgs.stdenv.mkDerivation {
      pname = "codex-desktop${suffix}";
      version = codexVersion;
      src = sourceRoot;
      # This derivation's fail-closed audit owns ELF interpreters and
      # RUNPATHs. Generic fixups would shrink them again and cannot
      # safely strip the current amd64 Tectonic payload.
      dontPatchELF = true;
      dontStrip = true;
      dontFixup = true;
      nativeBuildInputs = [
        pkgs.asar
        pkgs.bash
        pkgs.coreutils
        pkgs.curl
        pkgs.dpkg
        pkgs.gnupg
        pkgs.makeWrapper
        pkgs.nodejs
        pkgs.patchelf
        pkgs.python3
        pkgs.util-linux
      ];
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        runHook preInstall
        export HOME="$TMPDIR/home"
        export SOURCE_DATE_EPOCH="${flakeSourceDateEpoch}"
        mkdir -p "$HOME"
        source_dir="$TMPDIR/source"
        cp -R "$src" "$source_dir"
        chmod -R u+w "$source_dir"
        upstream_contract_root="$TMPDIR/upstream-contract"
        mkdir -p "$upstream_contract_root"
        dpkg-deb -x ${upstreamDeb} "$upstream_contract_root"
        node "$source_dir/nix/elf-runtime.cjs" validate-upstream \
          --root "$upstream_contract_root/usr/lib/chatgpt" \
          --arch ${officialPackage.architecture}
        export CODEX_ASAR_BIN="${pkgs.asar}/bin/asar"
        export CODEX_INSTALL_TRANSACTION_ACTIVE=1
        export CODEX_INSTALL_DIR="$out/opt/codex-desktop"
        export CODEX_LINUX_FEATURES_CONFIG="${featuresConfig}"
        export CODEX_INTERNAL_LINUX_FEATURE_IDS="${lib.concatStringsSep "," internalNixFeatureIds}"
        ${lib.optionalString (flakeSourceCommit != "") ''
        export CODEX_LINUX_SOURCE_COMMIT="${flakeSourceCommit}"
        export CODEX_LINUX_SOURCE_REMOTE="${flakeSourceRemote}"
        ''}
        ${lib.optionalString (lib.elem "computer-use-linux" effectiveFeatureIds) ''
        export CODEX_COMPUTER_USE_BINARY_SOURCE="${workspaceHelpers}/bin/codex-computer-use-linux"
        export CODEX_COMPUTER_USE_COSMIC_BINARY_SOURCE="${workspaceHelpers}/bin/codex-computer-use-cosmic"
        ''}
        ${lib.optionalString (lib.elem "read-aloud-mcp" effectiveFeatureIds) ''
        export CODEX_LINUX_READ_ALOUD_MCP_SOURCE="${workspaceHelpers}/bin/codex-read-aloud-linux"
        ''}
        ${lib.optionalString recordReplayBackendEnabled ''
        export CODEX_RECORD_REPLAY_LINUX_SOURCE="${workspaceHelpers}/bin/codex-record-replay-linux"
        ''}
        ${lib.optionalString (lib.elem "global-dictation" effectiveFeatureIds) ''
        export CODEX_GLOBAL_DICTATION_LINUX_SOURCE="${globalDictationHelper}/bin/codex-global-dictation-linux"
        ''}
        ${lib.optionalString (lib.elem "mcp-helper-reaper" effectiveFeatureIds) ''
        export CODEX_MCP_HELPER_REAPER_SOURCE="${mcpReaperHelper}/bin/codex-mcp-helper-reaper"
        ''}
        ${lib.optionalString watchboundEnabled ''
        export CODEX_WATCHBOUND_PACKAGE_ROOT="${watchboundPackage}/lib/node_modules"
        ''}
        bash "$source_dir/install.sh" "${upstreamDeb}"

        app="$out/opt/codex-desktop"
        test -d "$app"
        node "$source_dir/scripts/ci/validate-patch-report.js" \
          "$app/.codex-linux/patch-report.json" \
          --require-enabled-feature nix-store-bundled-marketplace-permissions
        dynamic_linker="$(cat ${pkgs.stdenv.cc}/nix-support/dynamic-linker)"
        node "$source_dir/nix/elf-runtime.cjs" fix \
          --root "$app" \
          --arch ${officialPackage.architecture} \
          --dynamic-linker "$dynamic_linker" \
          --runtime-library-path "${runtimeLibraryPath}" \
          --patchelf "${pkgs.patchelf}/bin/patchelf" \
          --chatgpt-relocator "$source_dir/nix/relocate-elf-interpreter.cjs"
        patchShebangs --build "$app"

        install -Dm0644 "$app/.codex-linux/codex-desktop.png" \
          "$out/share/icons/hicolor/256x256/apps/codex-desktop.png"
        ${lib.optionalString codexMicroEnabled ''
        install -Dm0644 \
          "$source_dir/linux-features/codex-micro/resources/70-codex-micro.rules" \
          "$out/lib/udev/rules.d/70-codex-micro.rules"
        ''}
        mkdir -p "$out/share/applications"
        awk '
          /^\[Desktop Action CheckForUpdates\]$/ { skip = 1; next }
          /^\[Desktop Action InstallReadyUpdate\]$/ { skip = 1; next }
          /^\[/ { skip = 0 }
          skip { next }
          /^Actions=/ { print "Actions=new-window;"; next }
          { print }
        ' "$source_dir/packaging/linux/codex-desktop.desktop" \
          > "$out/share/applications/codex-desktop.desktop"
        substituteInPlace "$out/share/applications/codex-desktop.desktop" \
          --replace-fail "/usr/bin/codex-desktop" "$out/bin/codex-desktop" \
          --replace-fail "/usr/share/applications/codex-desktop.desktop" "$out/share/applications/codex-desktop.desktop"
        makeWrapper "${nixRuntimeLauncher}" "$out/bin/codex-desktop" \
          --prefix PATH : "${runtimePathFor effectiveFeatureIds}" \
          --set-default ALSA_PLUGIN_DIR "${pkgs.pipewire}/lib/alsa-lib" \
          --set-default CODEX_OZONE_PLATFORM x11 \
          --run 'export XDG_DATA_DIRS="''${XDG_DATA_DIRS:-${xdgDefaultDataDirs}}"' \
          --prefix XDG_DATA_DIRS : "${gsettingsSchemaDataDirs}" \
          --set-default BAMF_DESKTOP_FILE_HINT "$out/share/applications/codex-desktop.desktop" \
          --set-default CODEX_CLI_PATH "$app/resources/codex" \
          --add-flags "$app/start.sh"
        node "$source_dir/nix/elf-runtime.cjs" audit \
          --root "$app" \
          --arch ${officialPackage.architecture} \
          --dynamic-linker "$dynamic_linker" \
          --runtime-library-path "${runtimeLibraryPath}" \
          --patchelf "${pkgs.patchelf}/bin/patchelf"
        node "$source_dir/nix/relocate-elf-interpreter.cjs" check \
          "$app/ChatGPT" "$dynamic_linker"
        runHook postInstall
      '';
      passthru = {
        linuxFeatureIds = userFeatureIds;
        effectiveLinuxFeatureIds = effectiveFeatureIds;
        inherit upstreamDeb workspaceRuntimeLibraries;
        upstreamVersion = codexVersion;
        upstreamArchitecture = officialPackage.architecture;
      };
      meta = {
        description = "Custom codex-desktop distribution based on OpenAI's official Linux package";
        homepage = "https://github.com/ilysenko/codex-desktop-linux";
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" "aarch64-linux" ];
        mainProgram = "codex-desktop";
      };
    };

in
lib.makeOverridable mkCodexDesktop { }
