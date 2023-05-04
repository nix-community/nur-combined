{ lib, pkgs, ... }:
{
  imports = [
    ./cross
    ./feeds.nix
    ./fs.nix
    ./hardware.nix
    ./home
    ./i2p.nix
    ./ids.nix
    ./machine-id.nix
    ./net.nix
    ./persist.nix
    ./programs
    ./secrets.nix
    ./ssh.nix
    ./users.nix
    ./vpn.nix
  ];

  sane.nixcache.enable-trusted-keys = true;
  sane.nixcache.enable = lib.mkDefault true;
  sane.persist.enable = lib.mkDefault true;
  sane.programs.sysadminUtils.enableFor.system = lib.mkDefault true;
  sane.programs.consoleUtils.enableFor.user.colin = lib.mkDefault true;

  # some services which use private directories error if the parent (/var/lib/private) isn't 700.
  sane.fs."/var/lib/private".dir.acl.mode = "0700";

  nixpkgs.config.allowUnfree = true;

  # time.timeZone = "America/Los_Angeles";
  time.timeZone = "Etc/UTC";  # DST is too confusing for me => use a stable timezone

  # allow `nix flake ...` command
  # TODO: is this still required?
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  # allow `nix-shell` (and probably nix-index?) to locate our patched and custom packages
  nix.nixPath = [
    "nixpkgs=${pkgs.path}"
    "nixpkgs-overlays=${../..}/overlays"
  ];
  # hardlinks identical files in the nix store to save 25-35% disk space.
  # unclear _when_ this occurs. it's not a service.
  # does the daemon continually scan the nix store?
  # does the builder use some content-addressed db to efficiently dedupe?
  nix.settings.auto-optimise-store = true;

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [ font-awesome noto-fonts-emoji hack-font ];
    fontconfig.enable = true;
    fontconfig.defaultFonts = {
      emoji = [ "Font Awesome 6 Free" "Noto Color Emoji" ];
      monospace = [ "Hack" ];
      serif = [ "DejaVu Serif" ];
      sansSerif = [ "DejaVu Sans" ];
    };
  };

  # XXX: twitter-color-emoji doesn't cross-compile; but not-fonts-emoji does
  # fonts = {
  #   enableDefaultFonts = true;
  #   fonts = with pkgs; [ font-awesome twitter-color-emoji hack-font ];
  #   fontconfig.enable = true;
  #   fontconfig.defaultFonts = {
  #     emoji = [ "Font Awesome 6 Free" "Twitter Color Emoji" ];
  #     monospace = [ "Hack" ];
  #     serif = [ "DejaVu Serif" ];
  #     sansSerif = [ "DejaVu Sans" ];
  #   };
  # };

  # disable non-required packages like nano, perl, rsync, strace
  environment.defaultPackages = [];

  # programs.vim.defaultEditor = true;
  environment.variables = {
    EDITOR = "vim";
    # git claims it should use EDITOR, but it doesn't!
    GIT_EDITOR = "vim";
    # TODO: these should be moved to `home.sessionVariables` (home-manager)
    # Electron apps should use native wayland backend:
    #   https://nixos.wiki/wiki/Slack#Wayland
    # Discord under sway crashes with this.
    # NIXOS_OZONE_WL = "1";
    # LIBGL_ALWAYS_SOFTWARE = "1";
  };

  # dconf docs: <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/desktop_migration_and_administration_guide/profiles>
  # find keys/values with `dconf dump /`
  programs.dconf.enable = true;
  programs.dconf.packages = [
    (pkgs.writeTextFile {
      name = "dconf-user-profile";
      destination = "/etc/dconf/profile/user";
      text = ''
        user-db:user
        system-db:site
      '';
    })
  ];

  # link debug symbols into /run/current-system/sw/lib/debug
  # hopefully picked up by gdb automatically?
  environment.enableDebugInfo = true;
}
