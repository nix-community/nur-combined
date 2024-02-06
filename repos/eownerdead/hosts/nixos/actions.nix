{ config, pkgs, ... }:
let sops = config.sops.secrets;
in {
  sops.secrets.codebergOrgRunnerToken = { };

  services = {
    gitea-actions-runner = {
      package = pkgs.forgejo-actions-runner;
      instances.codebergOrg = {
        enable = true;
        url = "https://codeberg.org";
        labels = [ ];
        name = config.networking.hostName;
        tokenFile = sops.codebergOrgRunnerToken.path;
      };
    };
  };

  virtualisation.podman.enable = true;

  # https://blog.kotatsu.dev/posts/2023-04-21-woodpecker-nix-caching/
  virtualisation.podman.defaultNetwork.settings.dns_enable = true;
  networking.firewall.interfaces."podman+" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
