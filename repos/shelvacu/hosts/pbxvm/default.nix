{
  lib,
  config,
  vaculib,
  vacuModules,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    vacuModules.vacuvmGuest
    vacuModules.sops
  ]
  ++ vaculib.directoryGrabberList ./.;

  options.vacu.pbx = {
    extension = mkOption {
      type = types.str;
      default = "1001";
      description = ''
        The SIP username / line number the Cisco phone registers as. Used as
        the pjsip endpoint, aor and auth username, and as `name`/`contact`/
        `authName` in the phone's TFTP config.
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
    tftpRoot = mkOption {
      type = types.str;
      default = "/srv/tftp";
      description = "Directory atftpd serves the phone's provisioning files from.";
    };
    sipPort = mkOption {
      type = types.port;
      default = 5060;
      description = "Port asterisk binds SIP on, for both TCP (the phone) and UDP (Telnyx).";
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
        else (Telnyx) leaves via prophecy's wg-doof SNAT and must be told the
        public address instead.
      '';
    };
    publicIp = mkOption {
      type = types.str;
      description = ''
        The address this VM's traffic appears to come from on the public
        internet — prophecy SNATs guest IPv4 to its Doof static address (see
        hosts/prophecy/doof.nix). Advertised to Telnyx in Contact and SDP.
      '';
      example = "205.201.63.13";
    };
    telnyx = {
      user = mkOption {
        type = types.str;
        description = "Telnyx SIP connection credential username.";
        example = "usertelnyx97122";
      };
      domain = mkOption {
        type = types.str;
        default = "sip.telnyx.com";
        description = "Telnyx regional SIP FQDN to register to and dial through.";
      };
      signalingIps = mkOption {
        type = types.listOf types.str;
        default = [
          "192.76.120.10"
          "64.16.250.10"
        ];
        description = ''
          Telnyx SIP *signaling* addresses for the region `domain` points at,
          used for the pjsip `type=identify` match. From <https://sip.telnyx.com/>;
          update if you move the connection to another region.
        '';
      };
      outboundCallerId = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          E.164 number to present as caller ID on outbound calls. When null,
          nothing is set and Telnyx falls back to the connection's default.
        '';
        example = "+15555550123";
      };
    };
  };

  config = {
    vacu.hostName = "pbxvm";

    vacuvmGuest.ip = "10.78.77.6";
    vacuvmGuest.ipv6 = "2602:fce8:106:10::6";
    vacuvmGuest.ipv6Gateway = "2602:fce8:106:10::1";

    vacu.pbx.phoneMac = "C444A03F4BD6";
    vacu.pbx.publicIp = "205.201.63.13";
    vacu.pbx.telnyx.user = "usertelnyx97122";

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
