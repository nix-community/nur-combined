# SPDX-FileCopyrightText: 2023 Sridhar Ratnakumar <srid@srid.ca>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Weathercold <weathercold.scr@proton.me>
#
# SPDX-License-Identifier: MIT

{ ezModules, flake, config, pkgs, lib, ... }:
{
  imports = [
    ezModules.suite-core
    flake.inputs.nur.hmModules.nur
  ];

  home = {
    inherit (flake.selfLib.data) stateVersion;
    username = lib.mkDefault flake.config.people.myself;
    homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${config.home.username}";
    activation.diff = config.lib.dag.entryBefore [ "writeBoundary" ] ''
      ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
    '';
  };
}
