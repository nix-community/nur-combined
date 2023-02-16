# Ditto
How damn meta right?

Ditto is not a host to be generally utilised in day-to-day and instead provides an extendable template that then is utilised to transform into other hosts.

This currently is done via the `common/images/*.nix` space generally but as I'm moving a lot of files around it's likely this comment might be outdated in short-order.

The application of ditto as a template is roughly:
```nix
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
```

Where `linode` as a cloud-base-image-modules property is whatever properties are required for a suitable
base image to be built for the upstream.