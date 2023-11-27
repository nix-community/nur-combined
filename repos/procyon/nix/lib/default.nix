# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
# SPDX-FileCopyrightText: 2023 Sridhar Ratnakumar <srid@srid.ca>
#
# SPDX-License-Identifier: MIT

{ self, inputs, config, lib, ... }:
lib.makeExtensible (selfLib: rec {
  data = lib.importJSON ./data.json;
  flattenTree = import ./flatten-tree.nix { inherit lib; };
  rakeLeaves = import ./rake-leaves.nix { inherit inputs lib; };
  buildModuleList = import ./build-module-list.nix { inherit selfLib lib; };
  makePackages = import ./make-packages.nix { inherit lib; };
  appNames = import ./app-names.nix { inherit lib; };
  makeApps = import ./make-apps.nix { inherit lib; };

  specialArgsFor = rec {
    common.flake = { inherit self inputs config lib selfLib; };
    nixos = common;
  };
  mkHomeConfiguration = pkgs: mod: inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = specialArgsFor.common;
    modules = [ mod ] ++ [ self.homeModules.common ];
  };
})
