{
  pkgs,
  nodes,
  lib,
  vacuRoot,
  ...
}:
let
  certs = import /${vacuRoot}/deterministic-certs.nix { nixpkgs = pkgs; };
  relayDomain = "relay.test.example.com";
  rootCA = certs.selfSigned "liam-test" {
    ca = true;
    cert_signing_key = true;
    cn = "Liam test CA";
  };
  relayCert = certs.caSigned "liam-relay" rootCA {
    ca = false;
    signing_key = true;
    encryption_key = true;
    data_encipherment = true;
    tls_www_client = true;
    tls_www_server = true;
    cn = relayDomain;
    dns_name = relayDomain;
  };
  relayUser = "foobar@shelvacu.com";
  relayPass = "asdfghjkl";
  relayPassFile = pkgs.writeText "relay-password-file" "${relayUser}:${relayPass}";

  testAgeSecret = "AGE-SECRET-KEY-1QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQPQQ94XCHF";
  testAgeSecretFile = pkgs.writeText "test-age-key" testAgeSecret;
  testBorgKey = "1234567890";

  sopsTestSecrets = {
    "liam-borg-key" = testBorgKey;
    "dovecot-passwd" =
      (lib.concatStringsSep "\n" (
        map (name: "${name}:{plain}${name}::::::") [
          "shelvacu"
          "julie"
          "vacustore"
        ]
      ))
      + ''

        backup:::::::'';
    dkim_key = ''
      -----BEGIN PRIVATE KEY-----
      MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBANn62hMdcFw4znAB
      CKth6N4JD8XrNezCYbvyrUcVpGkkMX3TC9sEyZgGV6Y2Cs/J2Q6jKakC47nXebzV
      Edk/kWsApj4J7PQl4t/G3vf1rdfICQx1pIspsmqQKsYugUG18EugEZzelai3+n4U
      wqsed4551aRtwaws8dJQePOEEq1BAgMBAAECgYEAummKgXpVkqiJ8sMPlPEgYnHB
      aXLjJNx/FGpOwVHCzp/DK2WG6ADKHhaecmgZCuYFmDz07bKo6U9arqBQqUdxpUor
      JT2SS9RFP5MTsTB6R+eRqX8oMRQhcXB/+MczoSV/087vIZsL3L//6XoGyvjuHKW/
      bvUR/F8PhB84uPU6RLkCQQDzXXj80iRhY6jHDwqoGf3BXd4O4cIAzPbBXN0W41fV
      L5ZBm0K0KAgLnyjVygbsSn6lXsZXzAa/wAbSstMeCn7PAkEA5Uv88nfZSLU99XvF
      WB9GD7lKXsAnWlf09F8hH4a1TH/zfGUCxrDdYNmdBdG6t0XuIVjay3TZcpW68Z2Q
      lLeW7wJACj7KJCKYo3z1kwPAGBmYBDb2bTv11eDLFpLZP+hsPy5UrghiQ4FX7V1S
      88Ugi3wLXtzhjrqpIhNsdhxPJPmeIwJAVpx8YE4a+hbT340v/thZS4ku6Vllw/9j
      XIcuaM0mYE4Yd81j3g9in7mzUUZmY+H7UAdTJfTuShT6t1dQDIzIawJBAIJ+azsj
      H5M2KsE3Nuxe3RODM/D4I5M5dngTkgNZQvUAywAyj9U39ZeFPEyXJyGkKNoR2CXB
      hCvgabgr0wsi1y0=
      -----END PRIVATE KEY-----
    '';
    relay_creds = "[${relayDomain}]:587 ${relayUser}:${relayPass}";
  };
  sopsTestSecretsYaml = pkgs.writeText "test-secrets-plain.json.yaml" (
    builtins.toJSON sopsTestSecrets
  );
  sopsTestSecretsFolder = pkgs.runCommand "test-secrets-encrypted" { } ''
    mkdir -p "$out"/hosts
    SOPS_AGE_KEY=${lib.escapeShellArg testAgeSecret} ${pkgs.sops}/bin/sops --verbose  -e --age "$(printf '%s' ${lib.escapeShellArg testAgeSecret} | ${pkgs.age}/bin/age-keygen -y)" --output-type yaml ${lib.escapeShellArg sopsTestSecretsYaml} > "$out"/hosts/liam.yaml
  '';
  mailtestModule =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      libraries = with pkgs.python3Packages; [
        imap-tools
        requests
      ];
      mkPkg =
        name:
        pkgs.writers.writePython3Bin "mailtest-${name}" { inherit libraries; } ''
          # flake8: noqa
          ${builtins.readFile ./mailtest/${name}.py}
        '';
    in
    {
      options.vacu.mailtest = lib.mkOption { readOnly = true; };
      config.vacu.mailtest = {
        smtp = mkPkg "smtp";
        imap = mkPkg "imap";
        mailpit = mkPkg "mailpit";
      };
      config.environment.systemPackages = builtins.attrValues config.vacu.mailtest;
    };
