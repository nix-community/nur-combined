{ lib, fetchFromGitHub
, python3Packages, wrapGAppsHook, gobject-introspection
, gtk-layer-shell, pango, gdk-pixbuf, atk
# Extra packages who's binary are required by nwg-panel
# These can also be left unused and leave it to the user's environment
# to have them
, sway             # swaylock, swaymsg
, systemd          # systemctl
, wlr-randr        # wlr-randr
, nwg-menu ? null  # nwg-menu
, withBluetoothControl ? true
, withBrightnessControl ? true, light
, withAudioControl ? true, pamixer, pulseaudio
}:

let
  inherit (lib) optionals;
  extraPackages = [ nwg-menu sway systemd wlr-randr ]
    ++ optionals withBrightnessControl [ light ] 
    ++ optionals withAudioControl [ pamixer pulseaudio ]
    ;
in
python3Packages.buildPythonApplication rec {
  pname = "nwg-panel";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-panel";
    rev = "v${version}";
    hash = "sha256-x5lGVF6eRhOVXrsBatdsiUiWs/+FxRlCtp79zA206RY=";
  };

  # No tests
  doCheck = false;

  # Because of wrapGAppsHook
  strictDeps = false;
  dontWrapGApps = true;

  buildInputs = [ atk gdk-pixbuf gtk-layer-shell pango ];
  nativeBuildInputs = [ wrapGAppsHook gobject-introspection ];
  propagatedBuildInputs = 
    with python3Packages; [ i3ipc netifaces psutil pygobject3 ]
    ++ optionals withBluetoothControl [ pybluez ];

  postInstall = ''
    mkdir -p $out/share/{applications,pixmaps}
    cp $src/nwg-panel-config.desktop $out/share/applications/
    cp $src/nwg-shell.svg $src/nwg-panel.svg $out/share/pixmaps/
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "$out/share"
    )
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --suffix PATH : "${lib.makeBinPath extraPackages}"
    )
  '';

  meta = with lib; {
    homepage = "https://github.com/nwg-piotr/nwg-panel";
    description = "GTK3-based panel for sway window manager";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ berbiche ];
  };
}
