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
      "audio"  # for wireplumber, so i can access devices without logind
      "clightning"  # servo, for clightning-cli
      "dialout"  # required for modem access (moby)
      "export"  # to read filesystem exports (servo)
      "feedbackd"  # moby, so `fbcli` can control vibrator and LEDs
      "input"  # for /dev/input/<xyz>... TODO:is this still necessary?
      "kvm"  # for qemu; /dev/kvm
      "media"  # servo
      "named"  # for `sane-vpn {up,down}`
      "networkmanager"
      "nixbuild"
      "plugdev"  # desko, for ZSA/QMK/udev
      "render"  # for crappy, /dev/dri/render*
      "seat"  # for sway, if using seatd
      "systemd-journal"  # allows to view other user's journals (esp system users)
      "transmission"  # servo
      "unbound"  # for `unbound-control` to work
      "video"  # mobile; for LEDs & maybe for camera?
      "wheel"
      "wireshark"
    ];

    # initial password is empty, in case anything goes wrong.
    # if `colin-passwd` (a password hash) is successfully found/decrypted, that becomes the password at boot.
    # N.B.: the linux password, here, is used for screen lockers;
    #       the login password is dictated by gocryptfs credentials;
    #       both are necessary for a well-functioning system.
    #       (in the future, pam-mount *could* be used to unify those passwords)
    initialPassword = lib.mkDefault "";
    hashedPasswordFile = lib.mkIf (config.sops.secrets ? "colin-passwd") config.sops.secrets.colin-passwd.path;

    shell = pkgs.zsh;

    # mount encrypted stuff at login
    # some other nix pam users:
    # - <https://github.com/g00pix/nixconf/blob/32c04f6fa843fed97639dd3f09e157668d3eea1f/profiles/sshfs.nix>
    # - <https://github.com/lourkeur/distro/blob/11173454c6bb50f7ccab28cc2c757dca21446d1d/nixos/profiles/users/louis-full.nix>
    # - <https://github.com/dnr/sample-nix-code/blob/03494480c1fae550c033aa54fd96aeb3827761c5/nixos/laptop.nix>
    # pamMount = let
    #   priv = config.fileSystems."${config.sane.persist.stores.private.origin}";
    # in lib.mkIf config.sane.persist.enable {
    #   fstype = priv.fsType;
    #   path = priv.device;
    #   mountpoint = priv.mountPoint;
    #   options = builtins.concatStringsSep "," priv.options;
    # };
  };

  # i explicitly set both `initialPassword` and `hashedPasswordFile`, so ignore the warning against this.
  # see: <https://github.com/NixOS/nixpkgs/pull/287506>
  sane.silencedWarnings = [
    ''
      The user 'colin' has multiple of the options
      `initialHashedPassword`, `hashedPassword`, `initialPassword`, `password`
      & `hashedPasswordFile` set to a non-null value.

      If multiple of these password options are set at the same time then a
      specific order of precedence is followed, which can lead to surprising
      results. The order of precedence differs depending on whether the
      {option}`users.mutableUsers` option is set.

      If the option {option}`users.mutableUsers` is
      `false`, then the order of precedence is as shown
      below, where values on the left are overridden by values on the right:
      {option}`initialHashedPassword` -> {option}`hashedPassword` -> {option}`initialPassword` -> {option}`password` -> {option}`hashedPasswordFile`

      The values of these options are:
      * users.users."colin".hashedPassword: ${lib.generators.toPretty {} config.users.users.colin.hashedPassword}
      * users.users."colin".hashedPasswordFile: ${lib.generators.toPretty {} config.users.users.colin.hashedPasswordFile}
      * users.users."colin".password: ${lib.generators.toPretty {} config.users.users.colin.password}
    ''
  ];

  environment.etc."/security/capability.conf".text = ''
    # The pam_cap.so module accepts the following arguments:
    #
    #   debug         - be more verbose logging things (unused by pam_cap for now)
    #   config=<file> - override the default config for the module with file
    #   keepcaps      - workaround for applications that setuid without this
    #   autoauth      - if you want pam_cap.so to always succeed for the auth phase
    #   default=<iab> - provide a fallback IAB value if there is no '*' rule
    #
    # format:
    # <CAP>[,<CAP>...] USER|@GROUP|*
    #
    # the part of each line before the delimiter (" \t\n") is parsed with `cap_iab_from_text`.
    # so each CAP can be prefixed to indicate which set it applies to:
    # [!][^][%]<CAP>
    # where ! adds to the NB set (bounding)
    #       ^ for AI (ambient + inherited)
    #       % (or empty) for I (inherited)
    #
    # special capabilities "all" and "none" enable all/none of the caps known to the system.

    # cap_ipc_lock: required by gnome-keyring (for `mlock`)
    # cap_sys_nice: allow realtime scheduling for e.g. audio applications, games
    ^cap_ipc_lock,^cap_net_admin,^cap_net_raw,^cap_sys_nice colin

    # include this `none *` line otherwise non-matching users get maximum inheritable capabilities
    none *
  '';

  # grant myself extra capabilities for systemd sessions so that i can e.g.:
  # - run wireshark without root/setuid
  # - (incidentally) create new network devices/routes without root/setuid, which ought to be useful for sandboxing if i deploy that right.
  # default systemd includes cap_wake_alarm unless we specify our own capabilityAmbientSet; might be helpful for things like rtcwake?
  #
  # userName and uid have to be explicitly set here, to pass systemd's sanity checks.
  # other values like `home`, `shell` can be omitted and systemd will grab those from other sources (/etc/passwd)
  #
  # user records are JSON dicts, keys are found in systemd: src/shared/user-record.c:user_record_load
  # notable keys:
  # - capabilityBoundingSet
  # - capabilityAmbientSet
  # - service
  # - privileged
  #
  # XXX 2024/01/30: as of systemd 255, ambient capabilities are broken; not set at login and not usable via systemd --user services.
  # environment.etc."userdb/colin.user".text = ''
  #   {
  #     "userName" : "colin",
  #     "uid": ${builtins.toString config.users.users.colin.uid},
  #     "capabilityAmbientSet": [
  #       "cap_net_admin",
  #       "cap_net_raw"
  #     ]
  #   }
  # '';

  sane.users.colin.default = true;
  services.getty.autologinUser = lib.mkDefault "colin";
  # security.pam.services.login.startSession = lib.mkForce false;  #< disable systemd integration

  # disable the `systemd --user` instance for colin.
  # systemd still starts a user.slice  when logging in via PAM (e.g. `ssh`, `login`),
  # but there's no user service manager which can start .service files or field `systemd --run` requests.
  systemd.services."user@${builtins.toString config.users.users.colin.uid}".enable = false;

  # systemd-user-sessions depends on remote-fs, causing login to take stupidly long
  # systemd.services."systemd-user-sessions".enable = false;
}
