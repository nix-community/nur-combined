{ self }:
let
  inherit (self) nixosConfigurations;
  inherit (self.inputs) nixos-generators;
  inherit (self.inputs.stable.lib) recursiveUpdate;
  inherit (self.inputs.stable.lib.attrsets)
    filterAttrsRecursive foldAttrs mapAttrsToList;
  inherit (nixosConfigurations) rpi1 rpi2;

  inherit (self.common.package-sets)
    x86_64-linux-stable x86_64-linux-unstable aarch64-linux-stable
    aarch64-linux-unstable;

  sd-configurtations = [ rpi1 rpi2 ];
  generator-formats = builtins.filter (format: format != "kexec")
    (builtins.attrNames nixos-generators.nixosModules);

  generator-images =
    builtins.foldl' (acc: set: (builtins.listToAttrs set) // acc) { }
    (mapAttrsToList (name: value:
      builtins.foldl' (acc: format:
        [{
          name = "${name}-${format}";
          value = nixos-generators.nixosGenerate {
            inherit format;
            inherit (value.pkgs.stdenv) system;
            inherit (value._module.args) modules;
          };
        }] ++ acc) [ ] generator-formats

    ) nixosConfigurations);

  # Create a list of identifer to sdImage build derivations.
  built-derivations = builtins.map (image: {
    "${image.config.networking.hostName}" = image.config.system.build.sdImage;
  }) sd-configurtations;

  # Fold list of image name => derivation into a set rather than a list
in builtins.foldl' recursiveUpdate generator-images built-derivations
