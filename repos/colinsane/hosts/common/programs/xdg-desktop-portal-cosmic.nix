{ config, pkgs, ... }:
let
  cfg = config.sane.programs.xdg-desktop-portal-cosmic;
in
{
  sane.programs.xdg-desktop-portal-cosmic = {
    packageUnwrapped = pkgs.xdg-desktop-portal-cosmic.overrideAttrs (base: {
      # XXX(2025-11-24): this might not *all* be necessary, but without this it fails on launch:
      # > Create event loop: Os(OsError { line: 63, file: "/build/xdg-desktop-portal-cosmic-1.0.0-beta.7-vendor/winit-0.30.5/src/platform_impl/linux/wayland/event_loop/mod.rs", error: NoWaylandLib })
      buildInputs = (base.buildInputs or []) ++ (with pkgs; [
        # dlopen'd dependencies:
        libglvnd
        libxkbcommon
        vulkan-loader
        wayland
      ]);
      # Force linking to libEGL, which is always dlopen()ed, and to
      # libwayland-client & libxkbcommon, which is dlopen()ed based on the
      # winit backend.
      # from <repo:nixos/nixpkgs:pkgs/by-name/uk/ukmm/package.nix>
      NIX_LDFLAGS = [
        "--push-state"
        "--no-as-needed"
        "-lEGL"
        "-lvulkan"
        "-lwayland-client"
        "-lxkbcommon"
        "--pop-state"
      ];
    });

    sandbox.method = null;  #< TODO: sandbox

    services.xdg-desktop-portal-cosmic = {
      description = "xdg-desktop-portal-cosmic backend (provides FileChooser; Access, Screenshot, Settings, ScreenCast)";
      dependencyOf = [ "xdg-desktop-portal" ];
      command = "${cfg.package}/libexec/xdg-desktop-portal-cosmic";
      readiness.waitDbus = "org.freedesktop.impl.portal.desktop.cosmic";
    };
  };
}

