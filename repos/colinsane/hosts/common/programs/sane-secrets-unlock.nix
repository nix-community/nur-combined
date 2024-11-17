{ pkgs, ... }:
{
  sane.programs."sane-secrets-unlock" = {
    packageUnwrapped = pkgs.sane-scripts.secrets-unlock;
    sandbox.extraHomePaths = [
      ".ssh/id_ed25519"
      ".ssh/id_ed25519.pub"
      ".config/sops"
    ];
    fs.".config/sops".dir = {};

    # automatically unlock the secrets at login.
    services.sane-secrets-unlock = {
      description = "sane-secrets-unlock: make secrets in ~/knowledge readable";
      startCommand = "sane-secrets-unlock";
      cleanupCommand = "rm -f ~/.config/sops/age/keys.txt";
      depends = [ "gocryptfs-private" ];
      partOf = [ "private-storage" ];
    };
  };
}
