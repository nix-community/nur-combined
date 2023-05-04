{ config, pkgs, lib, sane-lib, ... }:

# installer docs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/installation-device.nix
with lib;
let
  cfg = config.sane.guest;
  fs = sane-lib.fs;
in
{
  options = {
    sane.guest.enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = {
    # Users are exactly these specified here;
    # old ones will be deleted (from /etc/passwd, etc) upon upgrade.
    users.mutableUsers = false;

    # docs: https://nixpkgs-manual-sphinx-markedown-example.netlify.app/generated/options-db.xml.html#users-users
    users.users.colin = {
      # sets group to "users" (?)
      isNormalUser = true;
      home = "/home/colin";
      createHome = true;
      homeMode = "0700";
      # i don't get exactly what this is, but nixos defaults to this non-deterministically
      # in /var/lib/nixos/auto-subuid-map and i don't want that.
      subUidRanges = [
        { startUid=100000; count=1; }
      ];
      group = "users";
      extraGroups = [
        "wheel"
        "nixbuild"
        "networkmanager"
        # phosh/mobile. XXX colin: unsure if necessary
        "video"
        "feedbackd"
        "dialout" # required for modem access
      ];

      # initial password is empty, in case anything goes wrong.
      # if `colin-passwd` (a password hash) is successfully found/decrypted, that becomes the password at boot.
      initialPassword = lib.mkDefault "";
      passwordFile = lib.mkIf (config.sops.secrets ? "colin-passwd") config.sops.secrets.colin-passwd.path;

      shell = pkgs.zsh;

      # mount encrypted stuff at login
      # some other nix pam users:
      # - <https://github.com/g00pix/nixconf/blob/32c04f6fa843fed97639dd3f09e157668d3eea1f/profiles/sshfs.nix>
      # - <https://github.com/lourkeur/distro/blob/11173454c6bb50f7ccab28cc2c757dca21446d1d/nixos/profiles/users/louis-full.nix>
      # - <https://github.com/dnr/sample-nix-code/blob/03494480c1fae550c033aa54fd96aeb3827761c5/nixos/laptop.nix>
      pamMount = let
        priv = config.fileSystems."/home/colin/private";
      in {
        fstype = priv.fsType;
        path = priv.device;
        mountpoint = priv.mountPoint;
        options = builtins.concatStringsSep "," priv.options;
      };
    };

    security.pam.mount.enable = true;

    sane.users.colin.default = true;
    # ensure ~ perms are known to sane.fs module.
    # TODO: this is generic enough to be lifted up into sane.fs itself.
    sane.fs."/home/colin".dir.acl = {
      user = "colin";
      group = config.users.users.colin.group;
      mode = config.users.users.colin.homeMode;
    };

    sane.user.persist.plaintext = [
      "archive"
      "dev"
      # TODO: records should be private
      "records"
      "ref"
      "tmp"
      "use"
      "Music"
      "Pictures"
      "Videos"

      ".cache/nix"
      ".cache/nix-index"

      # ".cargo"
      # ".rustup"
    ];

    # convenience
    sane.user.fs."knowledge" = fs.wantedSymlinkTo "private/knowledge";
    sane.user.fs."nixos" = fs.wantedSymlinkTo "dev/nixos";
    sane.user.fs."Books/servo" = fs.wantedSymlinkTo "/mnt/servo-media/Books";
    sane.user.fs."Videos/servo" = fs.wantedSymlinkTo "/mnt/servo-media/Videos";
    sane.user.fs."Videos/servo-incomplete" = fs.wantedSymlinkTo "/mnt/servo-media/incomplete";
    sane.user.fs."Music/servo" = fs.wantedSymlinkTo "/mnt/servo-media/Music";
    sane.user.fs."Pictures/servo-macros" = fs.wantedSymlinkTo "/mnt/servo-media/Pictures/macros";

    # used by password managers, e.g. unix `pass`
    sane.user.fs.".password-store" = fs.wantedSymlinkTo "knowledge/secrets/accounts";

    sane.persist.sys.plaintext = mkIf cfg.enable [
      # intentionally allow other users to write to the guest folder
      { directory = "/home/guest"; user = "guest"; group = "users"; mode = "0775"; }
    ];
    users.users.guest = mkIf cfg.enable {
      isNormalUser = true;
      home = "/home/guest";
      subUidRanges = [
        { startUid=200000; count=1; }
      ];
      group = "users";
      initialPassword = lib.mkDefault "";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        # TODO: insert pubkeys that should be allowed in
      ];
    };

    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      settings.PasswordAuthentication = false;
    };
  };
}
