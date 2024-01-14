# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, pkgs, ... }:
{
  users.extraGroups.podman.members = [ "${flake.config.people.myself}" ];

  environment.systemPackages = with pkgs; [
    docker-client
    podman-compose
  ];

  virtualisation = {
    docker.enable = false;
    oci-containers.backend = "podman";
    containers.registries.search = [
      "ghcr.io"
      "docker.io"
    ];
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
