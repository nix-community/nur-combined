{ self }:
let
  inherit (self.inputs) unstable;
  inherit (self.common.system) unstable-system;
  inherit (self.common.cloud-base-image-modules) linode;
  inherit (self.common.package-sets) x86_64-linux-unstable;

  inherit (x86_64-linux-unstable) system identifier pkgs;
  base = self.common.modules.${identifier};
  modules = base ++ [ ../../hosts/ditto linode ];

in unstable-system { inherit system pkgs modules; }
