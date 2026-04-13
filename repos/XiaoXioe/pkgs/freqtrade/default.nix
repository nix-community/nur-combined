{
  lib,
  stdenv,
  buildFHSEnv,
  writeScript,
  writeShellScriptBin,
  python3,
  python3Packages,
  gcc,
  gnumake,
  ta-lib,
  zlib,
  glib,
  git,
  openssl,
}:

let
  fhs = buildFHSEnv {
    name = "freqtrade-env";
    targetPkgs = pkgs: [
      python3
      python3Packages.pip
      python3Packages.virtualenv
      python3Packages.wheel
      gcc
      gnumake
      ta-lib
      zlib
      glib
      git
      openssl
      # Dependency krusial untuk libstdc++.so.6 dan library dasar C
      stdenv.cc.cc.lib
      pkgs.linuxHeaders
    ];

    # Menambahkan library ke LD_LIBRARY_PATH di dalam FHS
    multiPkgs = pkgs: [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
    ];

    runScript = "bash";
  };

  initScript = writeScript "freqtrade-init.sh" ''
    #!/bin/bash
    FREQ_DIR="$HOME/.local/share/freqtrade-venv"

    # Pastikan library terdeteksi oleh compiler saat pip install
    export TA_INCLUDE_PATH="${ta-lib}/include"
    export TA_LIBRARY_PATH="${ta-lib}/lib"

    # Agar compiler menemukan libstdc++ saat build wheel via pip
    export LD_LIBRARY_PATH="/lib:/usr/lib:/lib64:/usr/lib64:$LD_LIBRARY_PATH"

    if [ ! -d "$FREQ_DIR" ]; then
        echo "Membuat virtual environment baru di $FREQ_DIR..."
        ${python3Packages.virtualenv}/bin/virtualenv "$FREQ_DIR"
        "$FREQ_DIR/bin/pip" install --upgrade pip wheel
        "$FREQ_DIR/bin/pip" install git+https://github.com/freqtrade/freqtrade.git@stable
    fi

    if [ "$1" == "--update" ]; then
        echo "Memperbarui Freqtrade..."
        "$FREQ_DIR/bin/pip" install --upgrade pip wheel
        "$FREQ_DIR/bin/pip" install --upgrade --force-reinstall git+https://github.com/freqtrade/freqtrade.git@stable
        echo "Update selesai!"
        exit 0
    fi

    source "$FREQ_DIR/bin/activate"
    exec freqtrade "$@"
  '';
in
(writeShellScriptBin "freqtrade" ''
  ${fhs}/bin/freqtrade-env ${initScript} "$@"
'').overrideAttrs
  (old: {
    meta = with lib; {
      description = "Free, open source crypto trading bot (Standalone FHS + Venv)";
      homepage = "https://github.com/freqtrade/freqtrade";
      license = licenses.gpl3Only;
      maintainers = [ "XiaoXioe" ];
      mainProgram = "freqtrade";
    };
  })
