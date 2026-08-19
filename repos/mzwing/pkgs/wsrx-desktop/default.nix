{
  lib,
  pkgs,
  source,
}: let
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  # Linux link-time and runtime desktop libraries from the upstream flake.
  linuxDesktopLibraries = with pkgs; [
    fontconfig
    freetype
    libGL
    libdrm
    libgbm
    libinput
    libx11
    libxcb
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
    libxcursor
    libxi
    libxkbcommon
    libxkbfile
    libxrandr
    wayland
  ];

  # Coupled Skia asset URLs and hashes maintained by the package pin updater.
  pins = lib.importJSON ./pins.json;

  # Rust targets used in Skia asset names.
  skiaTargets = {
    x86_64-linux = "x86_64-unknown-linux-gnu";
    aarch64-linux = "aarch64-unknown-linux-gnu";
  };

  skiaBinaries =
    lib.mapAttrs (
      system: target:
        pkgs.fetchurl {
          url = "https://github.com/rust-skia/skia-binaries/releases/download/${pins.skia.version}/skia-binaries-${pins.skia.commit}-${target}-${pins.skia.features}.tar.gz";
          hash = pins.skia.hashes.${system};
        }
    )
    skiaTargets;

  # Use the committed crate2nix graph; builds only need nixpkgs' buildRustCrate.
  cargoNix = import ./Cargo.nix {
    inherit pkgs;
    # Match Cargo's 16 release codegen units to keep CI builds within the job limit.
    buildRustCrateForPkgs = pkgs: pkgs.buildRustCrate.override {defaultCodegenUnits = 16;};
    defaultCrateOverrides =
      pkgs.defaultCrateOverrides
      // {
        # Map crate names to fetched workspace directories.
        wsrx = attrs: {
          src = source.src;
          workspace_member = "crates/wsrx";
        };
        wsrx-desktop = attrs: {
          src = source.src;
          workspace_member = "crates/desktop";
          nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
          buildInputs = (attrs.buildInputs or []) ++ linuxDesktopLibraries;
          # Avoid probing git in the sandbox.
          env.WSRX_GIT_VERSION = version;
        };

        # Provide Cargo's normalized crate name to build-target.
        build-target = attrs: {
          env.CARGO_CRATE_NAME = "build_target";
        };
        # Provide Cargo's empty encoded rustflags expected by rust-av build scripts.
        av-scenechange = attrs: {
          env.CARGO_ENCODED_RUSTFLAGS = "";
        };
        rav1e = attrs: {
          env.CARGO_ENCODED_RUSTFLAGS = "";
        };

        # Use prebuilt Skia while keeping libclang available for bindgen.
        skia-bindings = attrs:
          lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
            env.SKIA_BINARIES_URL = "file://${skiaBinaries.${pkgs.stdenv.hostPlatform.system}}";
            env.LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
            # Propagate libraries required by prebuilt Skia features.
            propagatedBuildInputs = with pkgs; [
              fontconfig
              freetype
              libGL
            ];
          };

        # Propagate native `-sys` libraries to the final link.
        wayland-sys = attrs: {
          nativeBuildInputs = [pkgs.pkg-config];
          propagatedBuildInputs = [pkgs.wayland];
        };
        gbm-sys = attrs: {
          propagatedBuildInputs = [pkgs.libgbm];
        };
        drm-sys = attrs: {
          propagatedBuildInputs = [pkgs.libdrm];
        };
        input-sys = attrs: {
          propagatedBuildInputs = [pkgs.libinput];
        };
        xkeysym = attrs: {
          propagatedBuildInputs = [pkgs.libxcb-keysyms];
        };
        libudev-sys = attrs: {
          # Propagate udev to the final link.
          nativeBuildInputs = [pkgs.pkg-config];
          propagatedBuildInputs = [pkgs.udev];
        };
      };
  };

  wsrxDesktop = cargoNix.workspaceMembers."wsrx-desktop".build;
in
  wsrxDesktop.overrideAttrs (old: {
    # Replace the crate2nix derivation name.
    name = "${pname}-${version}";

    postInstall = ''
      install -Dm644 \
        ${src}/freedesktop/wsrx-desktop.desktop \
        -t $out/share/applications
      install -Dm644 \
        ${src}/freedesktop/wsrx-desktop.svg \
        -t $out/share/icons/hicolor/scalable/apps

      wrapProgram $out/bin/wsrx-desktop \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath linuxDesktopLibraries}
    '';

    passthru =
      (old.passthru or {})
      // {
        # Update coupled Skia asset pins through the generic pin pipeline.
        pinUpdater = pkgs.writeShellApplication {
          name = "wsrx-desktop-update-pins";
          runtimeInputs = with pkgs; [
            coreutils
            curl
            gawk
            gnugrep
            jq
            nix
          ];
          # Ignore shellcheck errors caused by the runtime-injected helper path.
          excludeShellChecks = [
            "SC1090"
            "SC1091"
            "SC2154"
          ];
          runtimeEnv.PIN_UTILS = ../../scripts/package-updates/lib/pin-utils.sh;
          text = builtins.readFile ./update-pins.sh;
        };
      };

    # Skip executing the GUI without a display.
    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      test -x $out/bin/wsrx-desktop
      test -f $out/share/applications/wsrx-desktop.desktop
      test -f $out/share/icons/hicolor/scalable/apps/wsrx-desktop.svg

      runHook postInstallCheck
    '';

    meta =
      old.meta
      // {
        description = "Desktop interface for WebSocketReflectorX";
        homepage = "https://github.com/XDSEC/WebSocketReflectorX";
        changelog = "https://github.com/XDSEC/WebSocketReflectorX/releases/tag/${version}";
        license = lib.licenses.mit;
        mainProgram = "wsrx-desktop";
        maintainers = [
          {
            name = "mzwing";
          }
        ];
        platforms = [
          "x86_64-linux"
          "aarch64-linux"
        ];
      };
  })
