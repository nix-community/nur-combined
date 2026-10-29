{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.seowebchecker;
in {
  options.services.seowebchecker = {
    enable = mkEnableOption "SEOWebChecker automated SEO audit service";

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The SEOWebChecker package to use.";
    };

    urls = mkOption {
      type = types.listOf types.str;
      default = [ "https://seowebchecker.com/" ];
      example = [ "https://seowebchecker.com/" "https://example.com/" ];
      description = "List of target website URLs to audit.";
    };

    schedule = mkOption {
      type = types.str;
      default = "daily";
      example = "*-*-* 04:00:00";
      description = "systemd OnCalendar schedule string for periodic SEO audits.";
    };

    outputDir = mkOption {
      type = types.path;
      default = "/var/log/seowebchecker";
      description = "Directory where SEO audit result reports will be saved.";
    };

    format = mkOption {
      type = types.enum [ "json" "markdown" "text" ];
      default = "json";
      description = "Output format for audit reports (json, markdown, or text).";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.outputDir} 0750 root root -"
    ];

    systemd.services.seowebchecker = {
      description = "SEOWebChecker automated website SEO audit";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "seowebchecker-runner" ''
          set -euo pipefail
          DATE=$(date +%Y-%m-%d_%H%M%S)
          mkdir -p "${cfg.outputDir}"
          ${concatMapStringsSep "\n" (url: ''
            TARGET_SLUG=$(echo "${url}" | sed -e 's/[^a-zA-Z0-9]/_/g')
            OUT_FILE="${cfg.outputDir}/audit_''${TARGET_SLUG}_''${DATE}.${cfg.format}"
            echo "Auditing ${url} -> ''${OUT_FILE}..."
            ${cfg.package}/bin/seowebchecker "${url}" --format "${cfg.format}" > "''${OUT_FILE}" || true
          '') cfg.urls}
        '';
        PrivateTmp = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.outputDir ];
      };
    };

    systemd.timers.seowebchecker = {
      description = "Timer for periodic SEOWebChecker website SEO audits";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
    };
  };
}
