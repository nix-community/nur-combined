{
  self,
  lib,
  config,
  ...
}: {
  flake = {
    garnixConfig = builtins.toJSON {
      builds.include =
        (lib.naturalSort
          (lib.flatten
            (builtins.map
              (platform: (builtins.map (p: "packages.${platform}.${p}") (builtins.attrNames (self.ciPackages."${platform}"))))
              config.systems)))
        ++ ["nixosConfigurations.*"];
    };
  };
}
