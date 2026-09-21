{ pkgs, config, ... }:
let
  cfg = config.vacu.pbx;
  ext = cfg.extension;
  ip = config.vacuvmGuest.ip;
  configName = "SEP${cfg.phoneMac}.cnf.xml";

  # Cisco's own timezone spelling, not an IANA name. Keep in step with
  # common/nixos.nix's time.timeZone.
  ciscoTimeZone = "Pacific Standard/Daylight Time";

  # The phone's dial rules: how long to wait before sending what has been
  # keyed, so the user doesn't have to press Dial. `.` is one digit, `!` is one
  # or more; the last entry is the catch-all inter-digit timeout. These mirror
  # the [from-phone] patterns in extensions.conf.
  dialplanXml = pkgs.writeText "dialplan.xml" ''
    <DIALTEMPLATE>
      <TEMPLATE MATCH="611" Timeout="0"/>
      <TEMPLATE MATCH="911" Timeout="0"/>
      <TEMPLATE MATCH="933" Timeout="0"/>
      <TEMPLATE MATCH="1.........." Timeout="0"/>
      <TEMPLATE MATCH=".........." Timeout="0"/>
      <TEMPLATE MATCH="011!" Timeout="4"/>
      <TEMPLATE MATCH="*" Timeout="5"/>
    </DIALTEMPLATE>
  '';
