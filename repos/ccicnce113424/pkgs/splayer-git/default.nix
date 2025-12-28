{
  sources,
  version,
  hash,
  pnpm_10,
  fetchPnpmDeps,
  makeDesktopItem,
  splayer,
}:
splayer.overrideAttrs (
  final: _prev: {
    inherit (sources) pname src;
    inherit version;
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      inherit hash;
      pnpm = pnpm_10;
      fetcherVersion = 2;
    };
    desktopItems = [
      (makeDesktopItem {
        name = "splayer";
        desktopName = "SPlayer";
        exec = "splayer %U";
        terminal = false;
        type = "Application";
        icon = "splayer";
        startupWMClass = "SPlayer";
        comment = "A minimalist music player";
        categories = [
          "AudioVideo"
          "Audio"
          "Music"
        ];
        mimeTypes = [ "x-scheme-handler/orpheus" ];
        extraConfig.X-KDE-Protocols = "orpheus";
      })
    ];
  }
)
