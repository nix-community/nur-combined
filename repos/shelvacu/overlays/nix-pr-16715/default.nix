final: prev: {
  nixVersions = prev.nixVersions.extend (
    vfinal: vprev: {
      # https://github.com/NixOS/nix/pull/16715
      stable = vprev.stable.appendPatches (
        [ ./nix-pr-16715.patch ]
        ++ final.lib.optional (final.lib.versionAtLeast vprev.stable.version "2.36") ./nix-pr-16715-store-submit-output.patch
      );
    }
  );
}
