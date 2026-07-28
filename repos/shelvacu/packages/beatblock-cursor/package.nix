{
  runCommand,
  kdePackages,
  xcursorgen,
  inkscape,
}:
let
  cursor = builtins.path { path = ./cursor.svg; };
  theme_index = builtins.toFile "index.theme" ''
    [Icon Theme]
    Name=BeatblockCursor
    Comment=Cursor just for beatblock.
    Inherits=breeze_cursors
  '';
  metadata = [
    {
      filename = "default.svg";
      nominal_size = 24;
      hotspot_x = 12;
      hotspot_y = 12;
    }
  ];
  metadata_file = builtins.toFile "metadata.json" (builtins.toJSON metadata);
in
# see https://github.com/KDE/breeze/blob/master/cursors/svg-cursor-format.md
runCommand "beatblock-cursor"
  {
    nativeBuildInputs = [
      xcursorgen
      kdePackages.breeze
      inkscape
    ];
  }
  ''
    declare themeDir="$out/share/icons/BeatblockCursor"
    mkdir -p "$themeDir"
    cp ${theme_index} "$themeDir/index.theme"

    mkdir -p "$themeDir/cursors_scalable/default"
    inkscape ${cursor} --export-filename="$themeDir/cursors_scalable/default/default.svg" --export-plain-svg
    cp ${metadata_file} "$themeDir/cursors_scalable/default/metadata.json"

    # for alias in arrow left_ptr top_left_arrow; do
    #   ln -s "$themeDir/cursors_scalable/default" "$themeDir/cursors_scalable/$alias"
    # done

    cd "$themeDir"
    declare -a cmd=(
      kcursorgen
      --svg-theme-to-xcursor
      --svg-dir=cursors_scalable
      --xcursor-dir=cursors
      --sizes=12,18,24,30,36,42,48,54,60,66,72
      --scales=1
    )
    "''${cmd[@]}"
  ''
