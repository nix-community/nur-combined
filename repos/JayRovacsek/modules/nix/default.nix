{ config, ... }:
let
  # We use the below value as it'll be available before this
  # evaluates rather than config.flake (which is available but
  # only after further evaluation)
  inherit (config) flake;

  hardwareProfile = system:
    if builtins.hasAttr "profile" system.hardware.cpu then {
      inherit (system.hardware.cpu.profile) cores speed;
    } else {
      cores = 1;
      speed = 1;
    };

  # TODO: Make hostname here dynamic in relation to system tailscale configuration
  # rather than the networking hostname
  buildSystemFunction = system: {
    systems = [ system.nixpkgs.system ] ++ system.boot.binfmt.emulatedSystems;
    sshUser = "builder";
    sshKey = config.age.secrets."builder-id-ed25519".path;
    # WARNING: pretty big assumption that localDomain exists on the target system plus
    # assumption we are using "lan" as local domain identifier.
    # This is only temporary until we get into tailscale as the transport mechanism here
    hostName = "${system.networking.hostName}.${
        if builtins.hasAttr "localDomain" system.networking then
          system.networking.localDomain
        else
          "lan"
      }";
    supportedFeatures = system.nix.settings.system-features;
    # This is gross as it runs the code twice rather than once.
    # TODO: figure how to make it a single pass
    speedFactor = builtins.mul (hardwareProfile system).cores
      (hardwareProfile system).speed;
  };

  buildMachines = builtins.filter (x: x.speedFactor != 1)
    (builtins.map (host: buildSystemFunction host.config)
      (builtins.attrValues flake.nixosConfigurations));

in {
  age.secrets."builder-id-ed25519" = {
    file = ../../secrets/ssh/builder-id-ed25519.age;
    mode = "0400";
  };

  nix = {
    inherit buildMachines;
    distributedBuilds = (builtins.length buildMachines) != 0;

    gc = {
      automatic = false;
      options = "--delete-older-than 7d";
    };

    settings = {
      auto-optimise-store = true;
      sandbox = true;
      substituters =
        [ "https://binarycache.rovacsek.com/" "https://microvm.cachix.org/" ];
      trusted-public-keys = [
        "binarycache.rovacsek.com:xhZ1vkz2OQdHK/ex2ByA2GeziZoehrNHJCeMo7Afvr8="
        "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
      ];
      trusted-users = [ "jay" "jrovacsek" "j.rovacsek" "root" "builder" ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