in
{
  # The 8851 is running Cisco's *enterprise* (Unified CM) SIP firmware, so it
  # provisions the CUCM way: on boot it TFTPs SEP<MAC>.cnf.xml and takes its
  # whole identity from it. Everything else it asks for along the way
  # (CTLSEP<MAC>.tlv, ITLSEP<MAC>.tlv, SEP<MAC>.cnf.xml.sgn, locale files) is
  # absent on purpose — atftpd answers "file not found" and the phone falls
  # back to running unsigned and unlocalised, which is what we want.
  services.atftpd = {
    enable = true;
    root = cfg.tftpRoot;
    # Log every request: watching this is how you tell "the phone never asked"
    # apart from "the phone asked and did not like the answer". Deliberately
    # bound to 0.0.0.0 rather than this VM's address, so a slow networkd cannot
    # make the daemon fail its bind at boot.
    extraOptions = [ "--verbose=5" ];
  };
  # atftpd exits if it cannot bind; without this a transient failure is permanent.
  systemd.services.atftpd.serviceConfig.Restart = "on-failure";
  networking.firewall.allowedUDPPorts = [ 69 ];

  systemd.tmpfiles.rules = [
    "d ${cfg.tftpRoot} 0755 root root -"
    "L+ ${cfg.tftpRoot}/dialplan.xml - - - - ${dialplanXml}"
  ];

  # Rendered straight into the TFTP root rather than /run/secrets/rendered, so
  # atftpd (which drops to nobody) can read it without chasing a symlink into
  # the secrets tree. It contains the line's SIP password, which is why it is a
  # sops template and not a store path — although note TFTP hands it to anyone
  # on the LAN who asks for the right filename, so the real protection is that
  # the LAN is trusted.
  sops.templates.${configName} = {
    path = "${cfg.tftpRoot}/${configName}";
    mode = "0444";
    content = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <device>
        <fullConfig>true</fullConfig>
        <deviceProtocol>SIP</deviceProtocol>
        <devicePool>
          <dateTimeSetting>
            <dateTemplate>M/D/Y</dateTemplate>
            <timeZone>${ciscoTimeZone}</timeZone>
            <ntps>
              <ntp>
                <name>${ip}</name>
                <ntpMode>unicast</ntpMode>
              </ntp>
            </ntps>
          </dateTimeSetting>
          <callManagerGroup>
            <members>
              <member priority="0">
                <callManager>
                  <ports>
                    <sipPort>${toString cfg.sipPort}</sipPort>
                    <securedSipPort>5061</securedSipPort>
                  </ports>
                  <processNodeName>${ip}</processNodeName>
                </callManager>
              </member>
            </members>
          </callManagerGroup>
        </devicePool>
        <sipProfile>
          <sipProxies>
            <registerWithProxy>true</registerWithProxy>
          </sipProxies>
          <sipCallFeatures>
            <callHoldRingback>1</callHoldRingback>
            <semiAttendedTransfer>true</semiAttendedTransfer>
            <anonymousCallBlock>0</anonymousCallBlock>
            <callerIdBlocking>0</callerIdBlocking>
            <!-- Cisco call-completion is one of the proprietary extensions
                 stock asterisk does not speak. -->
            <remoteCcEnable>false</remoteCcEnable>
            <uriDialingDisplayPreference>1</uriDialingDisplayPreference>
          </sipCallFeatures>
          <sipStack>
            <sipInviteRetx>6</sipInviteRetx>
            <sipRetx>10</sipRetx>
            <timerInviteExpires>180</timerInviteExpires>
            <timerRegisterExpires>3600</timerRegisterExpires>
            <timerKeepAliveExpires>120</timerKeepAliveExpires>
            <remotePartyID>true</remotePartyID>
          </sipStack>
          <autoAnswerTimer>1</autoAnswerTimer>
          <autoAnswerAltBehavior>false</autoAnswerAltBehavior>
          <transferOnhookEnabled>false</transferOnhookEnabled>
          <enableVad>false</enableVad>
          <alwaysUsePrimeLine>false</alwaysUsePrimeLine>
          <phoneLabel>${cfg.phoneLabel}</phoneLabel>
          <callStats>false</callStats>
          <sipLines>
            <line button="1" lineIndex="1">
              <!-- featureID 9 is a plain line appearance. -->
              <featureID>9</featureID>
              <featureLabel>${ext}</featureLabel>
              <!-- USECALLMANAGER: use the callManagerGroup member above as the
                   proxy, rather than a separate address here. -->
              <proxy>USECALLMANAGER</proxy>
              <port>${toString cfg.sipPort}</port>
              <name>${ext}</name>
              <displayName>${ext}</displayName>
              <contact>${ext}</contact>
              <authName>${ext}</authName>
              <authPassword>${config.sops.placeholder."phone/${ext}/password"}</authPassword>
              <autoAnswer>
                <autoAnswerEnabled>0</autoAnswerEnabled>
              </autoAnswer>
              <callWaiting>1</callWaiting>
              <sharedLine>false</sharedLine>
              <messageWaitingLampPolicy>3</messageWaitingLampPolicy>
              <messageWaitingAMWI>0</messageWaitingAMWI>
              <messagesNumber></messagesNumber>
              <ringSettingIdle>4</ringSettingIdle>
              <ringSettingActive>5</ringSettingActive>
              <maxNumCalls>4</maxNumCalls>
              <busyTrigger>2</busyTrigger>
            </line>
          </sipLines>
          <dialTemplate>dialplan.xml</dialTemplate>
        </sipProfile>
        <!-- 1 = TCP. The enterprise firmware's UDP stack retransmits
             aggressively against non-CUCM proxies; the matching asterisk
             endpoint is pinned to transport-tcp. -->
        <transportLayerProtocol>1</transportLayerProtocol>
        <!-- 1 = non-secure. 2/3 would require TLS and a CAPF/CTL setup. -->
        <deviceSecurityMode>1</deviceSecurityMode>
        <vendorConfig>
          <!-- 0 = enabled. The phone's web UI is the only practical way to read
               its status/logs, and this LAN is trusted. -->
          <webAccess>0</webAccess>
          <sshAccess>1</sshAccess>
          <settingsAccess>1</settingsAccess>
          <disableSpeaker>false</disableSpeaker>
          <disableSpeakerAndHeadset>false</disableSpeakerAndHeadset>
        </vendorConfig>
        <userLocale>
          <name>English_United_States</name>
          <version>1.0.0.0-1</version>
          <winCharSet>utf-8</winCharSet>
        </userLocale>
        <networkLocaleInfo>
          <name>United_States</name>
          <version>1.0.0.0-1</version>
        </networkLocaleInfo>
        <!-- Deliberately no <loadInformation>: leaving it out means the phone
             keeps whatever firmware it already has instead of hunting this
             TFTP server for a .loads it will not find. -->
        <authenticationURL></authenticationURL>
        <directoryURL></directoryURL>
        <idleURL></idleURL>
        <informationURL></informationURL>
        <messagesURL></messagesURL>
        <proxyServerURL></proxyServerURL>
        <servicesURL></servicesURL>
      </device>
    '';
  };
}
