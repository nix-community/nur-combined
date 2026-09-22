{
  lib,
  config,
  vaculib,
  vacuModules,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.vacu.pbx;
in
{
  imports = [
    vacuModules.vacuvmGuest
    vacuModules.sops
  ]
  ++ vaculib.directoryGrabberList ./.;

  options.vacu.pbx = {
    extension = mkOption {
      type = types.strMatching "[0-9]+";
      default = "1001";
      description = ''
        The SIP username the phone's *first* line registers as. Each further
        line button counts up from here — with two trunks and the default
        `1001`, the phone registers as 1001 and 1002. Numeric because of that
        counting.
      '';
    };
    lines = mkOption {
      internal = true;
      readOnly = true;
      type = types.listOf (types.attrsOf types.str);
      description = ''
        The phone's line buttons, one per trunk, in button order: the default
        trunk on button 1 and the rest after it. Computed, not set by hand —
        `trunks` and `extension` are the inputs. Each entry has `trunk`,
        `index`, `extension` and `label`.

        This is the whole mechanism for choosing an outbound trunk: every line
        is a SIP registration of its own, so which button the call started on
        arrives at asterisk as which peer sent the INVITE, and each peer has a
        context that pins `TRUNK`.
      '';
    };
    phoneMac = mkOption {
      type = types.strMatching "[0-9A-F]{12}";
      description = ''
        The phone's MAC address, uppercase and without separators. The TFTP
        config file the phone asks for is named `SEP<phoneMac>.cnf.xml`.
      '';
      example = "C444A03F4BD6";
    };
    phoneLabel = mkOption {
      type = types.str;
      default = "Cisco 8851";
      description = "Text shown in the phone's top-right corner.";
    };
    perCountryDialRules = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to generate a `Timeout="0"` dial rule per country calling code,
        so an international number sends the instant its last digit lands
        instead of after the `011*` catch-all timeout. Adds ~215 rules to
        dialplan.xml (~10 KiB).

        Cisco documents no limit on the number of dial rules a phone will
        accept, so if the handset starts ignoring the whole file — no auto-dial
        at all, not even for local numbers — turn this off and it reverts to
        the handful of hand-written rules.
      '';
    };
    sshAccess = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to run an SSH server on the handset. Needs a password: add
        `phone.<extension>.sshPassword` to secrets/hosts/pbxvm.yaml *before*
        turning this on, or sops fails to render the phone's config and atftpd
        refuses to start.

        Logging in lands you in a restricted shell; on the 8800 series,
        username `debug` and password `debug` from there reaches the debugging
        shell. See <https://usecallmanager.nz/sepmac-cnf-xml.html>.
      '';
    };
    sshUser = mkOption {
      type = types.str;
      default = "cisco";
      description = "Username the phone's SSH server accepts, when `sshAccess` is on.";
    };
    tftpRoot = mkOption {
      type = types.str;
      default = "/srv/tftp";
      description = "Directory atftpd serves the phone's provisioning files from.";
    };
    sipPort = mkOption {
      type = types.port;
      default = 5060;
      description = ''
        Port chan_sip binds for the phone, TCP and UDP. The phone is told this
        as `<sipPort>` in its TFTP config, and 5060 is also what it falls back
        to, so there is little reason to move it.
      '';
    };
    pjsipPort = mkOption {
      type = types.port;
      default = 5062;
      description = ''
        Port chan_pjsip binds for the upstream trunks. It cannot be `sipPort`:
        chan_sip and chan_pjsip are separate stacks and cannot share a bind.
        Only outbound registration uses it, so the value is arbitrary —
        providers reply to whatever source port the REGISTER came from.
      '';
    };
    rtpPortRange = mkOption {
      type = types.attrsOf types.port;
      default = {
        from = 10000;
        to = 10999;
      };
      description = ''
        RTP port range. Kept small on purpose: every port in it is opened in
        the firewall, and one phone needs a handful.
      '';
    };
    localNets = mkOption {
      type = types.listOf types.str;
      default = [
        # The LAN the phone lives on. Note 10.78.77.0/24 (the vacuvm net) is
        # inside this /22, so this one entry covers both the phone and any
        # sibling VM.
        "10.78.76.0/22"
      ];
      description = ''
        Networks asterisk should treat as "not behind the NAT", i.e. that get
        this VM's own address in SDP/Contact rather than `publicIp`. Everything
        else (the trunks) leaves via prophecy's wg-doof SNAT and must be told
        the public address instead.
      '';
    };
    publicIp = mkOption {
      type = types.str;
      description = ''
        The address this VM's traffic appears to come from on the public
        internet — prophecy SNATs guest IPv4 to its Doof static address (see
        hosts/prophecy/doof.nix). Advertised to the trunks in Contact and SDP.
      '';
      example = "205.201.63.13";
    };
    defaultTrunk = mkOption {
      type = types.str;
      default = "telnyx";
      description = ''
        Which `trunks` entry gets line button 1 on the phone, and so carries
        any call placed without picking a line first.
      '';
    };
    trunks = mkOption {
      description = ''
        Upstream SIP providers, keyed by name. Each becomes a chan_pjsip
        endpoint/aor/registration/identify set, an inbound dialplan context
        `from-<name>`, a sops secret at `<name>/password`, and a line button
        on the phone that sends outbound calls this way.
      '';
      default = { };
      type = types.attrsOf (
        types.submodule (
          { name, ... }: {
            options = {
              label = mkOption {
                type = types.str;
                default = name;
                description = ''
                  Text the phone shows next to this trunk's line button, and
                  the display name its line registers with. The 8851 has room
                  for a short word.
                '';
                example = "Telnyx";
              };
              user = mkOption {
                type = types.str;
                description = "Credential username to register with.";
                example = "usertelnyx97122";
              };
              domain = mkOption {
                type = types.str;
                description = "SIP FQDN to register to and dial through.";
                example = "sip.telnyx.com";
              };
              port = mkOption {
                type = types.port;
                default = 5060;
                description = "Provider's SIP port. Some do not use 5060.";
              };
              secretKey = mkOption {
                type = types.str;
                default = "${name}/password";
                description = "Key in secrets/hosts/pbxvm.yaml holding the password.";
              };
              signalingIps = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = ''
                  The provider's SIP *signalling* addresses, for the pjsip
                  `type=identify` match. Optional: inbound calls already match
                  via `line=yes` on the registration, which is what survives
                  prophecy's SNAT. Where a provider publishes them, listing them
                  is a useful second path.
                '';
              };
              dialPrefix = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = ''
                  Optional second way in, on top of this trunk's line button:
                  dial this before a number, from any line, to force the call
                  out this trunk. Null (the default) means the line button is
                  the only way.

                  The prefix has no entry in the phone's dial rules, so such a
                  call leaves on the `*` catch-all timeout rather than the
                  instant the last digit lands.
                '';
                example = "*8";
              };
              outboundCallerId = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = ''
                  E.164 number to present on outbound calls. When null, nothing
                  is set and the provider falls back to its own default.
                '';
                example = "+15555550123";
              };
            };
          }
        )
      );
    };
  };

  config = {
    vacu.hostName = "pbxvm";

    vacuvmGuest.ip = "10.78.77.6";
    vacuvmGuest.ipv6 = "2602:fce8:106:10::6";
    vacuvmGuest.ipv6Gateway = "2602:fce8:106:10::1";

    vacu.pbx.phoneMac = "C444A03F4BD6";
    vacu.pbx.publicIp = "205.201.63.13";
    # One line button per trunk, default trunk first. Every button is its own
    # SIP registration, so the extensions count up from `extension`.
    vacu.pbx.lines =
      let
        names = [ cfg.defaultTrunk ] ++ lib.remove cfg.defaultTrunk (lib.attrNames cfg.trunks);
      in
      lib.imap1 (i: name: {
        trunk = name;
        index = toString i;
        extension = toString (lib.toInt cfg.extension + i - 1);
        inherit (cfg.trunks.${name}) label;
      }) names;

    assertions = [
      {
        assertion = cfg.trunks ? ${cfg.defaultTrunk};
        message = "vacu.pbx.defaultTrunk is ${cfg.defaultTrunk}, which is not one of vacu.pbx.trunks.";
      }
    ];

    vacu.pbx.trunks = {
      telnyx = {
        label = "Telnyx";
        user = "usertelnyx97122";
        domain = "sip.telnyx.com";
        # US signalling pair from <https://sip.telnyx.com/>; update if the
        # connection moves region.
        signalingIps = [
          "192.76.120.10"
          "64.16.250.10"
        ];
      };
      jmpchat = {
        label = "JMP";
        user = "c4986875698";
        domain = "jmp.cbcbc7.auth.bandwidth.com";
        port = 5008;
      };
    };

    users.users.shelvacu = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = lib.attrValues config.vacu.ssh.authorizedKeys;
    };

    services.openssh.enable = true;

    # The phone has no battery-backed clock and, in SIP mode, no other source
    # of time — so the PBX is also its NTP server (see `<ntps>` in the TFTP
    # config). `allow` is what turns chrony from a client into a server.
    services.chrony = {
      enable = true;
      extraConfig = lib.concatMapStringsSep "\n" (net: "allow ${net}") config.vacu.pbx.localNets;
    };
    networking.firewall.allowedUDPPorts = [ 123 ];

    system.stateVersion = "26.05";
  };
}
