{ vacuModules, ... }: {
  imports = [ vacuModules.borg-backup ];
  vacu.backup = {
    repoPath = "prophecy-backup";
    keyName = "prop-borg-key";
    paths = [
      "/var/lib/dokuwiki/wiki.pm3.dev"
      "/var/lib/radicale"
      "/var/lib/vaultwarden"
      "/var/lib/kanidm"
      "/var/lib/nixos"
      "/var/log"
      "/propdata/copyparty-share/ppl/shelvacu/obsidian"
      "/dav-experiment" # contains phone seedvault backup
    ];
  };
}
