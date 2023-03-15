{ self }:
let
  inherit (self) nixosConfigurations;
  inherit (self.inputs) nixos-generators;
  inherit (self.inputs.stable.lib) recursiveUpdate;
  inherit (self.inputs.stable.lib.attrsets)
    filterAttrs foldAttrs mapAttrsToList;
  inherit (nixosConfigurations) rpi1 rpi2;

  inherit (self.common.package-sets)
    x86_64-linux-stable x86_64-linux-unstable aarch64-linux-stable
    aarch64-linux-unstable;

  sd-configurtations = [ rpi1 rpi2 ];
  cloud-formats = [ "linode" "qcow" ];

  cloud-base-images =
    builtins.foldl' (acc: set: (builtins.listToAttrs set) // acc) { }
    (mapAttrsToList (name: value:
      builtins.foldl' (acc: format:
        [{
          name = "${format}-base-image";
          value = nixos-generators.nixosGenerate {
            inherit format;
            inherit (value.pkgs.stdenv) system;
            inherit (value._module.args) modules;
          };
        }] ++ acc) [ ] cloud-formats

    ) (filterAttrs (n: v: builtins.elem n cloud-formats) nixosConfigurations));

  # Create a list of identifer to sdImage build derivations.
  sd-images = builtins.map (image: {
    "${image.config.networking.hostName}" = image.config.system.build.sdImage;
  }) sd-configurtations;

  # Fold list of image name => derivation into a set rather than a list
in builtins.foldl' recursiveUpdate cloud-base-images sd-images
