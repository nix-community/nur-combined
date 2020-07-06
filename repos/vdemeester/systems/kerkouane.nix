{ pkgs, lib, ... }:

with lib;
let
  hostname = "kerkouane";

  networkingConfigPath = ../networking.nix;
  hasNetworkingConfig = (builtins.pathExists networkingConfigPath);
  secretPath = ../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);

  sshPort = if secretCondition then (import secretPath).ssh.kerkouane.port else 22;

  nginxExtraConfig = ''
    expires 31d;
    add_header Cache-Control "public, max-age=604800, immutable";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
    add_header X-Content-Type-Options "nosniff";
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Security-Policy "default-src 'self' *.sbr.pm *.sbr.systems *.demeester.fr";
    add_header X-XSS-Protection "1; mode=block";
  '';

  nginx = pkgs.nginxMainline.override (old: {
    modules = with pkgs.nginxModules; [
      fancyindex
    ];
  });

  filesWWW = {
    enableACME = true;
    forceSSL = true;
    root = "/home/vincent/desktop/sites/dl.sbr.pm";
    locations."/" = {
      index = "index.html";
      extraConfig = ''
        fancyindex on;
        fancyindex_localtime on;
        fancyindex_exact_size off;
        fancyindex_header "/.fancyindex/header.html";
        fancyindex_footer "/.fancyindex/footer.html";
        # fancyindex_ignore "examplefile.html";
        fancyindex_ignore "README.md";
        fancyindex_ignore "HEADER.md";
        fancyindex_ignore ".fancyindex";
        fancyindex_name_length 255;
      '';
    };
    extraConfig = nginxExtraConfig;
  };

  sources = import ../nix/sources.nix;
in
{
  imports = [
    (sources.nixos + "/nixos/modules/profiles/qemu-guest.nix")
    ./modules
    (import ../users).vincent
    (import ../users).root
  ]
  # digitalocean specifics
  ++ optionals hasNetworkingConfig [ networkingConfigPath ];

  networking.hostName = hostname;

  boot.loader.grub.device = "/dev/vda";
  fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };
  swapDevices = [{ device = "/swapfile"; size = 1024; }];

  core.nix = {
    # FIXME move this away
    localCaches = [ ];
    buildCores = 1;
  };

  profiles = {
    git.enable = true;
    ssh.enable = true;
    syncthing.enable = true;
    wireguard.server.enable = true;
  };

  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  security = {
    acme = {
      acceptTerms = true;
      email = "vincent@sbr.pm";
    };
    #acme.certs = {
    #  "sbr.pm".email = "vincent@sbr.pm";
    #};
  };
  security.pam.enableSSHAgentAuth = true;
  services = {
    govanityurl = {
      enable = true;
      user = "nginx";
      host = "go.sbr.pm";
      config = ''
        paths:
          /ape:
            repo: https://git.sr.ht/~vdemeester/ape
          /nr:
            repo: https://git.sr.ht/~vdemeester/nr
          /ram:
            repo: https://git.sr.ht/~vdemeester/ram
          /sec:
            repo: https://git.sr.ht/~vdemeester/sec
      '';
    };
    nginx = {
      enable = true;
      package = nginx;
      recommendedGzipSettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      virtualHosts."dl.sbr.pm" = filesWWW;
      virtualHosts."files.sbr.pm" = filesWWW;
      virtualHosts."paste.sbr.pm" = {
        enableACME = true;
        forceSSL = true;
        root = "/home/vincent/desktop/sites/paste.sbr.pm";
        locations."/" = {
          index = "index.html";
        };
        extraConfig = nginxExtraConfig;
      };
      virtualHosts."go.sbr.pm" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = { proxyPass = "http://127.0.0.1:8080"; };
        extraConfig = nginxExtraConfig;
      };
      virtualHosts."sbr.pm" = {
        enableACME = true;
        forceSSL = true;
        root = "/home/vincent/desktop/sites/sbr.pm";
        locations."/" = {
          index = "index.html";
        };
        extraConfig = nginxExtraConfig;
      };
      virtualHosts."sbr.systems" = {
        enableACME = true;
        forceSSL = true;
        root = "/home/vincent/desktop/sites/sbr.systems";
        locations."/" = {
          index = "index.html";
        };
        extraConfig = nginxExtraConfig;
      };
      virtualHosts."vincent.demeester.fr" = {
        enableACME = true;
        forceSSL = true;
        root = "/home/vincent/desktop/sites/vincent.demeester.fr";
        locations."/" = {
          index = "index.html";
          extraConfig = ''
            fancyindex on;
            fancyindex_localtime on;
            fancyindex_exact_size off;
            fancyindex_header "/assets/.fancyindex/header.html";
            fancyindex_footer "/assets/.fancyindex/footer.html";
            # fancyindex_ignore "examplefile.html";
            fancyindex_ignore "README.md";
            fancyindex_ignore "HEADER.md";
            fancyindex_ignore ".fancyindex";
            fancyindex_name_length 255;
          '';
        };
        extraConfig = nginxExtraConfig;
      };
    };
    openssh.ports = [ sshPort ];
    openssh.permitRootLogin = "without-password";
    syncthing.guiAddress = "127.0.0.1:8384";
  };
}
