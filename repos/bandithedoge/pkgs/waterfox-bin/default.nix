{
  pkgs,
  sources,
  config,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.waterfox-bin) pname version src;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = with pkgs; [
    alsa-lib
    dbus-glib
    gtk3
    stdenv.cc.cc.lib
    xorg.libXtst
  ];

  runtimeDependencies = with pkgs; [
    curl
    libva.out
    pciutils
  ];

  appendRunpaths = with pkgs; [
    (lib.getLib pipewire)
  ];

  buildPhase = let
    policies =
      {
        DisableAppUpdate = true;
      }
      // config.firefox.policies or {};
  in ''
    mkdir -p $out/{bin,lib/waterfox}
    cp -r * $out/lib/waterfox

    mkdir $out/lib/waterfox/distribution
    ln -s $out/lib/waterfox/waterfox $out/bin/waterfox
    # echo '${builtins.toJSON {inherit policies;}}' > $out/lib/waterfox/distribution/policies.json

    for i in 16 32 48 64 128
    do
      mkdir -p "$out/share/icons/hicolor/$(echo $i)x$(echo $i)/apps"
      ln -s $out/lib/waterfox/browser/chrome/icons/default/default$i.png "$out/share/icons/hicolor/$(echo $i)x$(echo $i)/apps/waterfox.png"
    done
  '';

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "Waterfox";
      exec = "waterfox %U";
      desktopName = "Waterfox";
      genericName = "Web Browser";
      icon = "waterfox";
      mimeTypes = [
        "application/vnd.mozilla.xul+xml"
        "application/xhtml+xml"
        "text/html"
        "text/xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      startupNotify = true;
      startupWMClass = "waterfox";
      terminal = false;
      categories = ["Network" "WebBrowser"];
      actions = {
        new-private-window = {
          exec = "waterfox --private-window %U";
          name = "New Private Window";
        };
        new-window = {
          exec = "waterfox --new-window %U";
          name = "New Window";
        };
        profile-manager-window = {
          exec = "waterfox --ProfileManager";
          name = "Profile Manager";
        };
      };
    })
  ];

  passthru = {
    binaryName = "waterfox";
    libName = "waterfox";
    inherit (pkgs) gtk3;

    alsaSupport = true;
    pipewireSupport = true;
  };

  meta = with pkgs.lib; {
    description = "Fast and Private Web Browser";
    homepage = "https://www.waterfox.net/";
    license = licenses.mpl20;
    platforms = ["x86_64-linux"];
    sourceProvenance = [sourceTypes.binaryNativeCode];
  };
}
