# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
# SPDX-FileCopyrightText: 2023 Sridhar Ratnakumar <srid@srid.ca>
# SPDX-FileCopyrightText: 2023 Elizabeth Paź <me@ehllie.xyz>
#
# SPDX-License-Identifier: MIT

{ self, inputs, config, lib, ... }:
lib.makeExtensible (selfLib: {
  data = lib.importJSON ./data.json;
  flattenTree = import ./flatten-tree.nix { inherit lib; };
  rakeLeaves = import ./rake-leaves.nix { inherit inputs lib; };
  buildModuleList = import ./build-module-list.nix { inherit selfLib lib; };
  makePackages = import ./make-packages.nix { inherit lib; };
  appNames = import ./app-names.nix { inherit lib; };
  makeApps = import ./make-apps.nix { inherit lib; };

  globalArgs = {
    flake = { inherit self inputs config selfLib; };
  };
})
