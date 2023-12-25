# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ self, ... }:
{
  perSystem = { lib, ... }: {
    checks = lib.mapAttrs'
      (
        name: value: {
          name = "nixosConfigurations/${name}";
          value = value.config.system.build.toplevel;
        }
      )
      self.nixosConfigurations;
  };
}
