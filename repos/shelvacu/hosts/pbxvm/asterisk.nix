{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.vacu.pbx;
  ext = cfg.extension;
  telnyx = cfg.telnyx;

  # Rendered by sops-nix at runtime so neither password ends up in the nix
  # store. pjsip.conf `#include`s it; see sops.templates below.
  pjsipSecrets = config.sops.templates."pjsip-secrets.conf".path;

  # Both transports advertise the same NAT story; only the protocol differs.
  # The Cisco enterprise (CUCM) SIP firmware retransmits badly over UDP — the
  # phone is configured for TCP (transportLayerProtocol 1) — while Telnyx is
  # dialled over UDP.
  natSettings = ''
    ${lib.concatMapStringsSep "\n" (net: "local_net=${net}") cfg.localNets}
    external_media_address=${cfg.publicIp}
    external_signaling_address=${cfg.publicIp}
  '';
in
{
  services.asterisk = {
    enable = true;

    # The nixpkgs default list still names two files asterisk 22 no longer
    # ships, which land in /etc/asterisk as dangling symlinks.
    useTheseDefaultConfFiles = lib.subtractLists [
      "cdr_syslog.conf"
      "phone.conf"
    ] options.services.asterisk.useTheseDefaultConfFiles.default;

    extraConfig = ''
      [options]
      ; Asterisk runs under systemd; keep it in the foreground and let the
      ; journal take the logs (see logger.conf below).
      verbose = 3
      documentation_language = en_US
    '';

    confFiles = {
      "logger.conf" = ''
        [general]

        [logfiles]
        ; `verbose` is what carries call progress -- the "Executing [...]" and
        ; "Called PJSIP/..." lines. Without it the journal only ever shows
        ; things that went wrong at NOTICE or above, so a call that never
        ; reaches the dialplan and a call that sails through look identical:
        ; both produce complete silence.
        syslog.local0 => notice,warning,error,verbose
      '';

      "rtp.conf" = ''
        [general]
        rtpstart=${toString cfg.rtpPortRange.from}
        rtpend=${toString cfg.rtpPortRange.to}
        ; No STUN/ICE: the one NAT in the path is prophecy's SNAT, and
        ; external_media_address already tells asterisk what to advertise.
        icesupport=no
      '';

      "pjsip.conf" = ''
        [global]
        type=global
        user_agent=Asterisk PBX

        ;=====================================================================
        ; Transports
        ;=====================================================================

        [transport-tcp]
        type=transport
        protocol=tcp
        bind=0.0.0.0:${toString cfg.sipPort}
        ${natSettings}

        [transport-udp]
        type=transport
        protocol=udp
        bind=0.0.0.0:${toString cfg.sipPort}
        ${natSettings}

        ;=====================================================================
        ; The Cisco 8851
        ;=====================================================================

        [${ext}]
        type=endpoint
        transport=transport-tcp
        context=from-phone
        aors=${ext}
        auth=${ext}-auth
        disallow=all
        ; g722 first: the 8851 has a wideband handset and speaker.
        allow=g722
        allow=ulaw
        allow=alaw
        ; Keep the media on asterisk — it is the only thing that can bridge the
        ; phone's LAN address and Telnyx's public one.
        direct_media=no
        rtp_symmetric=yes
        force_rport=yes
        rewrite_contact=yes
        dtmf_mode=rfc4733
        device_state_busy_at=2
        callerid=${cfg.phoneLabel} <${ext}>

        [${ext}]
        type=aor
        max_contacts=1
        remove_existing=yes
        ; The phone re-REGISTERs every timerRegisterExpires (3600s); qualify
        ; notices a yanked cable long before that.
        qualify_frequency=60

        ;=====================================================================
        ; Telnyx trunk
        ;=====================================================================

        [telnyx]
        type=endpoint
        transport=transport-udp
        context=from-telnyx
        aors=telnyx
        outbound_auth=telnyx-auth
        disallow=all
        allow=ulaw
        allow=alaw
        direct_media=no
        rtp_symmetric=yes
        force_rport=yes
        rewrite_contact=yes
        dtmf_mode=rfc4733
        from_user=${telnyx.user}
        from_domain=${telnyx.domain}
        send_rpid=yes

        [telnyx]
        type=aor
        contact=sip:${telnyx.domain}
        ; Also the NAT keepalive: prophecy's SNAT only keeps the mapping that
        ; lets Telnyx reach us alive while packets keep flowing, and conntrack's
        ; UDP timeouts are far shorter than the registration interval.
        qualify_frequency=30

        [telnyx]
        type=registration
        transport=transport-udp
        outbound_auth=telnyx-auth
        server_uri=sip:${telnyx.domain}
        client_uri=sip:${telnyx.user}@${telnyx.domain}
        contact_user=${telnyx.user}
        retry_interval=60
        forbidden_retry_interval=600
        expiration=120
        ; line/endpoint: tag the registration's Contact so INVITEs Telnyx sends
        ; back through it are matched to the telnyx endpoint. This is what makes
        ; inbound calls work from behind the SNAT, where the identify below
        ; cannot be relied on alone.
        line=yes
        endpoint=telnyx

        [telnyx]
        type=identify
        endpoint=telnyx
        ${lib.concatMapStringsSep "\n" (ip: "match=${ip}") telnyx.signalingIps}

        ;=====================================================================
        ; Credentials (rendered at runtime by sops-nix)
        ;=====================================================================

        #include "${pjsipSecrets}"
      '';

      "extensions.conf" = ''
        [globals]
        ${lib.optionalString (
          telnyx.outboundCallerId != null
        ) "OUTBOUND_CALLERID=${telnyx.outboundCallerId}"}

        ;---------------------------------------------------------------------
        ; Everything the phone dials
        ;---------------------------------------------------------------------
        [from-phone]
        ; Echo test, for proving the audio path without spending money.
        exten => 611,1,Answer()
         same => n,Wait(1)
         same => n,Playback(demo-echotest)
         same => n,Echo()
         same => n,Hangup()

        ; Telnyx wants E.164, so normalise every way the handset might be
        ; dialled into +1XXXXXXXXXX before handing it to the trunk.
        exten => _+X.,1,Goto(pstn,''${EXTEN},1)
        exten => _1NXXNXXXXXX,1,Goto(pstn,+''${EXTEN},1)
        exten => _NXXNXXXXXX,1,Goto(pstn,+1''${EXTEN},1)
        exten => _011X.,1,Goto(pstn,+''${EXTEN:3},1)
        exten => 911,1,Goto(pstn,911,1)
        exten => 933,1,Goto(pstn,933,1)

        ;---------------------------------------------------------------------
        ; Outbound via Telnyx
        ;---------------------------------------------------------------------
        [pstn]
        exten => _[+0-9].,1,NoOp(outbound ''${EXTEN} via telnyx)
         same => n,ExecIf($["''${OUTBOUND_CALLERID}" != ""]?Set(CALLERID(num)=''${OUTBOUND_CALLERID}))
         same => n,Dial(PJSIP/''${EXTEN}@telnyx,60)
         same => n,Hangup()

        ;---------------------------------------------------------------------
        ; Inbound from Telnyx — one phone, so everything rings it
        ;---------------------------------------------------------------------
        [from-telnyx]
        exten => _[+0-9].,1,NoOp(inbound ''${EXTEN} from telnyx)
         same => n,Dial(PJSIP/${ext},30)
         same => n,Hangup()
      '';
    };
  };

  sops.secrets."telnyx/password" = { };
  sops.secrets."phone/${config.vacu.pbx.extension}/password" = { };

  sops.templates."pjsip-secrets.conf" = {
    owner = "asterisk";
    content = ''
      [${ext}-auth]
      type=auth
      auth_type=userpass
      username=${ext}
      password=${config.sops.placeholder."phone/${ext}/password"}

      [telnyx-auth]
      type=auth
      auth_type=userpass
      username=${telnyx.user}
      password=${config.sops.placeholder."telnyx/password"}
    '';
  };

  networking.firewall.allowedTCPPorts = [ cfg.sipPort ];
  networking.firewall.allowedUDPPorts = [ cfg.sipPort ];
  networking.firewall.allowedUDPPortRanges = [ { inherit (cfg.rtpPortRange) from to; } ];
}
