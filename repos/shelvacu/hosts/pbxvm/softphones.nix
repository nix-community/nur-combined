{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.vacu.pbx;
  enabled = cfg.softphones != { };
in
{
  options.vacu.pbx = {
    softphones = mkOption {
      default = { };
      description = ''
        SIP clients that register from anywhere over TLS, keyed by name. Each
        becomes a chan_pjsip endpoint that rings alongside the desk phone, can
        be dialled and transferred to by its extension, and needs a password
        at `softphone.<name>.password` in secrets/hosts/pbxvm.yaml.
      '';
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              extension = mkOption {
                type = types.strMatching "[0-9]+";
                description = "SIP username, and the number other devices dial to reach it.";
                example = "10711";
              };
              label = mkOption {
                type = types.str;
                default = name;
                description = "Caller-ID name shown when this device calls another.";
              };
              secretKey = mkOption {
                type = types.str;
                default = "softphone/${name}/password";
                description = "Key in secrets/hosts/pbxvm.yaml holding the password.";
              };
            };
          }
        )
      );
    };
    publicHostname = mkOption {
      type = types.str;
      default = "pbx.shelvacu.com";
      description = ''
        Name softphones connect to, and the TLS certificate's name. Its A
        record is prophecy's public address, which forwards
        `softphoneTlsPort` and the RTP range here.
      '';
    };
    softphoneTlsPort = mkOption {
      type = types.port;
      default = 5061;
      description = "Port the softphones' TLS transport listens on, here and on prophecy.";
    };
  };

  config = lib.mkIf enabled {
    assertions = [
      {
        assertion =
          let
            exts = map (sp: sp.extension) (lib.attrValues cfg.softphones) ++ map (l: l.extension) cfg.lines;
          in
          lib.length exts == lib.length (lib.unique exts);
        message = "vacu.pbx.softphones: every extension must be unique, and not one of the desk phone's lines.";
      }
    ];

    # HTTP-01 through prophecy's caddy, which proxies the challenge path here.
    security.acme = {
      acceptTerms = true;
      defaults.email = "acme-certs@shelvacu.com";
      certs.${cfg.publicHostname} = {
        listenHTTP = ":80";
        group = "asterisk";
      };
    };
    # `core reload` restarts a TLS transport whose cert file has changed.
    vacu.acmeCertDependencies.${cfg.publicHostname} = [ "asterisk.service" ];

    networking.firewall.allowedTCPPorts = [
      80
      cfg.softphoneTlsPort
    ];
  };
}
