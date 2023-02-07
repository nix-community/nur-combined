let
  piholeUserConfig = import ../../../../users/service-accounts/pihole.nix;
  piholeDockerConfig = import ../../configs/pihole.nix;

  # Helper functions for generating correct nix configs
  userFunction = import ../../../../functions/service-user.nix;
  dockerFunction = import ../../../../functions/docker.nix;
  etcFunction = import ../../../../functions/etc.nix;

  # Config file contents to write to environment.etc locations
  local = import ./local.nix;
  cache = import ./cache.nix;

  # Files to write to etc
  etcConfigs = builtins.foldl' (x: y: x // etcFunction { config = y; }) { } [
    local
    cache
  ];

  # Actual constructs used to generate useful config
  piholeUser = userFunction { userConfig = piholeUserConfig; };
  pihole = dockerFunction { containerConfig = piholeDockerConfig; };
in {
  virtualisation.oci-containers.containers = pihole;
  users.extraUsers = piholeUser.extraUsers;
  users.extraGroups = piholeUser.extraGroups;

  imports = [ ../../../stubby ];

  environment.etc = etcConfigs;

  networking.firewall.allowedTCPPorts = [ 53 80 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
