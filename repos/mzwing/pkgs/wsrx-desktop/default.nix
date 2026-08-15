{
  lib,
  pkgs,
  source,
}: let
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  # Native libraries the desktop binary links against on Linux. The final
  # link happens in the wsrx-desktop crate derivation, and most of these
  # are additionally dlopen'ed at runtime (see postInstall's wrapProgram).
  # Mirrors the library list of the upstream flake.
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

  # Prebuilt Skia consumed by skia-bindings through SKIA_BINARIES_URL
  # (file:// URLs are supported). URL and hash are coupled — the tarball
  # name embeds the skia-bindings crate version (the release tag), the
  # upstream skia commit and the feature key of the enabled Linux
  # features — so they live in ./pins.json, which is kept in sync with
  # the regenerated Cargo.nix by this package's passthru.pinUpdater
  # (`nix run .#update-pins`, assets:
  # https://github.com/rust-skia/skia-binaries/releases). The tarballs
  # are static .a archives, so no patchelf/FHS handling is needed.
  pins = lib.importJSON ./pins.json;

  # Nix system -> Rust target triple used in the release asset names.
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

  # ./Cargo.nix (next to this file) is generated with `crate2nix generate`
  # at the upstream source root by the update script
  # (scripts/package-updates) and committed to this repository. Building it
  # needs no crate2nix at evaluation or build time, only nixpkgs'
  # buildRustCrate.
  cargoNix = import ./Cargo.nix {
    inherit pkgs;
    # nixpkgs' buildRustCrate defaults to -C codegen-units=1 (crate2nix
    # does not propagate the workspace profile), which serialises LLVM
    # codegen per crate; the WebRTC/Slint crates in this graph then need
    # 5+ hours each — beyond the 6-hour CI job limit, so they can never
    # finish. 16 units matches Cargo's own release default.
    buildRustCrateForPkgs = pkgs: pkgs.buildRustCrate.override { defaultCodegenUnits = 16; };
    defaultCrateOverrides =
      pkgs.defaultCrateOverrides
      // {
        # Workspace members. The generated file points each member's src
        # at ./crates/<dir> relative to the committed Cargo.nix, which
        # does not exist in this repository; those path thunks are never
        # forced once src is overridden here. Crate names differ from
        # directory names (wsrx-desktop lives in crates/desktop), so the
        # mapping is explicit.
        wsrx = attrs: {
          src = source.src;
          workspace_member = "crates/wsrx";
        };
        wsrx-desktop = attrs: {
          src = source.src;
          workspace_member = "crates/desktop";
          nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
          buildInputs = (attrs.buildInputs or []) ++ linuxDesktopLibraries;
          # build.rs reads this instead of probing git inside the sandbox.
          env.WSRX_GIT_VERSION = version;
        };

        # Environment variables Cargo provides but buildRustCrate does
        # not. CARGO_CRATE_NAME is the underscore-normalized crate name;
        # build-target 0.8.0 reads it with env!() at compile time.
        build-target = attrs: {
          env.CARGO_CRATE_NAME = "build_target";
        };
        # Cargo always exports CARGO_ENCODED_RUSTFLAGS to build scripts,
        # even when no extra rustflags are configured; buildRustCrate
        # does not, and the rust-av crates' build.rs files unwrap it
        # (av-scenechange 0.14.1 build.rs:250, rav1e 0.8.1 build.rs:277).
        # The empty string accurately encodes the absent rustflags and
        # lets the rav1e -> ravif -> image dependency chain build.
        av-scenechange = attrs: {
          env.CARGO_ENCODED_RUSTFLAGS = "";
        };
        rav1e = attrs: {
          env.CARGO_ENCODED_RUSTFLAGS = "";
        };

        # Use the prebuilt Skia binaries (the fetchurl FODs above)
        # instead of building Skia from source; bindgen still runs and
        # needs libclang. Linux-only (skiaBinaries has no entries for
        # other systems, and this package targets Linux only).
        skia-bindings = attrs:
          lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
            env.SKIA_BINARIES_URL = "file://${skiaBinaries.${pkgs.stdenv.hostPlatform.system}}";
            env.LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
            # The prebuilt textlayout binaries resolve fontconfig/freetype
            # symbols at the final link; the gl feature links libGL.
            propagatedBuildInputs = with pkgs; [
              fontconfig
              freetype
              libGL
            ];
          };

        # Native libraries of -sys crates only reach the final link via
        # propagatedBuildInputs (buildRustCrate's
        # completePropagatedBuildInputs); plain buildInputs on the -sys
        # crate would stay local to that crate's build.
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
          # nixpkgs' default override only sets buildInputs, which does
          # not propagate to the final link.
          nativeBuildInputs = [pkgs.pkg-config];
          propagatedBuildInputs = [pkgs.udev];
        };
      };
  };

  wsrxDesktop = cargoNix.workspaceMembers."wsrx-desktop".build;
in
  wsrxDesktop.overrideAttrs (old: {
    # crate2nix names the derivation rust_wsrx-desktop-<crate version>.
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
        # Package pin updater, run by the generic `nix run .#update-pins`
        # pipeline from the repository root. It derives the Skia
        # version/commit/feature key from the committed Cargo.nix and
        # rewrites ./pins.json (URL and hash must change together, so
        # this is not handled by update-hashes/nix-update). See
        # scripts/package-updates/README.md for the interface contract.
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
          # The shared helper library is injected by path; shellcheck
          # cannot follow it (SC1090/SC1091) and does not see runtimeEnv
          # variables as assigned (SC2154).
          excludeShellChecks = [
            "SC1090"
            "SC1091"
            "SC2154"
          ];
          runtimeEnv.PIN_UTILS = ../../scripts/package-updates/lib/pin-utils.sh;
          text = builtins.readFile ./update-pins.sh;
        };
      };

    # The GUI binary is not executed here: it needs a display.
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
