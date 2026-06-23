{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.freqtrade-setup;
  extraPipStr = concatStringsSep " " cfg.extraPip;
  cLibs = pkgs.lib.makeLibraryPath (
    with pkgs;
    [
      stdenv.cc.cc.lib
      zlib
      ta-lib
    ]
  );

  # Kumpulkan hanya bot yang nilai enable-nya true
  enabledBots = filterAttrs (name: botCfg: botCfg.enable) cfg.service.bots;

  setupScript = pkgs.writeShellScriptBin "freqtrade-setup" ''
    DIR="${cfg.configDir}"
    MARKER_FILE="$DIR/.nix_branch_marker"

    show_help() {
      echo "=== Freqtrade Setup Utility ==="
      echo "  freqtrade-setup          : Inisialisasi awal / sinkronisasi branch"
      echo "  freqtrade-update         : Reset dan rakit ulang dari nol"
      exit 0
    }

    if [ "''${1:-}" = "--help" ] || [ "''${1:-}" = "-h" ]; then show_help; fi

    echo "🚀 Memeriksa lingkungan Freqtrade di: $DIR"
    mkdir -p "$DIR" && cd "$DIR" || exit 1

    if [ -f "$MARKER_FILE" ]; then
      OLD_BRANCH=$(cat "$MARKER_FILE")
      if [ "$OLD_BRANCH" != "${cfg.branch}" ]; then
        echo "🔄 Deteksi perubahan branch ($OLD_BRANCH -> ${cfg.branch})! Menghapus versi lama..."

        ${
          if cfg.service.enable then
            ''
              echo "🛑 Menghentikan servis yang berjalan..."
              ${concatStringsSep "\n" (
                mapAttrsToList (botName: _: "systemctl --user stop freqtrade-${botName} || true") enabledBots
              )}
            ''
          else
            ""
        }

        rm -rf freqtrade .venv
      fi
    fi

    if [ ! -d ".git" ]; then ${pkgs.git}/bin/git init -q; fi

    if [ ! -d "freqtrade" ]; then
      echo "📥 Mengunduh Freqtrade branch [${cfg.branch}]..."
      ${pkgs.git}/bin/git clone --depth=1 -b "${cfg.branch}" https://github.com/freqtrade/freqtrade freqtrade
    fi

    if [ ! -d ".venv" ]; then
      echo "🐍 Membangun Virtual Environment..."
      ${cfg.pythonPackage}/bin/python -m venv .venv
    fi

    source .venv/bin/activate

    if [ ! -f ".venv/bin/freqtrade" ]; then
      echo "📦 Menginstal dependensi inti..."
      pip install -q -e freqtrade/
    fi

    if [ -n "${extraPipStr}" ]; then
      echo "📦 Menginstal dependensi ekstra..."
      pip install -q ${extraPipStr}
    fi

    echo "${cfg.branch}" > "$MARKER_FILE"

    ${
      if cfg.service.enable then
        ''
          echo "⚙️  Membangunkan daemon Systemd..."
          systemctl --user daemon-reload
          ${concatStringsSep "\n" (
            mapAttrsToList (botName: _: ''
              echo "▶️  Menyalakan servis bot: ${botName}..."
              systemctl --user start freqtrade-${botName} || true
            '') enabledBots
          )}
        ''
      else
        ""
    }

    echo "✅ Setup selesai! Freqtrade siap beraksi."
  '';

  updateScript = pkgs.writeShellScriptBin "freqtrade-update" ''
    DIR="${cfg.configDir}"
    echo "🚨 Memulai pembersihan total..."

    ${
      if cfg.service.enable then
        ''
          echo "🛑 Mematikan semua bot yang berjalan..."
          ${concatStringsSep "\n" (
            mapAttrsToList (botName: _: "systemctl --user stop freqtrade-${botName} || true") enabledBots
          )}
        ''
      else
        ""
    }

    rm -rf "$DIR/freqtrade" "$DIR/.venv" "$DIR/.nix_branch_marker"
    "${setupScript}/bin/freqtrade-setup"
  '';

  globalWrapper = pkgs.writeShellScriptBin "freqtrade" ''
    export LD_LIBRARY_PATH="${cLibs}:$LD_LIBRARY_PATH"
    export PYTHONWARNINGS="ignore:The HMAC key is"

    VENV_BIN="${cfg.configDir}/.venv/bin/freqtrade"
    if [ ! -x "$VENV_BIN" ]; then
      echo "⚠️  Lingkungan belum siap. Jalankan 'freqtrade-setup' terlebih dahulu!"
      exit 1
    fi

    exec "$VENV_BIN" "$@"
  '';

  logRotateScript = pkgs.writeShellScriptBin "freqtrade-log-rotate" ''
    LOG_FILE="$1"
    MAX_SIZE_STR="$2"
    
    if [ -z "$LOG_FILE" ] || [ -z "$MAX_SIZE_STR" ]; then
      exit 0
    fi
    
    if [ ! -f "$LOG_FILE" ]; then
      exit 0
    fi
    
    # Parse max size
    MAX_SIZE_BYTES=$(${pkgs.coreutils}/bin/numfmt --from=iec "$MAX_SIZE_STR" 2>/dev/null || echo "10485760")
    CURRENT_SIZE=$(${pkgs.coreutils}/bin/stat -c %s "$LOG_FILE")
    
    if [ "$CURRENT_SIZE" -ge "$MAX_SIZE_BYTES" ]; then
      TIMESTAMP=$(${pkgs.coreutils}/bin/date +"%Y%m%d-%H%M%S")
      BACKUP_FILE="''${LOG_FILE%.log}-$TIMESTAMP.log"
      
      ${pkgs.coreutils}/bin/cp "$LOG_FILE" "$BACKUP_FILE"
      ${pkgs.coreutils}/bin/truncate -s 0 "$LOG_FILE"
      
      # Keep only 5 newest backups
      BACKUPS=($(${pkgs.coreutils}/bin/ls -1t ''${LOG_FILE%.log}-*.log 2>/dev/null))
      COUNT=0
      for f in "''${BACKUPS[@]}"; do
        COUNT=$((COUNT+1))
        if [ "$COUNT" -gt 5 ]; then
          ${pkgs.coreutils}/bin/rm -f "$f"
        fi
      done
    fi
  '';

in
{
  # ==========================================
  # DEKLARASI OPSI / INTERFAKS KONFIGURASI
  # ==========================================
  options.programs.freqtrade-setup = {
    enable = mkEnableOption "Aktifkan Freqtrade Global Setup";

    configDir = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.local/share/freqtrade-dev";
    };

    branch = mkOption {
      type = types.str;
      default = "stable";
    };

    extraPip = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    pythonPackage = mkOption {
      type = types.package;
      default = pkgs.python313;
      description = "Paket Python yang digunakan untuk membuat virtual environment Freqtrade.";
    };


    service = {
      enable = mkEnableOption "Aktifkan otomatisasi background service (Systemd)";

      startupDelay = mkOption {
        type = types.str;
        default = "";
        example = "2m";
        description = "Waktu tunda sebelum service dimulai secara otomatis setelah login (menggunakan systemd timer). Kosongkan jika tidak ingin ada jeda.";
      };

      bots = mkOption {
        description = "Definisi instance bot Freqtrade";
        default = { };
        type = types.attrsOf (
          types.submodule {
            options = {
              enable = mkOption {
                type = types.bool;
                default = true;
                description = "Aktifkan atau matikan eksekusi bot ini di Systemd";
              };
              strategiesDir = mkOption { type = types.str; };
              strategyRun = mkOption { type = types.str; };
              configFile = mkOption {
                type = types.str;
                default = "config.json";
              };
              extraOpts = mkOption {
                type = types.listOf types.str;
                default = [ ];
              };
              extra = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "Command ekstra yang dijalankan bersama bot (misal uvicorn)";
              };
              disableLogs = mkOption {
                type = types.bool;
                default = false;
                description = "Matikan output log ke journalctl (mencegah log penuh)";
              };
              logToFile = mkOption {
                type = types.bool;
                default = false;
                description = "Simpan log langsung ke file di user_data/logs/ daripada ke journalctl.";
              };
              logMaxSize = mkOption {
                type = types.str;
                default = "10M";
                example = "50M";
                description = "Batas maksimal ukuran file log sebelum dirotasi. Jika melebihi, rotasi dilakukan saat restart.";
              };
              memoryLimit = mkOption {
                type = types.str;
                default = "";
                example = "4G";
                description = "Batas maksimal RAM (mencegah OOM freeze). Kosongkan jika tanpa batas.";
              };
            };
          }
        );
      };
    };
  };

  # ==========================================
  # IMPLEMENTASI / EKSEKUSI
  # ==========================================
  config = mkIf cfg.enable {
    home.packages = [
      setupScript
      updateScript
      globalWrapper
    ];

    programs.bash.shellAliases = {
      freqtrade-venv = "export LD_LIBRARY_PATH=\"${cLibs}\${LD_LIBRARY_PATH:+:}\$LD_LIBRARY_PATH\" && export PYTHONWARNINGS=\"ignore:The HMAC key is\" && source ${cfg.configDir}/.venv/bin/activate";
    };
    programs.zsh.shellAliases = {
      freqtrade-venv = "export LD_LIBRARY_PATH=\"${cLibs}\${LD_LIBRARY_PATH:+:}\$LD_LIBRARY_PATH\" && export PYTHONWARNINGS=\"ignore:The HMAC key is\" && source ${cfg.configDir}/.venv/bin/activate";
    };
    programs.fish.shellAliases = {
      freqtrade-venv = "set -gx LD_LIBRARY_PATH \"${cLibs}\" \$LD_LIBRARY_PATH; set -gx PYTHONWARNINGS \"ignore:The HMAC key is\"; source ${cfg.configDir}/.venv/bin/activate.fish";
    };



    # GENERATOR SYSTEMD USER SERVICES
    systemd.user.services = mkIf cfg.service.enable (
      mkMerge (
        mapAttrsToList (botName: botCfg: 
          let
            mainService = {
              "freqtrade-${botName}" = {
                Unit = {
                  Description = "Freqtrade Daemon - ${botName}";
                  After = [ "network-online.target" "time-sync.target" ];
                  Wants = [ "network-online.target" ] ++ imap0 (i: _: "freqtrade-${botName}-extra-${toString i}.service") botCfg.extra;
                } // (if cfg.service.startupDelay != "" then {
                  # Kosongkan WantedBy jika menggunakan timer
                } else {});
                Service = {
                  Type = "simple";
                  WorkingDirectory = botCfg.strategiesDir;
                  StandardOutput = if botCfg.disableLogs then "null" 
                                   else if botCfg.logToFile then "append:${botCfg.strategiesDir}/user_data/logs/freqtrade-${botName}.log" 
                                   else null;
                  StandardError = if botCfg.disableLogs then "null" 
                                  else if botCfg.logToFile then "append:${botCfg.strategiesDir}/user_data/logs/freqtrade-${botName}.log" 
                                  else null;

                  Environment = [
                    "LD_LIBRARY_PATH=${cLibs}"
                    "PYTHONWARNINGS=ignore:The HMAC key is"
                  ];

                  ExecCondition = "${pkgs.coreutils}/bin/test -x ${cfg.configDir}/.venv/bin/freqtrade";

                  ExecStart = ''
                    ${cfg.configDir}/.venv/bin/freqtrade trade \
                      --config ${botCfg.strategiesDir}/${botCfg.configFile} \
                      --userdir ${botCfg.strategiesDir}/user_data \
                      --strategy ${botCfg.strategyRun} \
                      ${escapeShellArgs botCfg.extraOpts}
                  '';

                  Restart = "always";
                  RestartSec = "10s";
                } // (if botCfg.logToFile then {
                  ExecStartPre = [
                    "${pkgs.coreutils}/bin/mkdir -p ${botCfg.strategiesDir}/user_data/logs"
                    "${logRotateScript}/bin/freqtrade-log-rotate ${botCfg.strategiesDir}/user_data/logs/freqtrade-${botName}.log ${botCfg.logMaxSize}"
                  ];
                } else {}) // (if botCfg.memoryLimit != "" then {
                  MemoryMax = botCfg.memoryLimit;
                } else {});
              };
            };
            extraServices = listToAttrs (imap0 (i: cmd: 
              nameValuePair "freqtrade-${botName}-extra-${toString i}" {
                Unit = {
                  Description = "Freqtrade Extra ${toString i} - ${botName}";
                  PartOf = [ "freqtrade-${botName}.service" ];
                  After = [ "network-online.target" "time-sync.target" ];
                  Wants = [ "network-online.target" ];
                };
                Install = {
                  WantedBy = [ "freqtrade-${botName}.service" ];
                };
                Service = {
                  Type = "simple";
                  WorkingDirectory = botCfg.strategiesDir;
                  StandardOutput = if botCfg.disableLogs then "null" 
                                   else if botCfg.logToFile then "append:${botCfg.strategiesDir}/user_data/logs/freqtrade-${botName}-extra-${toString i}.log" 
                                   else null;
                  StandardError = if botCfg.disableLogs then "null" 
                                  else if botCfg.logToFile then "append:${botCfg.strategiesDir}/user_data/logs/freqtrade-${botName}-extra-${toString i}.log" 
                                  else null;
                  Environment = [
                    "LD_LIBRARY_PATH=${cLibs}"
                    "PYTHONWARNINGS=ignore:The HMAC key is"
                  ];
                  ExecStart = "${pkgs.bash}/bin/bash -c 'source ${cfg.configDir}/.venv/bin/activate && exec ${cmd}'";
                  Restart = "always";
                  RestartSec = "10s";
                } // (if botCfg.logToFile then {
                  ExecStartPre = [
                    "${pkgs.coreutils}/bin/mkdir -p ${botCfg.strategiesDir}/user_data/logs"
                    "${logRotateScript}/bin/freqtrade-log-rotate ${botCfg.strategiesDir}/user_data/logs/freqtrade-${botName}-extra-${toString i}.log ${botCfg.logMaxSize}"
                  ];
                } else {}) // (if botCfg.memoryLimit != "" then {
                  MemoryMax = botCfg.memoryLimit;
                } else {});
              }
            ) botCfg.extra);
            
            # Tambahkan Install.WantedBy ke mainService jika tidak ada startupDelay
            mainServiceWithInstall = if cfg.service.startupDelay == "" then
              {
                "freqtrade-${botName}" = mainService."freqtrade-${botName}" // {
                  Install = { WantedBy = [ "default.target" ]; };
                };
              }
            else
              mainService;
          in
          mainServiceWithInstall // extraServices
        ) enabledBots
        ++ [
          {
            freqtrade-logrotate = {
              Unit = {
                Description = "Rotate Freqtrade log files";
              };
              Service = {
                Type = "oneshot";
                ExecStart = pkgs.writeShellScript "freqtrade-logrotate-run" ''
                  ${concatStringsSep "\n" (
                    mapAttrsToList (botName: botCfg:
                      optionalString botCfg.logToFile (
                        ''
                          ${logRotateScript}/bin/freqtrade-log-rotate "${botCfg.strategiesDir}/user_data/logs/freqtrade-${botName}.log" "${botCfg.logMaxSize}"
                        '' + concatStringsSep "\n" (
                          imap0 (i: _: ''
                            ${logRotateScript}/bin/freqtrade-log-rotate "${botCfg.strategiesDir}/user_data/logs/freqtrade-${botName}-extra-${toString i}.log" "${botCfg.logMaxSize}"
                          '') botCfg.extra
                        )
                      )
                    ) enabledBots
                  )}
                '';
              };
            };
          }
        ]
      )
    );

    # GENERATOR SYSTEMD USER TIMERS (DELAYED STARTUP & LOG ROTATION)
    systemd.user.timers = mkIf cfg.service.enable (
      mkMerge [
        (mkIf (cfg.service.startupDelay != "") (
          listToAttrs (mapAttrsToList (botName: botCfg: 
            nameValuePair "freqtrade-${botName}" {
              Unit = {
                Description = "Delayed Startup Timer for Freqtrade - ${botName}";
              };
              Timer = {
                OnStartupSec = cfg.service.startupDelay;
              };
              Install = {
                WantedBy = [ "timers.target" ];
              };
            }
          ) enabledBots)
        ))
        {
          freqtrade-logrotate = {
            Unit = {
              Description = "Run Freqtrade log rotation hourly";
            };
            Timer = {
              OnCalendar = "hourly";
              Persistent = true;
            };
            Install = {
              WantedBy = [ "timers.target" ];
            };
          };
        }
      ]
    );
  };
}
