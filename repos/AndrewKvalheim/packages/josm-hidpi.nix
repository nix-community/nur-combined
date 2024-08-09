{ makeWrapper
, runCommand

  # Dependencies
, josm
}:

runCommand "josm-hidpi" { nativeBuildInputs = [ makeWrapper ]; } ''
  makeWrapper ${josm}/bin/josm $out/bin/josm-hidpi \
    --set 'GDK_SCALE' '2'

  mkdir --parents "$out/share/applications"
  substitute ${josm}/share/applications/org.openstreetmap.josm.desktop \
    $out/share/applications/josm-hidpi.desktop \
    --replace-fail 'Name=JOSM' 'Name=JOSM (scale 2×)' \
    --replace-fail 'Exec=josm' "Exec=$out/bin/josm-hidpi"
''
