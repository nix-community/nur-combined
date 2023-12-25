# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ self, ... }:
{
  perSystem = { lib, ... }: {
    checks = lib.mapAttrs'
      (
        name: value: {
          name = "homeConfigurations/${name}";
          value = value.activationPackage;
        }
      )
      self.homeConfigurations;
  };
}
