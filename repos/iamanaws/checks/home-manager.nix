{
  inputs,
  hostRegistry,
  lib,
}:
let
  utils = import ../lib/hostUtils.nix { inherit lib; };

  # Inspect arguments sent to Home Manager without evaluating every host's
  # packages. This also works on Linux for Darwin module selection.
  inspect =
    registry:
    import ../lib/mkHome.nix {
      inherit lib;
      inherit (inputs) nixpkgs;
      hostRegistry = registry;
      inputs = inputs // {
        home-manager.lib.homeManagerConfiguration = args: args;
      };
    };

  homes = inspect hostRegistry;
  root = "${inputs.self}/home/users";
  disabled = utils.normalizeUser {
    name = "iamanaws";
    homeManager.enable = false;
  };
  partial = utils.normalizeUser {
    name = "iamanaws";
    homeManager.module = "nixos/pwnbox";
  };
  duplicate = builtins.tryEval (
    builtins.attrNames (inspect {
      inherit (hostRegistry) backends;
      all = [
        hostRegistry.byBackend.nixos.goliath
        hostRegistry.byBackend.nixos.goliath
      ];
    })
  );
in
assert
  (utils.normalizeUser "iamanaws").homeManager == {
    enable = true;
    module = "auto";
  };
assert
  disabled.homeManager == {
    enable = false;
    module = "auto";
  };
assert partial.homeManager.enable;
assert homes ? "iamanaws@archimedes" && homes ? "iamanaws@goliath";
assert homes ? "iamanaws@galileo" && homes ? "iamanaws@pwnbox";
assert !(homes ? "iamanaws@alpha");
assert !(homes ? "iamanaws-nixos") && !(homes ? "iamanaws-x86_64-linux");
assert !(homes ? _type) && !(homes ? contents);
assert
  toString (builtins.elemAt homes."iamanaws@pwnbox".modules 1) == "${root}/iamanaws/nixos/pwnbox";
assert toString (builtins.elemAt homes."iamanaws@galileo".modules 1) == "${root}/iamanaws/darwin";
assert homes."iamanaws@archimedes".extraSpecialArgs.hostConfig.device.profile == "laptop";
assert homes."iamanaws@goliath".extraSpecialArgs.hostConfig.device.hostname == "goliath";
assert homes."iamanaws-darwin".extraSpecialArgs.hostConfig.device.hostname == "galileo";
assert (builtins.elemAt homes."iamanaws@galileo".modules 2).home.homeDirectory == "/Users/iamanaws";
assert (builtins.elemAt homes."iamanaws@goliath".modules 2).home.homeDirectory == "/home/iamanaws";
assert !duplicate.success;
true
