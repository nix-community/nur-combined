{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.vacu.pbx;
  ext = cfg.extension;
  ip = config.vacuvmGuest.ip;
  configName = "SEP${cfg.phoneMac}.cnf.xml";

  # Cisco's own timezone spelling, not an IANA name. Keep in step with
  # common/nixos.nix's time.timeZone.
  ciscoTimeZone = "Pacific Standard/Daylight Time";

  # The phone's dial rules: how long to wait before sending what has been keyed,
  # so the user doesn't have to press Dial. Generated, because doing it properly
  # means knowing how long a phone number is in every country on earth; see
  # genDialplan below for the method and the correctness argument.
  #
  # Two wildcards: `.` is exactly one character, `*` is one or more (a literal
  # star key would be `\*`). There is no `!` -- that is IOS dial-peer syntax,
  # and a rule containing it never matches anything. There are no character
  # ranges either: `[2-9]` appears in some Cisco examples but is absent from the
  # documented pattern characters, which is why the local rules are eight
  # literal-first-digit rules rather than one.
  #
  # Keep the UPPERCASE `<DIALTEMPLATE MATCH= Timeout=>` spelling. The
  # usecallmanagernz reference files use lowercase `<dialTemplate match=
  # timeout=>` and XML is case-sensitive, so this looks like it ought to be
  # wrong -- but the uppercase form is what is actually deployed and working on
  # this 8851, with 10-digit numbers dialling the instant the last digit lands.
  # Don't "correct" it without a handset to test against.
  dialplanXml =
    pkgs.runCommand "dialplan.xml"
      {
        nativeBuildInputs = [
          (pkgs.python3.withPackages (ps: [
            ps.phonenumbers
            ps.regex
          ]))
        ];
      }
      ''
        python3 ${genDialplan} ${lib.optionalString (!cfg.perCountryDialRules) "--local-only"} > $out
      '';

  # Emits one Timeout="0" rule per (country code, leading-digit prefix), at the
  # longest national number that can begin with that prefix -- the point past
  # which no further digit can belong to the number, so the phone can send.
  #
  # Branching on leading digits rather than taking one length per country is
  # what makes this worth its ~2400 rules: a country's overall maximum is
  # usually set by some rare long service range, so a single per-country rule
  # almost never fires. Tokyo numbers are 9 digits but +81 runs to 17; Sydney is
  # 9 but +61 runs to 12. Splitting on the first digits collapses those to the
  # length that actually applies, and takes instant dialling from 56% of
  # libphonenumber's example numbers to 85%.
  #
  # It cannot make a number undialable, which is the property that matters: the
  # length attached to a prefix is the maximum over every number type whose
  # pattern that prefix could still grow into, so it is never shorter than a
  # real number starting that way. Countries with genuinely open numbering -- a
  # German landline is 5 to 15 digits and every Vorwahl reaches 15 -- simply
  # never tighten, and keep falling through to the `011*` timeout as before.
  #
  # The script re-checks all of that at build time against every example number
  # libphonenumber ships, and fails the build rather than emit a rule that would
  # dial one of them truncated. Metadata and python are build-time only; nothing
  # here reaches the guest's runtime closure.
  genDialplan = pkgs.writeText "gen-dialplan.py" ''
    """Generate the Cisco SIP dial rules, and prove they never truncate a number.

    Emits the whole DIALTEMPLATE. With --local-only, just the hand-written rules;
    otherwise also a rule per (country code, leading-digit prefix) at the longest
    national number that can begin with that prefix.
    """
    import re
    import sys

    import phonenumbers
    import regex
    from phonenumbers import PhoneNumberType, national_significant_number
    from phonenumbers import phonemetadata as pm
    from phonenumbers.phonenumberutil import COUNTRY_CODE_TO_REGION_CODE

    # How many leading digits of the national number we are willing to branch on.
    # 6 is where the output stops changing.
    MAX_PREFIX = 6

    TYPES = ("fixed_line", "mobile", "toll_free", "premium_rate", "shared_cost",
             "voip", "personal_number", "pager", "uan", "voicemail")

    # Local rules. Each is anchored on a literal leading digit: `.` matches any
    # character, so an unanchored 10-dot rule would also match the first ten keys
    # of an 011 dial string and, being the longer pattern, would win and place a
    # truncated international call.
    LOCAL = ([("611", 0), ("911", 0), ("933", 0), ("1" + "." * 10, 0)]
             + [(d + "." * 9, 0) for d in "23456789"])
    TRAILING = [("011*", 4), ("*", 5)]


    def number_types(cc):
        """(compiled pattern, longest valid length) for every number type on `cc`."""
        out = []
        for region in COUNTRY_CODE_TO_REGION_CODE[cc]:
            meta = (pm.PhoneMetadata.metadata_for_nongeo_region(cc, None)
                    if region == "001"
                    else pm.PhoneMetadata.metadata_for_region(region, None))
            if not meta:
                continue
            for name in TYPES:
                desc = getattr(meta, name, None)
                if (desc and desc.national_number_pattern
                        and desc.national_number_pattern != "NA" and desc.possible_length):
                    out.append((regex.compile(desc.national_number_pattern),
                                max(desc.possible_length)))
        return out


    def longest(types, prefix):
        """Longest valid national number starting with `prefix`; 0 if none can.

        fullmatch(partial=True) asks "could this string be extended into a valid
        number of this type" -- plain match() would also accept a prefix already
        longer than the type allows, quietly overstating the answer.
        """
        best = 0
        for rx, longest_for_type in types:
            if rx.fullmatch(prefix, partial=True):
                best = max(best, longest_for_type)
        return best


    def leaves(types, prefix=""):
        """Coarsest set of prefixes that each pin down a single longest length."""
        n = longest(types, prefix)
        if n == 0:
            return []
        if len(prefix) >= MAX_PREFIX:
            return [(prefix, n)]
        live = [(prefix + d, longest(types, prefix + d)) for d in "0123456789"]
        live = [(p, v) for p, v in live if v > 0]
        if not live or all(v == n for _, v in live):
            return [(prefix, n)]
        return [leaf for p, _ in live for leaf in leaves(types, p)]


    def country_rules():
        out = []
        for cc in sorted(COUNTRY_CODE_TO_REGION_CODE):
            types = number_types(cc)
            if not types:
                continue
            for prefix, n in leaves(types):
                out.append(("011" + str(cc) + prefix + "." * (n - len(prefix)), 0))
        return out


    def as_regex(pattern):
        body = "".join("." if c == "." else ".+" if c == "*" else re.escape(c)
                       for c in pattern)
        return re.compile("^" + body + "$")


    def verify(rules):
        """Fail if any rule would dial a truncated number.

        Walks every example number libphonenumber ships, keypress by keypress, and
        checks no Timeout=0 rule wins before the last digit. national_significant_
        number() rather than .national_number: the latter is an int, so it drops
        the leading zero that San Marino and Belize numbers actually carry.
        """
        by_len = {}
        wild = []
        for pattern, timeout in rules:
            if "*" in pattern:
                wild.append((as_regex(pattern), pattern, timeout))
            else:
                by_len.setdefault(len(pattern), []).append((as_regex(pattern), pattern, timeout))

        types = [getattr(PhoneNumberType, n) for n in
                 ("FIXED_LINE", "MOBILE", "TOLL_FREE", "PREMIUM_RATE", "SHARED_COST",
                  "VOIP", "PERSONAL_NUMBER", "PAGER", "UAN", "VOICEMAIL")]
        bad, instant, total = [], 0, 0
        for region in sorted(phonenumbers.SUPPORTED_REGIONS):
            for t in types:
                ex = phonenumbers.example_number_for_type(region, t)
                if not ex:
                    continue
                dial = "011" + str(ex.country_code) + national_significant_number(ex)
                total += 1
                for i in range(1, len(dial) + 1):
                    head = dial[:i]
                    hits = [(p, to) for rx, p, to in by_len.get(i, []) + wild if rx.match(head)]
                    if not hits:
                        continue
                    # "Rules are matched from start to finish with the longest
                    # matching rule taken as the one to use."
                    pattern, timeout = max(hits, key=lambda pt: len(pt[0]))
                    if timeout == 0:
                        if i < len(dial):
                            bad.append((region, dial, head, pattern))
                        else:
                            instant += 1
                        break
        if bad:
            for region, dial, head, pattern in bad[:20]:
                print(f"{region}: dialling {dial} fires at {head!r} via {pattern!r}",
                      file=sys.stderr)
            sys.exit(f"{len(bad)} of {total} example numbers would be dialled truncated")
        print(f"verified {total} example numbers, no truncation; "
              f"{instant} ({100 * instant // total}%) dial on the last digit",
              file=sys.stderr)


    def main():
        rules = LOCAL + ([] if "--local-only" in sys.argv else country_rules()) + TRAILING
        verify(rules)
        print("<DIALTEMPLATE>")
        for pattern, timeout in rules:
            print(f'  <TEMPLATE MATCH="{pattern}" Timeout="{timeout}"/>')
        print("</DIALTEMPLATE>")


    main()
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
