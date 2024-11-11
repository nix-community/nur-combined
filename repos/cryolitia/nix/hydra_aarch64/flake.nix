{
  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    extra-substituters = [
      "https://cryolitia.cachix.org"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cryolitia.cachix.org-1:/RUeJIs3lEUX4X/oOco/eIcysKZEMxZNjqiMgXVItQ8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };
  inputs = {
    parent.url = "../../.";
  };
  outputs =
    {
      self,
      parent,
      ...
    }:
    
    {
      hydraJobs = {
        aarch64 = parent.ciJobs."aarch64-linux";
      };
    };
}
