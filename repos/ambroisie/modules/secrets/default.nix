{ config, inputs, lib, options, ... }:

{
  imports = [
    inputs.agenix.nixosModules.age
  ];

  config.age = {
    secrets =
      let
        toName = lib.removeSuffix ".age";
        userExists = u: builtins.hasAttr u config.users.users;
        # Only set the user if it exists, to avoid warnings
        userIfExists = u: if userExists u then u else "root";
        toSecret = name: { owner ? "root", ... }: {
          file = ./. + "/${name}";
          owner = lib.mkDefault (userIfExists owner);
        };
        convertSecrets = n: v: lib.nameValuePair (toName n) (toSecret n v);
        secrets = import ./secrets.nix;
      in
      lib.mapAttrs' convertSecrets secrets;

    identityPaths = options.age.identityPaths.default ++ [
      # FIXME: hard-coded path, could be inexistent
      "/home/ambroisie/.ssh/id_ed25519"
    ];
  };
}
