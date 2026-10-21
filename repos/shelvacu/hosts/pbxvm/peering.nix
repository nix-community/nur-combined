{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.vacu.pbx;
in
{
  options.vacu.pbx = {
    peers = mkOption {
      default = { };
      description = ''
        Other PBXes that register here over TLS, keyed by name. Each becomes a
        chan_pjsip endpoint on the softphones' transport; its extensions can be
        dialled from here and ours from there, and PSTN numbers it advertises
        are called over the peering instead of a trunk. See "Peering" in
        docs/pbxvm.md for the protocol the other side has to speak.
      '';
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              prefix = mkOption {
                type = types.strMatching "10[0-9]";
                description = "Reach peer's extensions by first dialing this";
                example = "103";
              };
              extensionLength = mkOption {
                type = types.ints.positive;
                example = 2;
              };
              secretKey = mkOption {
                type = types.str;
                default = "peer/${name}/password";
                description = "Key in secrets/hosts/pbxvm.yaml holding the password the peer registers with.";
              };
            };
          }
        )
      );
    };
    advertisedNumbers = mkOption {
      type = types.listOf (types.strMatching "\\+[0-9]+");
      default = [ ];
      description = ''
        E.164 numbers this PBX answers, sent to every peer so they call them
        over the peering. Peers' calls to them ring the desk phone's first line.
        Remove a number to send peers back to the PSTN for it.
      '';
      example = [ "+14253510339" ];
    };
  };

  config = lib.mkIf (cfg.peers != { }) {
    assertions = [
      {
        assertion = cfg.softphones != { };
        message = "vacu.pbx.peers uses the softphones' TLS transport, which only exists with at least one softphone.";
      }
      {
        assertion =
          let
            prefixes = [ cfg.extensionPrefix ] ++ map (p: p.prefix) (lib.attrValues cfg.peers);
          in
          lib.length prefixes == lib.length (lib.unique prefixes);
        message = "vacu.pbx.peers: every extensionPrefix must be unique, and not ours.";
      }
    ];

    systemd.services.pbx-advertise = {
      description = "Advertise our numbers to PBX peers";
      after = [ "asterisk.service" ];
      requisite = [ "asterisk.service" ];
      serviceConfig.Type = "oneshot";
      script = lib.concatMapStrings (name: ''
        ${config.services.asterisk.package}/bin/asterisk -rx \
          'channel originate Local/${name}@peer-advertise application NoOp'
      '') (lib.attrNames cfg.peers);
    };
    systemd.timers.pbx-advertise = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnActiveSec = "1min";
        OnUnitActiveSec = "5min";
      };
    };
  };
}