in
{
  name = "liam-receives-mail";

  nodes.ns =
    { lib, nodes, ... }:
    let
      liam_config = nodes.liam;
    in
    {
      networking.firewall.allowedUDPPorts = [ 53 ];
      services.bind.enable = true;
      services.bind.extraOptions = "empty-zones-enable no;";
      services.bind.zones = [
        {
          name = ".";
          master = true;
          file = pkgs.writeText "root.zone" ''
            $TTL 3600
            . IN SOA ns. fake-hostmaster.example.com. ( 1 1 1 1 1 )
            . IN NS ns.
            ${relayDomain}. IN A ${nodes.relay.networking.primaryIPAddress}
            ${lib.concatMapStringsSep "\n" (
              node: "${node.networking.hostName}. IN A ${node.networking.primaryIPAddress}"
            ) (builtins.attrValues nodes)}
            ${lib.concatMapStringsSep "\n" (d: ''
              ${d}. IN  A ${nodes.liam.networking.primaryIPAddress}
              ${d}. IN  MX 0 ${d}.
              ${d}. IN  TXT  ( "v=spf1 mx -all" ) ;
              ${liam_config.services.opendkim.selector}._domainkey.${d}.  IN      TXT     ( "v=DKIM1; k=rsa; "
                "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDZ+toTHXBcOM5wAQirYejeCQ/F6zXswmG78q1HFaRpJDF90wvbBMmYBlemNgrPydkOoympAuO513m81RHZP5FrAKY+Cez0JeLfxt739a3XyAkMdaSLKbJqkCrGLoFBtfBLoBGc3pWot/p+FMKrHneOedWkbcGsLPHSUHjzhBKtQQIDAQAB" )
            '') liam_config.vacu.liam.domains}
          '';
        }
      ];
    };

  nodes.relay =
    { pkgs, config, ... }:
    let
      mailpit = pkgs.mailpit;
      dir = "/var/lib/mailpit";
    in
    {
      networking.firewall.enable = false;
      users.groups.mailpit = { };
      users.users.mailpit = {
        isSystemUser = true;
        home = dir;
        createHome = true;
        group = config.users.groups.mailpit.name;
      };
      systemd.services.mailpit = {
        environment = {
          MP_DATABASE = "${dir}/mailpit.db";
          MP_SMTP_TLS_CERT = relayCert.certificatePath;
          MP_SMTP_TLS_KEY = relayCert.privateKeyPath;
          MP_SMTP_REQUIRE_STARTTLS = "true";
          MP_SMTP_BIND_ADDR = "0.0.0.0:587";
          MP_SMTP_AUTH_FILE = "${relayPassFile}";
          MP_UI_BIND_ADDR = "0.0.0.0:8025";
        };
        serviceConfig.ExecStart = "${mailpit}/bin/mailpit";
        # serviceConfig.Restart = "always";
        serviceConfig.User = config.users.users.mailpit.name;
        serviceConfig.Group = config.users.groups.mailpit.name;
        serviceConfig.AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        wantedBy = [ "multi-user.target" ];
      };
    };

  nodes.liam =
    {
      lib,
      inputs,
      config,
      ...
    }:
    {
      imports = [
        /${vacuRoot}/common
        /${vacuRoot}/hosts/liam
      ];
      vacu.underTest = true;
      #systemd.tmpfiles.settings."69-whatever"."/run/secretKey".L.argument = "${testAgeSecretFile}";
      systemd.services."acme-liam.dis8.net".enable = lib.mkForce false;
      systemd.timers."acme-liam.dis8.net".enable = lib.mkForce false;
      systemd.services."acme-selfsigned-liam.dis8.net".wantedBy = [
        "postfix.service"
        "dovecot2.service"
      ];
      systemd.services."acme-selfsigned-liam.dis8.net".before = [
        "postfix.service"
        "dovecot2.service"
      ];
      vacu.sops.secretsPath = "${sopsTestSecretsFolder}";
      vacu.liam.relayhosts = {
        shelvacuAlt = "[badhost.blarg]:587";
        allDomains = "[${relayDomain}]:587";
      };
      system.activationScripts.sopsHack.text = "ln -s ${testAgeSecretFile} /run/secretKey";
      system.activationScripts.setupSecrets.deps = [ "sopsHack" ];
      sops.age.keyFile = "/run/secretKey";
      services.do-agent.enable = false;
      virtualisation.digitalOcean = {
        seedEntropy = false;
        setSshKeys = false;
        rebuildFromUserData = false;
        setRootPassword = false;
      };
      # uncomment to significantly speed up the test
      services.dovecot2.enableDHE = lib.mkForce false;
      security.acme.defaults.email = lib.mkForce "me@example.org";
      security.acme.defaults.server = lib.mkForce "https://example.com"; # self-signed only
      networking.nameservers = lib.mkForce [ nodes.ns.networking.primaryIPAddress ];
      security.pki.certificateFiles = [ rootCA.certificatePath ];

      vacu.liam.backup.keyPath = pkgs.writeText "test-borg-key" testBorgKey;
      vacu.hosts.rsn.sshKeys = lib.mkForce [ ]; # remove known key so i can do a trust-on-first-use in the test
      networking.hosts."${nodes.rsyncnet.networking.primaryIPAddress}" = [
        config.vacu.liam.backup.rsyncHost
      ];
    };

  nodes.rsyncnet =
    { ... }:
    let
      borgCfg = nodes.liam.vacu.liam.backup;
      user = borgCfg.rsyncUser;
    in
    {
      users.users.${user} = {
        isNormalUser = true;
        createHome = true;
        # shell = null;
        home = "/home/${user}";
      };
      services.openssh = {
        enable = true;
        settings = {
          AllowUsers = [ user ];
          # ForceCommand = lib.getExe loginCommand;
        };
      };
      environment.systemPackages = [
        (lib.hiPrio (
          pkgs.writeScriptBin "borg" ''
            echo "bad: called plain bin/borg" >&2
            exit 1
          ''
        ))
        (pkgs.writeScriptBin "borg14" ''
          exec ${lib.getExe pkgs.borgbackup} "$@"
        '')
        pkgs.borgbackup
        (pkgs.writers.writeBashBin "borg-init" { } ''
          set -euo pipefail
          export BORG_PASSPHRASE=${lib.escapeShellArg testBorgKey}
          export BORG_NEW_PASSPHRASE=${lib.escapeShellArg testBorgKey}
          ${lib.getExe pkgs.borgbackup} init --encryption repokey-blake2 --make-parent-dirs /home/${user}/borg-repos/liam-backup
        '')
      ];
    };

  nodes.checker =
    { pkgs, lib, ... }:
    {
      imports = [ mailtestModule ];
      environment.systemPackages = [ pkgs.wget ];
      networking.nameservers = lib.mkForce (lib.singleton nodes.ns.networking.primaryIPAddress);
    };

  testScript =
    let
      rawFile = builtins.readFile ./testScript/main.py;
      data = {
        checkSieve = lib.getExe nodes.liam.vacu.checkSieve;
        acmeTest = pkgs.writeText "acme-test" "test";
        acmeTestDest = nodes.liam.security.acme.defaults.webroot + "/.well-known/acme-challenge/test";
        relayIP = nodes.relay.networking.primaryIPAddress;
        liamIP = nodes.liam.networking.primaryIPAddress;
        inherit testBorgKey;
        borgExe = lib.getExe pkgs.borgbackup;
      };
      dataJson = builtins.toJSON data;
      res = builtins.replaceStrings [ "@data@" ] [ dataJson ] rawFile;
    in
    res;

  skipTypeCheck = true;
  skipLint = true;
}
