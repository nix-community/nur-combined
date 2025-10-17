{ lib, config, ... }:
{
  nix = {
    buildMachines = (
      lib.optional (config.networking.hostName != "hastur")

        {
          hostName = "hastur";
          system = "x86_64-linux";
          protocol = "ssh-ng";
          maxJobs = 12;
          speedFactor = 4;
          sshUser = "remotebuild";
          sshKey = "/persist/keys/remotebuild";
          supportedFeatures = [
            "nixos-test"
            "benchmark"
            "big-parallel"
            "kvm"
          ];
          mandatoryFeatures = [ ];
        }
      # ]
    )
    # ++ (lib.optional (config.networking.hostName != "eihort") {
    #   hostName = "eihort";
    #   system = "x86_64-linux";
    #   protocol = "ssh-ng";
    #   maxJobs = 4;
    #   speedFactor = 1;
    #   sshUser = "remotebuild";
    #   sshKey = "/persist/keys/remotebuild";
    #   supportedFeatures = [
    #     "nixos-test"
    #     "benchmark"
    #     "big-parallel"
    #     "kvm"
    #   ];
    #   mandatoryFeatures = [ ];
    # });
    ;
    distributedBuilds = true;
  };
}
