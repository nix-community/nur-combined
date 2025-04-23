{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.ssh;
in
{
  sane.programs.ssh = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.openssh "ssh";
    sandbox.method = null;  #< TODO: sandbox
  };

  programs.ssh = lib.mkIf cfg.enabled {
    # fixes the following error when running ssh (e.g. via `git`) in a sandbox:
    # "Bad owner or permissions on /nix/store/<hash>-systemd-257.3/lib/systemd/ssh_config.d/20-systemd-ssh-proxy.conf"
    # - that error is caused because openssh wants config files to be 0220 UNLESS said config file is owned by root or self.
    #   the `bunpen` and `bwrap` user namespace sandboxes map root -> nobody, so openssh fails the check.
    #   by avoiding the include, we hack around this limitation.
    systemd-ssh-proxy.enable = false;
  };
}
