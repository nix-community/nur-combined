{ config, flake }:
let
  hasMicrovm = if builtins.hasAttr "microvm" config then true else false;

  isMicrovmHost =
    if hasMicrovm then builtins.hasAttr "vms" config.microvm else false;

  isMicrovmGuest =
    if hasMicrovm then builtins.hasAttr "hypervisor" config.microvm else false;
  # there may be reason for a host to be both a guest and host
  isRecursiveMicrovm = isMicrovmHost && isMicrovmGuest;

  bridgeNetworks = builtins.map (x: x.netdevConfig.Name)
    (builtins.filter (x: x.netdevConfig.Kind == "bridge" && x.enable)
      (builtins.attrValues config.systemd.network.netdevs));

  meta = {
    inherit hasMicrovm isMicrovmGuest isMicrovmHost isRecursiveMicrovm
      bridgeNetworks;
  };

in meta
