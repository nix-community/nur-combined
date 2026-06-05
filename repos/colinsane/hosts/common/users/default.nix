{ lib, pkgs, ... }:
{
  imports = [
    ./colin.nix
    ./guest.nix
    ./pam.nix
    ./root.nix
  ];

  users.groups.media = {};
  users.groups.plugdev = {};

  # Users are exactly these specified here;
  # old ones will be deleted (from /etc/passwd, etc) upon upgrade.
  users.mutableUsers = false;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # tcb is a per-user alternative to the traditionally system-wide
  # /etc/{group,passwd,shadow} -- particularly /etc/shadow.
  #
  # each user gets files: /etc/tcb/$user/{group,passwd,shadow}.
  #
  # /etc/nsswitch is then directed to try loading those files when requesting
  # a resource, in addition to the default /etc/{group,passwd,shadow}.
  #
  # /etc/tcb/$user/ files may be created from existing /etc files via `tcb_convert`,
  # or supplied manually (clip the appropriate line from the /etc files).
  system.nssDatabases.shadow = [ "tcb" ];
  system.nssModules = lib.mkIf (!pkgs.stdenv.hostPlatform.isMusl) [
    # N.B.: musl libc consults /etc/tcb _by default_ so doesn't need the nss module.
    # /etc/nsswitch.conf itself is also unused on pure musl systems
    pkgs.tcb
  ];

  # userborn: perl-free alternative to update-users-groups.pl.
  # <https://github.com/nikstur/userborn>
  # see also: systemd-sysusers.
  # TODO(2026-01-01): i should be able to totally remove any runtime user management
  # and configure /etc/{group,passwd,shadow} 100% statically:
  # the secret parts of these are linked into /etc/tcb/... already.
  services.userborn.enable = true;
  # instruct `userborn` to *symlink* shadow into /etc:
  # that way i can safely expose all of /etc to all services, even as i make the underlying `shadow` readable by my user.
  # services.userborn.passwordFilesLocation = "/var/lib/etc_secrets";

  # systemd.services.userborn.serviceConfig.ExecStartPost = lib.mkBefore [
  #   # userborn defaults are 0o000 owned by root:root.
  #   # make readable by `wheel`, as required by e.g. swaylock.
  #   # `lib.mkBefore` and gracefully fail because `userborn` forces these read-only (via mount) after init.
  #   "-${pkgs.coreutils}/bin/chmod 440 /var/lib/etc_secrets/shadow"
  #   "-${pkgs.coreutils}/bin/chown :wheel /var/lib/etc_secrets/shadow"
  #   # `dbus-user`, `seatd`, `ssh-add` services both need access to either group or passwd (not sure exactly which).
  #   "-${pkgs.coreutils}/bin/chmod 444 /var/lib/etc_secrets/group"
  #   "-${pkgs.coreutils}/bin/cp --preserve=mode,ownership /var/lib/etc_secrets/group /etc/group.new"
  #   "-${pkgs.coreutils}/bin/mv /etc/group.new /etc/group"
  #   "-${pkgs.coreutils}/bin/chmod 444 /var/lib/etc_secrets/passwd"
  #   "-${pkgs.coreutils}/bin/cp --preserve=mode,ownership /var/lib/etc_secrets/passwd /etc/passwd.new"
  #   "-${pkgs.coreutils}/bin/mv /etc/passwd.new /etc/passwd"
  # ];

  # # environment.etc."group".enable = false;
  # # environment.etc."passwd".enable = false;
}
