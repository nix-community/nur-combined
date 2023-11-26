# SPDX-FileCopyrightText: 2023 Sridhar Ratnakumar <srid@srid.ca>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ lib, ... }:
let
  keySubmodule = lib.types.submodule {
    options = {
      gpg = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };
      ssh = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };
    };
  };
  userSubmodule = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
      };
      email = lib.mkOption {
        type = lib.types.str;
      };
      key = {
        type = lib.types.attrsOf keySubmodule;
      };
    };
  };
  peopleSubmodule = lib.types.submodule {
    options = {
      users = lib.mkOption {
        type = lib.types.attrsOf userSubmodule;
      };
      myself = lib.mkOption {
        type = lib.types.str;
        description = ''
          The name of the user that represents myself.

          Admin user in all contexts.
        '';
      };
    };
  };
in
{
  options = {
    people = lib.mkOption {
      type = peopleSubmodule;
    };
  };

  config.people = rec {
    myself = "procyon";
    users = {
      "${myself}" = {
        name = "Unidealistic Raccoon";
        email = "dw5pzgvhbglzdgljcmfjy29vbg@skiff.com";
        key = {
          gpg = [
            "2764AA78791D69DF7E8916D640802D0919B2FB7D"
          ];
          ssh = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMLMCpAHL6U/68APRbekm/mzlBaRSNzi3GQzJYff0N69"
          ];
        };
      };
    };
  };
}
