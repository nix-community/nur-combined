{
  lib,
  pkgs,
  config,
  options,
  ...
}:
let
  cfg = config.vacu.pbx;
  ext = cfg.extension;
  trunks = cfg.trunks;

  # Rendered by sops-nix at runtime so neither password ends up in the nix
  # store; each config `#include`s its own. See sops.templates below.
  pjsipSecrets = config.sops.templates."pjsip-secrets.conf".path;
  sipSecrets = config.sops.templates."sip-secrets.conf".path;

  # Line buttons 2 and up. The phone registers only the first line, so these are
  # `register=` aliases of that registration rather than registrations of their
  # own; see sip.conf below.
  secondaryLines = builtins.tail cfg.lines;

  # Only the upstream trunks are left on chan_pjsip, all dialled over UDP.

  # One endpoint/aor/registration(/identify) set per trunk. `line=yes` on the
  # registration is what makes inbound calls work from behind prophecy's SNAT:
  # the provider sends the INVITE back down the flow the REGISTER opened, and
  # pjsip matches it to the endpoint by the line tag rather than by address.
  trunkSections = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: t:
      let
        uri = "sip:${t.domain}:${toString t.port}";
      in
      ''
        ;=====================================================================
        ; ${name}
        ;=====================================================================

        [${name}]
        type=endpoint
        transport=transport-udp
        context=from-${name}
        aors=${name}
        outbound_auth=${name}-auth
        disallow=all
        allow=ulaw
        allow=alaw
        direct_media=no
        rtp_symmetric=yes
        force_rport=yes
        rewrite_contact=yes
        dtmf_mode=rfc4733
        from_user=${t.user}
        from_domain=${t.domain}
        send_rpid=yes

        [${name}]
        type=aor
        contact=${uri}
        ; Also the NAT keepalive: prophecy's SNAT only keeps the mapping that
        ; lets the provider reach us alive while packets keep flowing, and
        ; conntrack's UDP timeouts are far shorter than the registration
        ; interval.
        qualify_frequency=30

        [${name}]
        type=registration
        transport=transport-udp
        outbound_auth=${name}-auth
        server_uri=${uri}
        client_uri=sip:${t.user}@${t.domain}:${toString t.port}
        contact_user=${t.user}
        retry_interval=60
        forbidden_retry_interval=600
        expiration=120
        ; Without this a single 401 ends the registration for good: pjsip logs
        ; "Fatal response '401' ... stopping outbound registration" and never
        ; tries again, so a provider that rejects one REGISTER -- a rotated
        ; password, a rate limit, a bad nonce -- takes the trunk down until
        ; somebody notices and reloads. Retrying every forbidden_retry_interval
        ; is noisier and self-healing, which is the better trade for a trunk
        ; nobody is watching. (JMP.chat did exactly this on 2026-09-22.)
        auth_rejection_permanent=no
        line=yes
        endpoint=${name}
      ''
      + lib.optionalString (t.signalingIps != [ ]) ''

        [${name}]
        type=identify
        endpoint=${name}
        ${lib.concatMapStringsSep "\n" (ip: "match=${ip}") t.signalingIps}
      ''
    ) trunks
  );

  natSettings = ''
    ${lib.concatMapStringsSep "\n" (net: "local_net=${net}") cfg.localNets}
    external_media_address=${cfg.publicIp}
    external_signaling_address=${cfg.publicIp}
  '';
