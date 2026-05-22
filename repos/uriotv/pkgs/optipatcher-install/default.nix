{
  lib,
  writeShellApplication,
  coreutils,
  curl,
  gnugrep,
  gnused,
  jq,
}:

writeShellApplication {
  name = "optipatcher-install";

  runtimeInputs = [
    coreutils
    curl
    gnugrep
    gnused
    jq
  ];

  text = ''
    set -e

    echo "Downloading latest OptiPatcher..."
    URL=$(curl -sL "https://api.github.com/repos/optiscaler/OptiPatcher/releases/latest" | jq -r '.assets[0].browser_download_url')

    mkdir -p plugins
    curl -sL "$URL" -o plugins/OptiPatcher.asi

    if [ -f "OptiScaler.ini" ]; then
      sed -i 's/LoadAsiPlugins=false/LoadAsiPlugins=true/' OptiScaler.ini 2>/dev/null || true
      sed -i 's/LoadAsiPlugins=auto/LoadAsiPlugins=true/' OptiScaler.ini 2>/dev/null || true
      grep -q "LoadAsiPlugins" OptiScaler.ini || printf '\n[Plugins]\nLoadAsiPlugins=true\n' >> OptiScaler.ini
    fi

    echo ""
    echo "Done! OptiPatcher.asi installed to plugins/"
    echo "Supported games: https://github.com/optiscaler/OptiPatcher/blob/main/GameSupport.md"
  '';

  meta = with lib; {
    description = "Downloader for the latest OptiPatcher ASI plugin";
    homepage = "https://github.com/optiscaler/OptiPatcher";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "optipatcher-install";
  };
}
