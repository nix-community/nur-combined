{ lib
, pkgs
, pnpm-install-only ? null
, nodejs-hide-symlinks ? null
}:

let
  internal = pkgs.callPackage ./internal.nix {
    inherit pnpm-install-only nodejs-hide-symlinks;
  };

  separatePublicAndInternalAPI = api: extraAttributes: {
    inherit (api) shell build node_modules;

    # *** WARNING ****
    # using any of the functions exposed by `internal` is not supported. That
    # being said, hiding them would only lead to copy&paste and it is also useful
    # for testing internal building blocks.
    internal = lib.warn "[npmlock2nix] You are using the unsupported internal API." (
      api
    );
  } // (lib.listToAttrs (map (name: lib.nameValuePair name api.${name}) extraAttributes));

  internalPublic = separatePublicAndInternalAPI internal [ "packageRequirePatchShebangs" ];
in
{
  v1 = internalPublic;
  v2 = internalPublic;
  tests = pkgs.callPackage ./tests { };
} // internalPublic
