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

  setupScript = pkgs.writeShellScriptBin "freqtrade-setup" ''
    DIR="${cfg.configDir}"
    MARKER_FILE="$DIR/.nix_branch_marker"

    show_help() {
      echo "=== Freqtrade Setup Utility ==="
      echo "Perintah pembantu otomatisasi lingkungan kerja Freqtrade via Nix."
      echo ""
      echo "Penggunaan:"
      echo "  freqtrade-setup          Menjalankan instalasi/inisialisasi awal"
      echo "  freqtrade-setup --help   Menampilkan pesan bantuan ini"
      echo "  freqtrade-setup -h       Menampilkan pesan bantuan ini"
      echo ""
      echo "Konfigurasi Saat Ini (via Home Manager):"
      echo "  Direktori Target : $DIR"
      echo "  Branch Git       : ${cfg.branch}"
      echo "  Paket Pip Ekstra : ${if extraPipStr == "" then "(Tidak ada)" else extraPipStr}"
    }

    # Penanganan argumen --help
    if [ "''${1:-}" = "--help" ] || [ "''${1:-}" = "-h" ]; then
      show_help
      exit 0
    fi

    echo "🚀 Memeriksa lingkungan Freqtrade di: $DIR"
    mkdir -p "$DIR"
    cd "$DIR" || exit 1

    # OTOMATISASI DETEKSI PERUBAHAN BRANCH
    if [ -f "$MARKER_FILE" ]; then
      OLD_BRANCH=$(cat "$MARKER_FILE")
      if [ "$OLD_BRANCH" != "${cfg.branch}" ]; then
        echo "🔄 Deteksi perubahan konfigurasi branch di Home Manager ($OLD_BRANCH -> ${cfg.branch})!"
        echo "🗑️  Menghapus folder lama secara otomatis untuk menghindari konflik versi..."
        rm -rf freqtrade .venv
      fi
    fi

    # Otomatisasi Git Init & Clone
    if [ ! -d ".git" ]; then ${pkgs.git}/bin/git init -q; fi
    if [ ! -d "freqtrade" ]; then
      echo "📥 Mengunduh Freqtrade branch [${cfg.branch}]..."
      ${pkgs.git}/bin/git clone --depth=1 -b "${cfg.branch}" https://github.com/freqtrade/freqtrade freqtrade
    fi

    # Membangun Virtual Environment
    if [ ! -d ".venv" ]; then
      echo "🐍 Membangun Virtual Environment..."
      ${pkgs.python313}/bin/python -m venv .venv
    fi

    source .venv/bin/activate

    if [ ! -f ".venv/bin/freqtrade" ]; then
      echo "📦 Menginstal dependensi inti Freqtrade..."
      pip install -q -e freqtrade/
    fi

    if [ -n "${extraPipStr}" ]; then
      echo "📦 Menginstal dependensi ekstra: ${extraPipStr}..."
      pip install -q ${extraPipStr}
    fi

    # Simpan status branch saat ini ke file penanda
    echo "${cfg.branch}" > "$MARKER_FILE"
    echo "✅ Semua siap! Gunakan perintah 'freqtrade' untuk memulai."
  '';

  updateScript = pkgs.writeShellScriptBin "freqtrade-update" ''
    DIR="${cfg.configDir}"
    echo "🚨 Memulai pembersihan total lingkungan Freqtrade..."
    echo "🗑️  Menghapus folder: $DIR/freqtrade dan $DIR/.venv"
    rm -rf "$DIR/freqtrade" "$DIR/.venv" "$DIR/.nix_branch_marker"

    echo "🔄 Menjalankan ulang inisialisasi awal..."
    "${setupScript}/bin/freqtrade-setup"
  '';

  globalWrapper = pkgs.writeShellScriptBin "freqtrade" ''
    export LD_LIBRARY_PATH="${cLibs}:$LD_LIBRARY_PATH"
    export PYTHONWARNINGS="ignore:The HMAC key is"

    VENV_BIN="${cfg.configDir}/.venv/bin/freqtrade"

    if [ ! -x "$VENV_BIN" ]; then
      echo "⚠️  Lingkungan belum siap atau baru saja diubah."
      echo "💡 Silakan jalankan perintah 'freqtrade-setup' terlebih dahulu!"
      exit 1
    fi

    exec "$VENV_BIN" "$@"
  '';

in
{
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
  };

  config = mkIf cfg.enable {
    home.packages = [
      setupScript # Menyediakan perintah 'freqtrade-setup'
      updateScript # Menyediakan perintah 'freqtrade-update'
      globalWrapper # Menyediakan perintah 'freqtrade' global
    ];
  };
}
