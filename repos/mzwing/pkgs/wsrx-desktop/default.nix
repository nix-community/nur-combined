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
  # (file:// URLs are supported). The tarball name embeds the
  # skia-bindings crate version (the release tag, 0.99.0), the upstream
  # skia commit (a25a0fdb7d90429aa2d1) and the feature key slint's skia
  # renderer enables on Linux (gl-jpegd-jpege-pdf-textlayout-vulkan); all
  # three must be updated together whenever a regenerated Cargo.nix bumps
  # skia-bindings (assets: https://github.com/rust-skia/skia-binaries/releases).
  skiaBinaries = {
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/rust-skia/skia-binaries/releases/download/0.99.0/skia-binaries-a25a0fdb7d90429aa2d1-x86_64-unknown-linux-gnu-gl-jpegd-jpege-pdf-textlayout-vulkan.tar.gz";
      hash = "sha256-CX5413XJFW3EsHC5zKcAjbq1h1E+yxkkuvTPliDzEZs=";
    };
    aarch64-linux = pkgs.fetchurl {
      url = "https://github.com/rust-skia/skia-binaries/releases/download/0.99.0/skia-binaries-a25a0fdb7d90429aa2d1-aarch64-unknown-linux-gnu-gl-jpegd-jpege-pdf-textlayout-vulkan.tar.gz";
      sha256 = "ffe0e2e22113c0eee5699187943e24bec8bc85b13411102101fee132ac96f42b";
    };
  };

  # ./Cargo.nix (next to this file) is generated with `crate2nix generate`
  # at the upstream source root by the update script
  # (scripts/package-updates) and committed to this repository. Building it
  # needs no crate2nix at evaluation or build time, only nixpkgs'
  # buildRustCrate.
  cargoNix = import ./Cargo.nix {
    inherit pkgs;
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
