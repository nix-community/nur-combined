{ self }:
let
  inherit (self.inputs) unstable;
  inherit (self.common.system) unstable-system;
  inherit (self.common.cloud-base-image-modules) oracle;
  inherit (self.common.package-sets) x86_64-linux-unstable;

  inherit (x86_64-linux-unstable) system identifier pkgs;
  base = self.common.modules.${identifier};
  modules = base ++ [ ../../hosts/ditto oracle ];

in unstable-system { inherit system pkgs modules; }
