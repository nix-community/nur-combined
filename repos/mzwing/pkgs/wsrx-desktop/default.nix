{
  lib,
  pkgs,
  source,
}: let
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  # Linux link-time and runtime desktop libraries for the GPUI/wgpu renderer.
  linuxDesktopLibraries = with pkgs; [
    fontconfig
    freetype
    libGL
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
    vulkan-loader
    wayland
  ];

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

        # Link the vendored AWS-LC through its CMake builder.
        aws-lc-sys = attrs: {
          nativeBuildInputs = with pkgs; [cmake perl];
          env.AWS_LC_SYS_CMAKE_BUILDER = "1";
        };

        # Resolve libxkbcommon, which the crate links through `#[link]` without a build script.
        xkbcommon = attrs: {
          propagatedBuildInputs = [pkgs.libxkbcommon];
        };

        # Probe fontconfig for font-kit, the font source GPUI uses on Linux.
        yeslogic-fontconfig-sys = attrs: {
          nativeBuildInputs = [pkgs.pkg-config];
          propagatedBuildInputs = [pkgs.fontconfig];
        };

        # Keep wayland linkable for consumers that drop the crate's dlopen feature.
        wayland-sys = attrs: {
          nativeBuildInputs = [pkgs.pkg-config];
          propagatedBuildInputs = [pkgs.wayland];
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
        description = "Controlled TCP-over-WebSocket forwarding tunnel (GUI version)";
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
