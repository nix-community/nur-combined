# https://git.clan.lol/clan/clan-infra/src/branch/main/modules/web01/gitea/actions-runner.nix
{
  config,
  pkgs,
  lib,
  ...
}:
let
  sops = config.sops.secrets;
  actions-root = pkgs.dockerTools.streamLayeredImage (
    pkgs.docker-nixpkgs.nix-flakes.buildArgs
    // {
      tag = "actions";
      includeStorePaths = false;
    }
  );
in
{
  sops.secrets.codebergOrgRunnerToken = { };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;
    instances.codebergOrg = {
      enable = true;
      url = "https://codeberg.org";
      labels = [ "nixos:docker://localhost/${actions-root.imageName}:actions" ];
      name = config.networking.hostName;
      tokenFile = sops.codebergOrgRunnerToken.path;
      settings.container = {
        network = "host";
        options = "-e NIX_REMOTE=daemon -v /nix/:/nix/ -v /nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket";
        valid_volumes = [ "/nix/" ];
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

  systemd.services."gitea-runner-codebergOrg" = {
    preStart = "${actions-root} | ${config.virtualisation.podman.package}/bin/podman load";
    serviceConfig.dynamicUser = lib.mkForce false;
  };
}
