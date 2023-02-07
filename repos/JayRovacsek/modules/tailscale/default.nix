{ config, lib, ... }:
let
  hasMicrovm = if builtins.hasAttr "microvm" config then true else false;

  isMicrovmGuest =
    if hasMicrovm then builtins.hasAttr "hypervisor" config.microvm else false;

  hostMap = {
    alakazam = "admin";
    dragonite = "admin";
    aipom = "download";
    cloyster = "work";
    victreebel = "work";
    gastly = "admin";
    igglybuff = "dns";
    jigglypuff = "dns";
    ninetales = "work";
    wigglytuff = "general";
  };
  tailnet = hostMap.${config.networking.hostName};
  authFile = if isMicrovmGuest then
    "/run/agenix.d/preauth-${tailnet}"
  else
    config.age.secrets."preauth-${tailnet}".path;
in {
  imports = [ ../../options/tailscale ];

  services.tailscale = {
    inherit authFile tailnet;
    enable = true;
  };

  age.secrets."preauth-${tailnet}" = lib.mkForce {
    file = ../../secrets/tailscale/preauth-${tailnet}.age;
    mode = "0440";
    group = if config.services.headscale.enable then
      config.services.headscale.group
    else
      "0";
  };
}
