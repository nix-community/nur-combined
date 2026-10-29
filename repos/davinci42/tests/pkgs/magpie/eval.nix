{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;
  linuxPkgs =
    if pkgs.stdenv.hostPlatform.isLinux then pkgs else import pkgs.path { system = "x86_64-linux"; };
  evaluateNixos =
    extra:
    (import (pkgs.path + "/nixos/lib/eval-config.nix") {
      pkgs = linuxPkgs;
      system = linuxPkgs.stdenv.hostPlatform.system;
      modules = [
        ../../../modules/magpie-nixos.nix
        extra
      ];
    }).config;

  darwinBaseModule = {
    options = {
      assertions = lib.mkOption {
        type = lib.types.listOf lib.types.unspecified;
        default = [ ];
      };
      environment.systemPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
      };
      launchd.user.agents = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options.serviceConfig = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = { };
            };
          }
        );
        default = { };
      };
    };
  };

  evaluateDarwin =
    extra:
    (lib.evalModules {
      modules = [
        { _module.args = { inherit pkgs; }; }
        darwinBaseModule
        ../../../modules/magpie-darwin.nix
        extra
      ];
    }).config;

  nixosDisabled = evaluateNixos { };
  nixosEnabled = evaluateNixos { services.magpie.enable = true; };
  nixosCustom = evaluateNixos {
    services.magpie = {
      enable = true;
      package = linuxPkgs.hello;
      listenAddress = "[::1]";
      port = 13425;
      openFirewall = true;
      web = {
        enable = true;
        listenAddress = "0.0.0.0";
        port = 13430;
      };
      tls = {
        certFile = "/etc/ssl/magpie/cert.pem";
        keyFile = "/etc/ssl/magpie/key.pem";
      };
      extraArgs = [ "--gateway" ];
      settings = {
        chinaMirror = true;
        redact = true;
        noAutoUpdate = true;
        arbitraryFutureUpstreamSetting = {
          nested = [
            1
            2
            3
          ];
        };
      };
      settingsFile = "/run/secrets/magpie-settings.json";
      environment = {
        MAGPIE_PUBLIC_URL = "https://magpie.example.com";
        DO_NOT_TRACK = "0";
      };
      environmentFile = "/run/secrets/magpie.env";
    };
  };

  nixosConflict =
    name: value:
    evaluateNixos {
      services.magpie = {
        enable = true;
        environment.${name} = value;
      };
    };

  nixosPartialTls = evaluateNixos {
    services.magpie = {
      enable = true;
      tls.certFile = "/etc/ssl/magpie/cert.pem";
    };
  };

  nixosRelativeEnvFile = evaluateNixos {
    services.magpie = {
      enable = true;
      environmentFile = "relative.env";
    };
  };

  nixosRelativeSettingsFile = evaluateNixos {
    services.magpie = {
      enable = true;
      settingsFile = "relative.json";
    };
  };

  darwinDisabled = evaluateDarwin { };
  darwinEnabled = evaluateDarwin { services.magpie.enable = true; };
  darwinCustom = evaluateDarwin {
    services.magpie = {
      enable = true;
      logFile = "/tmp/magpie.log";
      web = {
        enable = true;
        listenAddress = "0.0.0.0";
        port = 13430;
      };
      settings = {
        theme = "dark";
        lang = "zh";
      };
      settingsFile = "/run/secrets/magpie-settings.json";
      environment = {
        MAGPIE_ALLOW_IPS = "127.0.0.1";
      };
      environmentFile = "/run/secrets/magpie.env";
    };
  };

  exportedWithoutPkgs = import ../../../default.nix { pkgs = null; };

  checks = {
    moduleExportsWithoutPkgs =
      builtins.isPath exportedWithoutPkgs.nixosModules.magpie
      && builtins.isPath exportedWithoutPkgs.darwinModules.magpie;

    nixosDisabledService = !(nixosDisabled.systemd.services ? magpie);
    nixosDisabledUser = !(nixosDisabled.users.users ? magpie);
    nixosPackageDefault = nixosDisabled.services.magpie.package.pname == "magpie";
    nixosDefaultBind = nixosEnabled.systemd.services.magpie.environment.MAGPIE_ADDR == "127.0.0.1:3425";
    nixosInstallsPackage = lib.elem nixosEnabled.services.magpie.package nixosEnabled.environment.systemPackages;
    nixosTelemetryDisabledByDefault =
      nixosEnabled.systemd.services.magpie.environment.DO_NOT_TRACK == "1"
      && nixosEnabled.systemd.services.magpie.environment.MAGPIE_NO_STATS == "1";
    nixosFirewallClosedByDefault = nixosEnabled.networking.firewall.allowedTCPPorts == [ ];
    nixosNoSecretFileByDefault =
      !(nixosEnabled.systemd.services.magpie.serviceConfig ? EnvironmentFile);

    nixosCustomBind = nixosCustom.systemd.services.magpie.environment.MAGPIE_ADDR == "[::1]:13425";
    nixosFirewallOpensGatewayAndWeb =
      nixosCustom.networking.firewall.allowedTCPPorts == [
        13425
        13430
      ];
    nixosTlsEnv =
      nixosCustom.systemd.services.magpie.environment.MAGPIE_TLS_CERT == "/etc/ssl/magpie/cert.pem"
      && nixosCustom.systemd.services.magpie.environment.MAGPIE_TLS_KEY == "/etc/ssl/magpie/key.pem";
    nixosExecStartWithWebAndExtraArgs =
      nixosCustom.systemd.services.magpie.serviceConfig.ExecStart
      == "${linuxPkgs.hello}/bin/magpie serve '--web=0.0.0.0:13430' --gateway";
    nixosCustomEnvironment =
      nixosCustom.systemd.services.magpie.environment.MAGPIE_PUBLIC_URL == "https://magpie.example.com"
      && nixosCustom.systemd.services.magpie.environment.DO_NOT_TRACK == "0";
    nixosPreStartSyncsSettings =
      lib.hasInfix "magpie-configure.py" nixosCustom.systemd.services.magpie.preStart
      && lib.hasInfix "--settings-file /run/secrets/magpie-settings.json" nixosCustom.systemd.services.magpie.preStart
      && lib.hasInfix "--config-dir /var/lib/magpie/magpie" nixosCustom.systemd.services.magpie.preStart;
    nixosSecretFile =
      nixosCustom.systemd.services.magpie.serviceConfig.EnvironmentFile == "/run/secrets/magpie.env";
    nixosFreeformSettingsPreserved =
      nixosCustom.services.magpie.settings.chinaMirror == true
      &&
        nixosCustom.services.magpie.settings.arbitraryFutureUpstreamSetting.nested == [
          1
          2
          3
        ];

    nixosRejectPartialTls = lib.any (
      item: !item.assertion && lib.hasInfix "tls.certFile" item.message
    ) nixosPartialTls.assertions;
    nixosRejectRelativeEnvFile =
      !(builtins.tryEval nixosRelativeEnvFile.services.magpie.environmentFile).success;
    nixosRejectRelativeSettingsFile =
      !(builtins.tryEval nixosRelativeSettingsFile.services.magpie.settingsFile).success;
    nixosRejectAddrConflict =
      !(builtins.tryEval (nixosConflict "MAGPIE_ADDR" "0.0.0.0:9999")
        .systemd.services.magpie.environment.MAGPIE_ADDR).success;

    darwinDisabledAgent = !(darwinDisabled.launchd.user.agents ? magpie);
    darwinEnabledAgent =
      darwinEnabled.launchd.user.agents.magpie.serviceConfig.Label == "com.yetone.magpie.serve"
      && darwinEnabled.launchd.user.agents.magpie.serviceConfig.RunAtLoad == true
      && darwinEnabled.launchd.user.agents.magpie.serviceConfig.ProcessType == "Background"
      &&
        darwinEnabled.launchd.user.agents.magpie.serviceConfig.EnvironmentVariables.MAGPIE_ADDR
        == "127.0.0.1:3425";
    darwinCustomAgent =
      darwinCustom.launchd.user.agents.magpie.serviceConfig.ProcessType == "Background"
      && darwinCustom.launchd.user.agents.magpie.serviceConfig.StandardOutPath == "/tmp/magpie.log"
      &&
        darwinCustom.launchd.user.agents.magpie.serviceConfig.EnvironmentVariables.MAGPIE_ALLOW_IPS
        == "127.0.0.1";
  };
  failures = lib.attrNames (lib.filterAttrs (_: passed: !passed) checks);
in
assert lib.assertMsg (failures == [ ]) "Failed checks: ${lib.concatStringsSep ", " failures}";
checks
