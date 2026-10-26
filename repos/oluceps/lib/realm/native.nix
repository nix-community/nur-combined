{
  lib,
  common,
  outputs,
}:
{ name, w, ... }:
let
  inherit (common) appName;
in
outputs.merge (
  # Native ingress: the application terminates mTLS itself and consumes
  # SDS. The registration therefore attests the application unit and user,
  # and the application joins realm-proxies for Agent socket access.
  lib.optional (lib.any (i: i.native) (builtins.attrValues w.ingress)) (
    outputs.empty
    // {
      registrations."realm-native-${name}" = {
        spiffeID = w.spiffeID;
        selectors = [
          "systemd:id:${w.unit}"
          "unix:user:${w.user}"
        ];
      };
      services.${appName w} = {
        # Retry canceled starts after the Agent becomes ready again.
        upheldBy = [ "spire-agent.service" ];
        requires = [ "spire-agent.service" ];
        after = [ "spire-agent.service" ];
        serviceConfig.SupplementaryGroups = [ "realm-proxies" ];
      };
    }
  )
)
