{ config, inputs, lib, options, ... }:

{
  imports = [
    inputs.agenix.homeManagerModules.age
  ];

  config.age = {
    secrets =
      let
        toName = lib.removeSuffix ".age";
        toSecret = name: { ... }: {
          file = ./. + "/${name}";
        };
        convertSecrets = n: v: lib.nameValuePair (toName n) (toSecret n v);
        secrets = import ./secrets.nix;
      in
      lib.mapAttrs' convertSecrets secrets;

    # Add my usual agenix key to the defaults
    identityPaths = options.age.identityPaths.default ++ [
      "${config.home.homeDirectory}/.ssh/agenix"
    ];
  };
}
