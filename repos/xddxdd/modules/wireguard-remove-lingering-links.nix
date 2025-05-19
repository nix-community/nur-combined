{
  pkgs,
  lib,
  config,
  ...
}:
{
  key = "xddxdd-nur-packages-wireguard-remove-lingering-links";

  # Remove lingering WireGuard links after they are shut down.
  systemd.services =
    let
      cfgToWg =
        n: v:
        lib.nameValuePair "wireguard-${n}" {
          serviceConfig.ExecStartPre =
            if v.interfaceNamespace == null then
              [ "-${pkgs.iproute2}/bin/ip link del \"${n}\"" ]
            else
              [
                "-${pkgs.iproute2}/bin/ip netns exec \"${v.interfaceNamespace}\" ${pkgs.iproute2}/bin/ip link del \"${n}\""
              ];
        };
    in
    lib.mapAttrs' cfgToWg config.networking.wireguard.interfaces;
}
