{self, ...}: {
  ciData = self.lib.ci.makeCiData self {
    config = {
      checks.groups = [
        [".*"]
      ];
      checks.setup = ["pre-commit"];
      packages.groups = [
        [".*"]
      ];
      hosts.exclude = [
        # `nixosConfigurations.${name}.config.system.build.toplevel`
        # derivations have `allowSubstitutes = false`, which breaks
        # `nix-build-uncached`; don't build them directly (cacheable
        # `checks."host/${name}"` wrappers would be built instead).
        ".*"
      ];
      hosts.groups = [
        [".*"]
      ];
    };
  };
}
