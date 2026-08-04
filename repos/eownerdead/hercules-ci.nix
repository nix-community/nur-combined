{ inputs, lib, ... }:
{
  imports = [
    inputs.hercules-ci-effects.flakeModule
  ];

  hercules-ci = {
    flake-update = {
      enable = true;
      baseMerge = {
        enable = true;
        method = "reset";
      };
      createPullRequest = false;
      when.hour = 7;
      effect.settings.git = {
        checkout.user = lib.mkForce "eownerdead";
      };
    };
  };
}
