{ ... }:
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

  system.activationScripts.makeEtcShadowSandboxable = {
    deps = [ "users" ];
    text = ''
      # /etc is a public config directory. secrets like /etc/shadow don't belong there.
      # move /etc/shadow to a non-config directory but link to it from /etc.
      # this lets me keep all of /etc public, but only expose the private shadow file to sandboxed programs selectively.
      # this is technically racy, but the nixos `users` activation script is not easily patchable.
      mkdir -p /var/lib/etc_secrets
      cp --preserve=all --dereference /etc/shadow /var/lib/etc_secrets/shadow
      chown root:wheel /var/lib/etc_secrets/shadow
      ln -sf /var/lib/etc_secrets/shadow /etc/shadow
    '';
  };
  # define this specifically so that other parts of the config can know the real location of /etc/shadow
  # i.e. so that sandboxed programs which require it can indeed provision it (sane.programs.sandbox...)
  sane.fs."/etc/shadow".symlink.target = "/var/lib/etc_secrets/shadow";

}
