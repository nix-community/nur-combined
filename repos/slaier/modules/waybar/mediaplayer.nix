{ lib
, stdenv
, wrapGAppsHook
, gobject-introspection
, glib
, playerctl
, python3
}:

stdenv.mkDerivation {
  pname = "waybar-mediaplayer";
  version = "0.1.0";

  src = lib.sourceFilesBySuffices ./. [ ".py" ];

  nativeBuildInputs = [
    wrapGAppsHook
    gobject-introspection
  ];

  propagatedBuildInputs = [
    glib
    playerctl
    python3.pkgs.pygobject3
  ];

  strictDeps = false;

  installPhase = ''
    mkdir -p $out/bin
    cp $src/mediaplayer.py $out/bin/waybar-mediaplayer.py
    wrapProgram $out/bin/waybar-mediaplayer.py \
      --prefix PYTHONPATH : "$PYTHONPATH:$out/${python3.sitePackages}"
  '';

  meta = with lib; {
    description = "Generic MediaPlayer for waybar";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "waybar-mediaplayer.py";
    homepage = "https://github.com/Alexays/Waybar/blob/master/resources/custom_modules/mediaplayer.py";
  };
}
