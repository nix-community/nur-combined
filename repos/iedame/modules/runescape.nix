# RuneScape on NixOS: the Jagex Launcher (../pkgs/jagex-launcher) plus
# RuneLite, and the glue that makes "Play" work. Import it and set:
#
#     programs.runescape.enable = true;
#     programs.runescape.users  = [ "yourusername" ];
#
# It assumes home-manager is used as a NixOS module (the
# `home-manager.nixosModules.home-manager` import). If you use standalone
# home-manager instead, see the note at the bottom of this file.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.runescape;

  jagex-launcher = pkgs.callPackage ../pkgs/jagex-launcher/package.nix { };

  ##########################################################################
  # The RuneLite shim  --  this is the part that makes it all work
  #
  # The Jagex Launcher manages RuneLite itself: it downloads a plain
  # generic-Linux RuneLite.AppImage into
  # ~/.local/share/Jagex Launcher/games/runelite/ and execs it directly,
  # ignoring any Nix-packaged client.
  #
  # That AppImage is broken on NixOS even with appimage-run/binfmt enabled:
  # RuneLite's own launcher downloads and verifies the client jars (the
  # splash screen), then in its default FORK launch mode *re-executes the
  # AppImage itself* (`RuneLite.AppImage -c ...`) to spawn the client JVM.
  # That re-exec bounces back through binfmt and dies silently -- the splash
  # closes and no client ever appears.
  #
  # nixpkgs' `runelite` resolves to JVM launch mode instead, spawning the
  # client as a normal nix-wrapped java subprocess. So: replace the
  # launcher-managed RuneLite.AppImage with a shell script that execs
  # nixpkgs' runelite. The launcher execs that path with your Jagex session
  # in JX_* environment variables, the shim forwards them straight through,
  # and the client picks up the Jagex login as normal.
  #
  # The shim starts with a #! line so binfmt leaves it alone. The real game
  # client jars still self-update at runtime -- only the outer launcher
  # binary is replaced.
  ##########################################################################
  runeliteShim = pkgs.writeShellScript "runelite-jagex-shim" ''
    exec ${lib.getExe cfg.runelitePackage} ${lib.escapeShellArgs cfg.runeliteFlags} "$@"
  '';

  installPath = homeDir: "${homeDir}/.local/share/Jagex Launcher/games/runelite/RuneLite.AppImage";

  # The home-manager side: the packages plus an activation script that keeps
  # the shim in place.
  # NOTE: `lib` here is home-manager's lib (it carries `lib.hm.dag`), not the
  # NixOS one from the outer module arguments.
  hmModule =
    { config, lib, ... }:
    {
      home.packages = [
        jagex-launcher
        cfg.runelitePackage
      ];

      # Once the launcher has installed RuneLite (i.e. the directory exists),
      # re-point that path at our shim on every activation. Guarded on
      # existence so we never interfere with the launcher's initial download.
      #
      # NOTE: if RuneLite stops launching again (splash appears, then
      # vanishes), the launcher has re-downloaded the real RuneLite.AppImage
      # over this shim during an update. Just rebuild
      # (`sudo nixos-rebuild switch`) and this re-installs the shim.
      home.activation.jagexRuneliteShim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -d "$(dirname "${installPath config.home.homeDirectory}")" ]; then
          run install -m555 ${runeliteShim} "${installPath config.home.homeDirectory}"
        fi
      '';
    };
in
{
  options.programs.runescape = {
    enable = lib.mkEnableOption "the Jagex Launcher and RuneLite";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "alice" ];
      description = ''
        Usernames to install the launcher and RuneLite for. Each must already
        have a `home-manager.users.<name>` entry.
      '';
    };

    runelitePackage = lib.mkPackageOption pkgs "runelite" { };

    runeliteFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      # HiDPI displays want something like [ "--scale=2.0" ].
      example = [ "--scale=2.0" ];
      description = "Extra flags passed to runelite when launched via the Jagex Launcher.";
    };

    launcherPackage = lib.mkOption {
      type = lib.types.package;
      default = jagex-launcher;
      readOnly = true;
      description = "The packaged Jagex Launcher, exposed for reuse elsewhere.";
    };
  };

  config = lib.mkIf cfg.enable {
    # The AppImage the launcher downloads is a "generic Linux" dynamically
    # linked binary, which NixOS cannot execute out of the box. Without
    # binfmt registration the launcher's exec fails silently and clicking
    # Play appears to do nothing at all.
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    # NOTE: the Jagex Launcher is unfree, so you need one of
    #   nixpkgs.config.allowUnfree = true;
    # or an allowUnfreePredicate that lets "jagex-launcher" through. This
    # module deliberately does not set either, since defining
    # allowUnfreePredicate twice conflicts with your own config.

    home-manager.users = lib.genAttrs cfg.users (_: hmModule);
  };
}

# ---------------------------------------------------------------------------
# Using standalone home-manager instead?
#
# Split it: put the NixOS half in configuration.nix --
#
#     programs.appimage = { enable = true; binfmt = true; };
#
# -- and in your home.nix, inline the `jagex-launcher` derivation and the
# `runeliteShim` / `home.activation.jagexRuneliteShim` blocks from above.
# Nothing else in this file is NixOS-specific.
# ---------------------------------------------------------------------------
