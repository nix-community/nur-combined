# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, config, lib, ... }:
let
  inherit (config.sops) secrets;
  inherit (flake.inputs) self;
  cfg = config.services.tailscale;
in
{
  sops.secrets."tailscale-authkey" = lib.mkIf (cfg.useRoutingFeatures == "server") {
    sopsFile = "${toString self}/secrets/nix/services/tailscale.yaml";
  };

  networking = {
    search = [ "hale-toad.ts.net" ];
    nameservers = [ "100.100.100.100" ];
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    permitCertUid = flake.config.people.myself;
    useRoutingFeatures = lib.mkDefault "client";
    authKeyFile = lib.mkIf (cfg.useRoutingFeatures == "server") secrets."tailscale-authkey".path;
  };
}
