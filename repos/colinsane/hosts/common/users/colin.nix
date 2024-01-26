{ config, pkgs, lib, ... }:

{
  # docs: https://nixpkgs-manual-sphinx-markedown-example.netlify.app/generated/options-db.xml.html#users-users
  users.users.colin = {
    # sets group to "users" (?)
    isNormalUser = true;
    home = "/home/colin";
    # i don't get exactly what this is, but nixos defaults to this non-deterministically
    # in /var/lib/nixos/auto-subuid-map and i don't want that.
    subUidRanges = [
      { startUid=100000; count=1; }
    ];
    group = "users";
    extraGroups = [
      "clightning"  # servo, for clightning-cli
      "dialout"  # required for modem access (moby)
      "export"  # to read filesystem exports (servo)
      "feedbackd"  # moby, so `fbcli` can control vibrator and LEDs
      "input"  # for /dev/input/<xyz>: sxmo
      "media"  # servo, for /var/lib/uninsane/media
      "networkmanager"
      "nixbuild"
      "systemd-journal"  # allows to view other user's journals (esp system users)
      "transmission"  # servo, to admin /var/lib/uninsane/media
      "video"  # mobile; for LEDs & maybe for camera?
      "wheel"
      "wireshark"
    ];

    # initial password is empty, in case anything goes wrong.
    # if `colin-passwd` (a password hash) is successfully found/decrypted, that becomes the password at boot.
    initialPassword = lib.mkDefault "";
    hashedPasswordFile = lib.mkIf (config.sops.secrets ? "colin-passwd") config.sops.secrets.colin-passwd.path;

    shell = pkgs.zsh;

    # mount encrypted stuff at login
    # some other nix pam users:
    # - <https://github.com/g00pix/nixconf/blob/32c04f6fa843fed97639dd3f09e157668d3eea1f/profiles/sshfs.nix>
    # - <https://github.com/lourkeur/distro/blob/11173454c6bb50f7ccab28cc2c757dca21446d1d/nixos/profiles/users/louis-full.nix>
    # - <https://github.com/dnr/sample-nix-code/blob/03494480c1fae550c033aa54fd96aeb3827761c5/nixos/laptop.nix>
    pamMount = let
      hasPrivate = config.fileSystems ? "/home/colin/private";
      priv = config.fileSystems."/home/colin/private";
    in lib.mkIf hasPrivate {
      fstype = priv.fsType;
      path = priv.device;
      mountpoint = priv.mountPoint;
      options = builtins.concatStringsSep "," priv.options;
    };
  };

  security.pam.mount.enable = true;

  # in the future, may add this to sshd/login/sudo
  # security.pam.services.systemd-user.rules = {
  #   auth.pam_cap = {
  #     order = 11500;
  #     # order = 12500;  # before pam_unix but after all the others
  #     control = "required"; # ?
  #     modulePath = "${pkgs.libcap.pam}/lib/security/pam_cap.so";
  #   };
  # };
  # security.pam.services.greetd.rules = {
  #   auth.pam_cap = {
  #     order = 12500;  # before pam_unix but after all the others
  #     control = "required"; # ?
  #     modulePath = "${pkgs.libcap.pam}/lib/security/pam_cap.so";
  #   };
  # };
  # environment.etc."/security/capability.conf".text = ''
  #   # The pam_cap.so module accepts the following arguments:
  #   #
  #   #   debug         - be more verbose logging things (unused by pam_cap for now)
  #   #   config=<file> - override the default config for the module with file
  #   #   keepcaps      - workaround for applications that setuid without this
  #   #   autoauth      - if you want pam_cap.so to always succeed for the auth phase
  #   #   default=<iab> - provide a fallback IAB value if there is no '*' rule
  #   #
  #   # format:
  #   # <CAP>[,<CAP>...] USER|@GROUP|*
  #   #
  #   # the part of each line before the delimiter (" \t\n") is parsed with `cap_iab_from_text`.
  #   # so each CAP can be prefixed to indicate which set it applies to:
  #   # [!][^][%]<CAP>
  #   # where ! adds to the NB set
  #   #       ^ for AI
  #   #       % (or empty) for I

  #   ^cap_net_admin,^cap_new_raw colin
  #   # include this `none *` line otherwise non-matching users get maximum inheritable capabilities
  #   none *
  # '';

  # grant myself extra capabilities so that i can e.g.:
  # - run wireshark without root/setuid
  # - (incidentally) create new network devices/routes without root/setuid, which ought to be useful for sandboxing if i deploy that right.
  # default systemd includes cap_wake_alarm unless we specify our own capabilityAmbientSet; might be helpful for things like rtcwake?
  #
  # userName and uid have to be explicitly set here, to pass systemd's sanity checks.
  # other values like `home`, `shell` can be omitted and systemd will grab those from other sources (/etc/passwd)
  environment.etc."userdb/colin.user".text = ''
    {
      "userName" : "colin",
      "uid": ${builtins.toString config.users.users.colin.uid},
      "capabilityAmbientSet": [
        "cap_net_admin",
        "cap_net_raw"
      ]
    }
  '';

  sane.users.colin = {
    default = true;

    persist.byStore.plaintext = [
      "archive"
      "dev"
      # TODO: records should be private
      "records"
      "ref"
      "tmp"
      "use"
      "Books"
      "Music"
      "Pictures"
      "Videos"

      # these are persisted simply to save on RAM.
      # ~/.cache/nix can become several GB.
      # fontconfig and mesa_shader_cache are < 10 MB.
      # TODO: integrate with sane.programs.sandbox?
      ".cache/fontconfig"
      ".cache/mesa_shader_cache"
      ".cache/nix"

      # ".cargo"
      # ".rustup"
    ];

    # fs.".cargo".symlink.target = "/tmp/colin-cargo";

    # convenience
    fs."knowledge".symlink.target = "private/knowledge";
    fs."nixos".symlink.target = "dev/nixos";
    fs."Books/servo".symlink.target = "/mnt/servo-media/Books";
    fs."Videos/servo".symlink.target = "/mnt/servo-media/Videos";
    # fs."Music/servo".symlink.target = "/mnt/servo-media/Music";
    fs."Pictures/servo-macros".symlink.target = "/mnt/servo-media/Pictures/macros";
  };
}
