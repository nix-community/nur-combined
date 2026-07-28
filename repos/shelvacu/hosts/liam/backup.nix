{ vacuModules, ... }: {
  imports = [ vacuModules.borg-backup ];
  vacu.backup = {
    repoPath = "liam-backup";
    keyName = "liam-borg-key";
    paths = [
      "/var/lib/mail"
      "/var/lib/dovecot"
      "/var/log"
    ];
  };
}
