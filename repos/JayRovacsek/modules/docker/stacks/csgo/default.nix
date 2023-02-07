let
  csgoUserConfig = import ../../../../users/service-accounts/csgo.nix;
  csgoDockerConfig = import ../../configs/csgo.nix;

  # Helper functions for generating correct nix configs
  userFunction = import ../../../../functions/service-user.nix;
  dockerFunction = import ../../../../functions/docker.nix;
  etcFunction = import ../../../../functions/etc.nix;

  # Actual constructs used to generate useful config
  csgoUser = userFunction { userConfig = csgoUserConfig; };
  csgo = dockerFunction { containerConfig = csgoDockerConfig; };

  # Config file contents to write to environment.etc locations
  settings = import ./settings.nix;

  # Files to write to etc
  etcConfigs =
    builtins.foldl' (x: y: x // etcFunction { config = y; }) { } settings.files;

in {
  virtualisation.oci-containers = { containers = csgo; };
  users.extraUsers = csgoUser.extraUsers;
  users.extraGroups = csgoUser.extraGroups;

  environment.etc = etcConfigs;

  networking.firewall.allowedTCPPorts = [ 27015 ];
  networking.firewall.allowedUDPPorts = [ 26900 27005 27015 ];
}
