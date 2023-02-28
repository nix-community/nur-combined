{
  sources,
  lib,
  appimageTools,
  ...
}:
appimageTools.wrapType2 rec {
  inherit (sources.an-anime-game-launcher-bin) pname version src;

  extraInstallCommands = let
    contents = appimageTools.extract {inherit pname version src;};
  in ''
    mv $out/bin/${pname}-${version} $out/bin/an-anime-game-launcher
    cp -r ${contents}/usr/share $out/
    substituteInPlace $out/share/applications/an-anime-game-launcher.desktop \
      --replace "Exec=AppRun" "Exec=$out/bin/an-anime-game-launcher"
  '';

  extraPkgs = pkgs:
    with pkgs; [
      webkitgtk
      libayatana-appindicator
      unzip
      gnutar
      git
      curl
      xdelta
      cabextract
      libnotify
    ];

  meta = with lib; {
    description = "(EXPERIMENTAL: Needs manual game patching) An Anime Game launcher for Linux with automatic patching fixing detection of Linux/Wine and telemetry disabling";
    homepage = "https://github.com/an-anime-team/an-anime-game-launcher";
    license = licenses.gpl3;
  };
}
