{
  pkgs,
  nodes,
  lib,
  vacuRoot,
  ...
}:
let
  certs = import /${vacuRoot}/deterministic-certs.nix { nixpkgs = pkgs; };
  kanidmDomain = "kanidm.test.example.com";
  rootCA = certs.selfSigned "kanidm-test-ca" {
    ca = true;
    cert_signing_key = true;
    cn = "Kanidm test CA";
  };
  kanidmCert = certs.caSigned "kanidm-test-cert" rootCA {
    ca = false;
    signing_key = true;
    encryption_key = true;
    data_encipherment = true;
    tls_www_client = true;
    tls_www_server = true;
    cn = kanidmDomain;
    dns_name = kanidmDomain;
  };
  fileServerDomain = "files.test.example.com";
  fileServerCert = certs.caSigned "file-server-cert" rootCA {
    ca = false;
    signing_key = true;
    encryption_key = true;
    data_encipherment = true;
    tls_www_client = true;
    tls_www_server = true;
    cn = fileServerDomain;
    dns_name = fileServerDomain;
  };
  kanidmPassword = "test-admin-password";
  awesomeFile = pkgs.writeText "awesomefile.txt" "This is the contents of the awesome file";
  fileServerWebRoot = pkgs.linkFarmFromDrvs "test-fileserver-webroot" [ awesomeFile ];
  clientSecretFile = pkgs.writeText "clientSecret" "test-client-secret";
  oauthModule =
    { vacuModules, ... }:
    {
      imports = [ vacuModules.auto-oauth-proxy ];
      options.sops = lib.mkOption { };
      config.vacu.oauthProxy = {
        kanidmDomain = kanidmDomain;
        instances.file_server = {
          enable = true;
          appDomain = fileServerDomain;

          configureCaddy = lib.mkDefault false;
          configureKanidm = lib.mkDefault false;
          clientSecret.path = clientSecretFile;
          basicAuthAccounts = {
            # password is "test" and "test2"
            test = [
              "$2a$14$fa/B67RyOVk60919Bj9Z.ObyYXQl3gYexztCfh3Y9YrS6Q/5YIG9m"
              "$2a$14$OzR29jA1L4hjuf9JlUeqU.GJs7Zp1uSpk3eVwQkiX4bfUhrBwcubO"
            ];
          };
        };
      };
    };
  kanidmPackage = pkgs.kanidmWithSecretProvisioning_1_7;
in
{
  name = "caddy-kanidm";

  defaults =
    {
      security.pki.certificateFiles = [ rootCA.certificatePath ];
      networking.hosts = {
        ${nodes.kanidm.networking.primaryIPAddress} = [ kanidmDomain ];
        ${nodes.fileServer.networking.primaryIPAddress} = [ fileServerDomain ];
      };
    };

  nodes.kanidm =
    { ... }:
    {
      imports = [ oauthModule ];
      vacu.oauthProxy.instances.file_server = {
        configureKanidm = true;
        kanidmMembers = [ "testperson" ];
      };

      networking.firewall.allowedTCPPorts = [ 443 ];
      
      services.kanidm = {
        package = kanidmPackage;
        enableServer = true;
        serverSettings = {
          tls_chain = kanidmCert.certificatePath;
          tls_key = kanidmCert.privateKeyPath;
          origin = "https://${kanidmDomain}";
          domain = kanidmDomain;
          bindaddress = "0.0.0.0:443";
        };
        provision = {
          enable = true;
          adminPasswordFile = pkgs.writeText "testAdminPassword.txt" kanidmPassword;
          idmAdminPasswordFile = pkgs.writeText "testAdminPassword.txt" kanidmPassword;
          persons.testperson = {
            present = true;
            mailAddresses = [ "testperson@${kanidmDomain}" ];
            displayName = "Testithy";
          };
        };
      };
    };

  nodes.fileServer =
    { ... }:
    {
      imports = [ oauthModule ];
      vacu.oauthProxy.instances.file_server = {
        configureCaddy = true;
        caddyConfig = ''
          root * ${fileServerWebRoot}
          file_server browse
        '';
      };

      services.caddy = {
        enable = true;
        virtualHosts.${fileServerDomain}.extraConfig = ''
          tls ${fileServerCert.certificatePath} ${fileServerCert.privateKeyPath}
        '';
      };

      networking.firewall.allowedTCPPorts = [ 80 443 ];
    };

  nodes.client =
    { ... }:
    {
      environment.systemPackages = [
        pkgs.wget
        pkgs.xvfb-run
        (pkgs.writers.writePython3Bin "kanidmGetResetToken" {
          libraries = [
            (
              pkgs.python3Packages.kanidm.overridePythonAttrs {
                src = kanidmPackage.src;
                build-system = [ pkgs.python3Packages.pdm-backend ];
              }
            )
          ];
          doCheck = false;
        } ./kanidmGetResetToken.py)
      ];

      services.kanidm = {
        package = kanidmPackage;
        enableClient = true;
        clientSettings.uri = "https://${kanidmDomain}";
      };

      services.squid = {
        enable = true;
        proxyPort = 8888;
      };

      networking.firewall.allowedTCPPorts = [ 8888 ];
    };

  testScript =
    let
      rawFile = builtins.readFile ./testScript/main.py;
      data = {
        inherit kanidmPassword;
        playwrightDriverBrowsers = pkgs.playwright-driver.browsers;
      };
      dataJson = builtins.toJSON data;
      res = builtins.replaceStrings [ "@data@" ] [ dataJson ] rawFile;
    in
    res;

  skipTypeCheck = true;
  skipLint = true;
  extraPythonPackages = p: [
    p.pyotp
    p.playwright
  ];
}
