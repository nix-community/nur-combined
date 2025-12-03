{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.ssh;
in
{
  sane.programs.ssh = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.openssh "ssh";
    sandbox.net = "all";
    sandbox.whitelistSsh = true;
    # sandbox.autodetectCliPaths = "existingFile";  # to support `-o 'UserKnownHostsFile /path/...'`
    sandbox.extraPaths = [ "/var/run/tailscale" ];  # `tailscale ssh` invokes ssh in a way that somehow calls _back_ into ts, not clear how.
    sandbox.extraHomePaths = [ ".config/tailscale/ssh_known_hosts" ];
    suggestedPrograms = [ "ssh-agent" ];
  };

  sane.programs.ssh-agent = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.openssh "ssh-agent";
    suggestedPrograms = [ "ssh-add" ];
    sandbox.net = "clearnet";
    sandbox.extraRuntimePaths = [
      "ssh-agent"
    ];

    env.SSH_AUTH_SOCK = "/run/user/colin/ssh-agent/agent";

    services.ssh-agent = {
      description = "ssh-agent authentication agent";
      command = pkgs.writeShellScript "ssh-agent-start" ''
        mkdir -p "$XDG_RUNTIME_DIR/ssh-agent"
        # -D = Don't fork
        # -d = dont fork, *and*, write debug info to standard eror
        #      (only one of -D|-d may be specified)
        exec ssh-agent -d -a "$XDG_RUNTIME_DIR/ssh-agent/agent"
      '';
      readiness.waitExists = [
        "$SSH_AUTH_SOCK"
      ];
      partOf = [ "default" ];
    };
  };

  sane.programs.ssh-add = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.openssh "ssh-add";
    sandbox.autodetectCliPaths = "existing";
    sandbox.extraHomePaths = [
      ".ssh/id_ed25519"
    ];
    sandbox.whitelistSsh = true;
    services.ssh-add = {
      description = "import keys to ssh-agent";
      startCommand = "ssh-add";
      cleanupCommand = "ssh-add -d";  # `ssh-add -d` undo's `ssh-add`, but leaves keys added to the agent through other means still available
      depends = [
        "gocryptfs-private"
        "ssh-agent"
      ];
      partOf = [ "private-storage" ];
    };
  };

  programs.ssh = lib.mkIf cfg.enabled {
    # fixes the following error when running ssh (e.g. via `git`) in a sandbox:
    # "Bad owner or permissions on /nix/store/<hash>-systemd-257.3/lib/systemd/ssh_config.d/20-systemd-ssh-proxy.conf"
    # - that error is caused because openssh wants config files to be 0220 UNLESS said config file is owned by root or self.
    #   the `bunpen` and `bwrap` user namespace sandboxes map root -> nobody, so openssh fails the check.
    #   by avoiding the include, we hack around this limitation.
    systemd-ssh-proxy.enable = false;
    # extraConfig = let
    #   SSH_EXTRA_KNOWN_HOSTS = pkgs.writeCBin "print-SSH_EXTRA_KNOWN_HOSTS" ''
    #     #define _GNU_SOURCE
    #     #include <stdio.h>
    #     #include <unistd.h>
    #     int main (int argc, char **argv) {
    #       for (char **env = environ; *env; ++env) {
    #         char *ep = *env;
    #         char *ap = "SSH_EXTRA_KNOWN_HOSTS";
    #         while (*ep != '\0' && *ap != '\0' && *ep++ == *ap++) {
    #           if (*ep == '=' && *ap == '\0') {
    #             printf ("%s\n", ep + 1);
    #           }
    #         }
    #       }
    #       return 0;
    #     }
    #   '';
    # in ''
    #   # allow injecting ephemeral known_hosts by setting/appending this env var
    #   # e.g. `SSH_EXTRA_KNOWN_HOSTS="$(ssh-keyscan FOO)" ssh FOO`
    #   # XXX: this is done in system-wide ssh config because otherwise user-namespaced ssh complains about
    #   # ~/.ssh/config being owned by the wrong user.
    #   # it's a custom binary instead of `printenv SSH_EXTRA_KNOWN_HOSTS` so as to make the env var optional.
    #   KnownHostsCommand ${lib.getExe SSH_EXTRA_KNOWN_HOSTS}
    # '';
  };
}
