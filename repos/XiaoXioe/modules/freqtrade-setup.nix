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

    home.shellAliases = {
      freqtrade-venv = "export LD_LIBRARY_PATH=\"${cLibs}\${LD_LIBRARY_PATH:+:}\$LD_LIBRARY_PATH\" && export PYTHONWARNINGS=\"ignore:The HMAC key is\" && source ${cfg.configDir}/.venv/bin/activate";
    };


    # GENERATOR SYSTEMD USER SERVICES
    systemd.user.services = mkIf cfg.service.enable (
      mapAttrs' (
        botName: botCfg:
        nameValuePair "freqtrade-${botName}" {
          Unit = {
            Description = "Freqtrade Daemon - ${botName}";
            After = [ "network.target" ];
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            Type = "simple";
            WorkingDirectory = botCfg.strategiesDir;

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
          };
        }
      ) enabledBots
    );
  };
}