in
{
  services.asterisk = {
    enable = true;

    # chan_sip, and the Cisco extensions built on it, exist only in this build.
    package = pkgs.asterisk-usecallmanager;

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

      # The nixpkgs module's modules.conf is just `autoload=yes`, which is what
      # we want plus one exception: res_pjsip_notify has nothing to do here now
      # that the phone's restart/reset are chan_sip type=notify sections, and
      # the only trunks on pjsip are upstream providers we would never send a
      # NOTIFY to. Left to autoload it looks for a pjsip_notify.conf that does
      # not exist and logs an error on every start; noload says so deliberately
      # instead of keeping an empty config file around to quiet it.
      "modules.conf" = ''
        [modules]
        autoload=yes
        noload => res_pjsip_notify.so
      '';

      "rtp.conf" = ''
        [general]
        rtpstart=${toString cfg.rtpPortRange.from}
        rtpend=${toString cfg.rtpPortRange.to}
        ; No STUN/ICE: the one NAT in the path is prophecy's SNAT, and
        ; external_media_address already tells asterisk what to advertise.
        icesupport=no
      '';

      # The Cisco 8851 runs Cisco's *enterprise* (Unified CM) firmware, which
      # expects a pile of proprietary SIP that only the usecallmanager.nz patch
      # speaks -- and that patch reintroduces chan_sip to carry it, because
      # upstream deleted chan_sip in Asterisk 21. So the phone is a chan_sip
      # peer and the Telnyx trunk stays on chan_pjsip, each with its own bind:
      # the two stacks are independent and cannot share a port.
      "sip.conf" = ''
        [general]
        ; This chan_sip rejects `context`, `allowguest` and `dtmfmode` in
        ; [general]: guests are unconditionally disabled now, and all three
        ; belong on a peer.
        alwaysauthreject=yes
        srvlookup=no
        udpbindaddr=0.0.0.0:${toString cfg.sipPort}
        tcpenable=yes
        tcpbindaddr=0.0.0.0:${toString cfg.sipPort}
        ; The phone is on the LAN with no NAT between us -- prophecy's SNAT is
        ; only in the path to the trunks, which is chan_pjsip's problem.
        ${lib.concatMapStringsSep "\n" (net: "localnetwork=${net}") cfg.localNets}
        nat=no
        disallow=all
        ; g722 first: the 8851 has a wideband handset and speaker.
        allow=g722
        allow=ulaw
        allow=alaw

        ; One peer per line button on the phone. That is the whole
        ; trunk-selection mechanism: the button the call was started on decides
        ; which peer the INVITE comes from, and each peer's context pins the
        ; trunk.
        ;
        ; The phone does not register these separately, though -- the enterprise
        ; firmware sends *one* REGISTER, for the primary line, and holds one
        ; device-wide digest credential. So the primary peer lists the others in
        ; `register=`, and chan_sip gives each of them the primary's
        ; registration: its address, socket and secret, a contact rebuilt as
        ; its own name at the phone's address, and a line index counting up
        ; from 2 in the order listed here.
        ;
        ; That line index is also what makes their authentication work. The
        ; phone answers every challenge as the primary line, so `cisco=yes` plus
        ; an index above 1 is how chan_sip knows to expect the primary's name in
        ; the digest username rather than the peer's own (sip/dialog.c,
        ; "Cisco phones use the primary line credentials for secondary lines").
        ; Get this wrong and the phone sits on "Phone is registering" while the
        ; journal repeats `Authorization username mismatch`.
        ;
        ; Everything else stays per peer, which is the point: context, callerid
        ; and dialplan are the line's own.
        ${lib.concatMapStringsSep "\n" (l: ''
          [${l.extension}]
          type=peer
          host=dynamic
          dtmfmode=rfc2833
          ; The enterprise firmware's UDP path retransmits badly against anything
          ; that is not a real CUCM; the phone is set to transportLayerProtocol 1.
          transport=tcp
          context=from-phone-${l.trunk}
          callerid=${cfg.phoneLabel} <${l.extension}>
          ; The switch the whole patch hangs off. Without it the peer is served as
          ; a generic SIP phone and every Cisco softkey stays dead -- and the
          ; secondary lines never authenticate at all.
          cisco=yes
          directmedia=no
          ; 'qualify' is deprecated in this chan_sip; 'yes' means the 2000ms default.
          maxqualify=yes
          ${lib.optionalString (l.index == "1" && secondaryLines != [ ]) ''
            register=${lib.concatMapStringsSep "," (s: s.extension) secondaryLines}
          ''}
          #include "${sipSecrets}"
        '') cfg.lines}

        ; The phone reads its TFTP config when it boots and at no other time --
        ; there is no polling interval. To push a change without walking over to
        ; it, CUCM sends a NOTIFY carrying `Event: service-control`; all-zero
        ; version stamps mean "everything you have cached is stale, fetch it
        ; again".
        ;
        ; RegisterCallId is the part stock Asterisk could not supply, and the
        ; reason this moved off chan_pjsip: the patch adds SIP_PEER(), so the
        ; NOTIFY can carry the Call-ID of the phone's own REGISTER, which is
        ; what it checks before acting. This chan_sip wants the types inline
        ; here rather than in a sip_notify.conf, which it deprecates.
        ;
        ;   asterisk -rx 'sip notify cisco-restart 1001'
        ;   asterisk -rx 'sip notify cisco-reset 1001'
        [cisco-service-control](!)
        type=notify
        header=Event: service-control
        header=Subscription-State: active
        header=Content-Type: text/plain
        ; Quick restart: re-reads config without a full boot cycle.
        [cisco-restart](cisco-service-control)
        content=action=restart
        content=RegisterCallId={''${SIP_PEER(''${PEERNAME},register_callid)}}
        content=ConfigVersionStamp={00000000-0000-0000-0000-000000000000}
        content=DialplanVersionStamp={00000000-0000-0000-0000-000000000000}
        content=SoftkeyVersionStamp={00000000-0000-0000-0000-000000000000}
        content=FeatureControlVersionStamp={00000000-0000-0000-0000-000000000000}
        ; Full reset: the phone re-runs its whole boot sequence, TFTP and all.
        [cisco-reset](cisco-service-control)
        content=action=reset
        content=RegisterCallId={''${SIP_PEER(''${PEERNAME},register_callid)}}
        content=ConfigVersionStamp={00000000-0000-0000-0000-000000000000}
        content=DialplanVersionStamp={00000000-0000-0000-0000-000000000000}
        content=SoftkeyVersionStamp={00000000-0000-0000-0000-000000000000}
        content=FeatureControlVersionStamp={00000000-0000-0000-0000-000000000000}
        ; Tell the phone to upload a problem report -- see the phone's web UI
        ; for where it lands.
        [cisco-prt-report](cisco-service-control)
        content=action=prt-report
        content=RegisterCallId={''${SIP_PEER(''${PEERNAME},register_callid)}}
      '';

      "pjsip.conf" = ''
        [global]
        type=global
        user_agent=Asterisk PBX

        ;=====================================================================
        ; Transports
        ;=====================================================================

        [transport-udp]
        type=transport
        protocol=udp
        bind=0.0.0.0:${toString cfg.pjsipPort}
        ${natSettings}

        ${trunkSections}

        ;=====================================================================
        ; Credentials (rendered at runtime by sops-nix)
        ;=====================================================================

        #include "${pjsipSecrets}"
      '';

      "extensions.conf" = ''
        [globals]
        DEFAULT_TRUNK=${cfg.defaultTrunk}
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: t: "CALLERID_${name}=${toString t.outboundCallerId}") (
            lib.filterAttrs (_: t: t.outboundCallerId != null) trunks
          )
        )}

        ;---------------------------------------------------------------------
        ; One context per line button. Which button the call was placed on is
        ; which peer the INVITE came from, which is this context -- so picking
        ; a line *is* picking a trunk, and there is nothing to dial for it.
        ;---------------------------------------------------------------------
        ${lib.concatMapStringsSep "\n" (l: ''
          [from-phone-${l.trunk}]
          exten => _[*+0-9].,1,Set(TRUNK=${l.trunk})
           same => n,Goto(from-phone,''${EXTEN},1)
        '') cfg.lines}

        ;---------------------------------------------------------------------
        ; Everything the phone dials, once its line has chosen a trunk
        ;---------------------------------------------------------------------
        [from-phone]
        ; Echo test, for proving the audio path without spending money.
        exten => 611,1,Answer()
         same => n,Wait(1)
         same => n,Playback(demo-echotest)
         same => n,Echo()
         same => n,Hangup()

        ; Override the line's trunk by prefix, for a trunk that has one. Note
        ; the phone's own dial rules have no entry for these, so they leave on
        ; the `*` catch-all timeout rather than the instant the last digit
        ; lands -- which is why the line buttons are the everyday way.
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            name: t:
            let
              skip = toString (builtins.stringLength t.dialPrefix);
            in
            "exten => _${t.dialPrefix}X.,1,Set(TRUNK=${name})\n same => n,Goto(normalise,\${EXTEN:${skip}},1)"
          ) (lib.filterAttrs (_: t: t.dialPrefix != null) trunks)
        )}

        ; Otherwise keep whatever the line set. DEFAULT_TRUNK is the belt and
        ; braces for a call that somehow arrived without one.
        exten => _X.,1,ExecIf($["''${TRUNK}" = ""]?Set(TRUNK=''${DEFAULT_TRUNK}))
         same => n,Goto(normalise,''${EXTEN},1)
        exten => _+X.,1,ExecIf($["''${TRUNK}" = ""]?Set(TRUNK=''${DEFAULT_TRUNK}))
         same => n,Goto(normalise,''${EXTEN},1)

        ;---------------------------------------------------------------------
        ; Normalise to E.164, whichever trunk was chosen
        ;---------------------------------------------------------------------
        [normalise]
        exten => _+X.,1,Goto(pstn,''${EXTEN},1)
        exten => _1NXXNXXXXXX,1,Goto(pstn,+''${EXTEN},1)
        exten => _NXXNXXXXXX,1,Goto(pstn,+1''${EXTEN},1)
        exten => _011X.,1,Goto(pstn,+''${EXTEN:3},1)
        exten => 911,1,Goto(pstn,911,1)
        exten => 933,1,Goto(pstn,933,1)

        ;---------------------------------------------------------------------
        ; Out
        ;---------------------------------------------------------------------
        [pstn]
        exten => _[+0-9].,1,NoOp(outbound ''${EXTEN} via ''${TRUNK})
         same => n,ExecIf($["''${CALLERID_''${TRUNK}}" != ""]?Set(CALLERID(num)=''${CALLERID_''${TRUNK}}))
         same => n,Dial(PJSIP/''${EXTEN}@''${TRUNK},60)
         same => n,Hangup()

        ;---------------------------------------------------------------------
        ; In -- one phone, but ring the line button that belongs to the trunk
        ; the call came in on, so the handset shows which number was called
        ; and answering it holds the right line.
        ;---------------------------------------------------------------------
        ${lib.concatMapStringsSep "\n" (l: ''
          [from-${l.trunk}]
          exten => _[+0-9].,1,NoOp(inbound ''${EXTEN} from ${l.trunk})
           same => n,Dial(SIP/${l.extension},30)
           same => n,Hangup()
        '') cfg.lines}
      '';
    };
  };

  # chan_sip takes the phone's password as a bare `secret=` inside the peer
  # section, so this file is #included mid-section rather than being a section
  # of its own.
  sops.templates."sip-secrets.conf" = {
    owner = "asterisk";
    content = ''
      secret=${config.sops.placeholder."phone/${ext}/password"}
    '';
  };

  sops.secrets = lib.mapAttrs' (_: t: lib.nameValuePair t.secretKey { }) trunks // {
    "phone/${ext}/password" = { };
  };

  sops.templates."pjsip-secrets.conf" = {
    owner = "asterisk";
    content = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: t: ''
        [${name}-auth]
        type=auth
        auth_type=userpass
        username=${t.user}
        password=${config.sops.placeholder.${t.secretKey}}
      '') trunks
    );
  };

  networking.firewall.allowedTCPPorts = [ cfg.sipPort ];
  networking.firewall.allowedUDPPorts = [
    cfg.sipPort
    cfg.pjsipPort
  ];
  networking.firewall.allowedUDPPortRanges = [ { inherit (cfg.rtpPortRange) from to; } ];
}
