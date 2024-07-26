{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.stirling-pdf;
in
{
  options.services.stirling-pdf = {
    enable = mkEnableOption "Enable stirling-pdf service";

    package = mkPackageOption pkgs "stirling-pdf" { };

    environment = mkOption {
      type = types.attrsOf (types.nullOr (types.either types.str types.path));
      default = { };
      example = {
        SERVER_PORT = "8080";
        INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
      };
      description = ''
        Environment variables for the stirling-pdf app.
        See https://github.com/Stirling-Tools/Stirling-PDF#customisation for available options.
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        File containing additional environment variables to pass to Stirling PDF.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.stirling-pdf = {
      inherit (cfg) environment;

      # following the LocalRunGuide
      path = with pkgs; [
        unpaper
        libreoffice
        ocrmypdf
        poppler_utils
        unoconv
        opencv
        pngquant
        tesseract
        python3Packages.weasyprint
        calibre
      ];

      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        BindReadOnlyPaths = [ "${pkgs.tesseract}/share/tessdata:/usr/share/tessdata" ];
        CacheDirectory = "stirling-pdf";
        Environment = [ "HOME=%S/stirling-pdf" ];
        EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = getExe cfg.package;
        RuntimeDirectory = "stirling-pdf";
        StateDirectory = "stirling-pdf";
        SuccessExitStatus = 143;
        User = "stirling-pdf";
        WorkingDirectory = "/var/lib/stirling-pdf";

        # Hardening
        CapabilityBoundingSet = "";
        DynamicUser = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "~@cpu-emulation @debug @keyring @mount @obsolete @privileged @resources @clock @setuid @chown"
        ];
        UMask = "0077";
      };
    };
  };
}
