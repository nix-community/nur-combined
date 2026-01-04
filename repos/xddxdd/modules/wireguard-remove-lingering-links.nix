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
              [ "-${lib.getExe' pkgs.iproute2 "ip"} link del \"${n}\"" ]
            else
              [
                "-${lib.getExe' pkgs.iproute2 "ip"} netns exec \"${v.interfaceNamespace}\" ${lib.getExe' pkgs.iproute2 "ip"} link del \"${n}\""
              ];
        };
    in
    lib.mapAttrs' cfgToWg config.networking.wireguard.interfaces;
}
