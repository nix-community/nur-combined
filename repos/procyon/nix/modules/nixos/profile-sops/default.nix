# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Nix community projects <admin@nix-community.org>
#
# SPDX-License-Identifier: MIT

{ flake, config, lib, ... }:
let
  defaultSopsPath = "${toString flake.inputs.self}/secrets/nix/hosts/${config.networking.hostName}.yaml";
in
{
  imports = with flake.inputs; [
    sops-nix.nixosModules.default
  ];

  sops = {
    defaultSopsFile = lib.mkIf (builtins.pathExists defaultSopsPath) defaultSopsPath;
    age = {
      generateKey = true;
      keyFile = "/var/lib/sops-nix/key.txt";
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
