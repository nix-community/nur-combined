{ lib
, stdenvNoCC
, fetchFromGitHub
, xorg
, librsvg
, findutils
, colorScheme ? {
    main = "#8a80e0";
    stroke = "#1c1a2d";
    accent = "#c1bbfe";
    contextMenu = "#c1bbfe";
    loadingBackground = "#534d86";
    loadingForeground = "#8a80e0";
    notAllowed = "#8a80e0";
  }
, ...
}:
stdenvNoCC.mkDerivation {
  pname = "afterglow-cursors-recolored-custom";
  version = "0-unstable-2023-10-04";

  src = fetchFromGitHub {
    owner = "TeddyBearKilla";
    repo = "Afterglow-Cursors-Recolored";
    rev = "940a5d30e52f8c827fa249d2bbcc4af889534888";
    hash = "sha256-GR+d+jrbeIGpqal5krx83PxuQto2PQTO3unQ+jaJf6s=";
  };

  buildInputs = [ xorg.xcursorgen librsvg findutils ];

  patchPhase = ''

    find "src/svg" -name "*.svg" -type f \
      -execdir sed -i 's/#111111/${colorScheme.main}/g' "{}" \+ \
      -execdir sed -i 's/#222222/${colorScheme.stroke}/g' "{}" \+ \
      -execdir sed -i 's/#333333/${colorScheme.accent}/g' "{}" \+ \
      -execdir sed -i 's/#444444/${colorScheme.contextMenu}/g' "{}" \+ \
      -execdir sed -i 's/#555555/${colorScheme.loadingBackground}/g' "{}" \+ \
      -execdir sed -i 's/#666666/${colorScheme.loadingForeground}/g' "{}" \+ \
      -execdir sed -i 's/#777777/${colorScheme.notAllowed}/g' "{}" \+
  '';

  buildPhase = ''
    ls "$src/src/svg"
    mkdir -p "$TEMPDIR/preparing/x1" "$TEMPDIR/preparing/x1_25" "$TEMPDIR/preparing/x1_5" "$TEMPDIR/preparing/x2" "$TEMPDIR/theme/cursors"

    for file in "$src"/src/svg/*.svg; do
      basename="$file"
      basename="''${basename##*/}" # remove the longest "*/" (parent dir)
      basename="''${basename%.svg}" # remove ".svg" file extension
      rsvg-convert -o "$TEMPDIR/preparing/x1/$basename.png" -w 32 -h 32 $file
      rsvg-convert -o "$TEMPDIR/preparing/x1_25/$basename.png" -w 40 -h 40 $file
      rsvg-convert -o "$TEMPDIR/preparing/x1_5/$basename.png" -w 48 -h 48 $file
      rsvg-convert -o "$TEMPDIR/preparing/x2/$basename.png" -w 64 -h 64 $file
    done

    cd "$TEMPDIR/preparing" # we need to cd because all cursor configs have hardcoded paths
    for cursor_config in $src/src/config/*.cursor; do
      basename="$cursor_config"
      basename="''${basename##*/}" # remove the longest "*/" (parent dir)
      basename="''${basename%.cursor}" # remove ".cursor" file extension
      xcursorgen "$cursor_config" "$TEMPDIR/theme/cursors/$basename"
    done

    cd "$TEMPDIR/theme/cursors"
    while read current_alias; do
      file="''${current_alias#* }"
    linkto="''${current_alias% *}"
      if [ -e $linkto ]; then
        continue
      fi
      ln -sr "$file" "$linkto"
    done < "$src/src/cursorList"
    cd $src
    echo -e "[Icon Theme]\nName=Afterglow Custom\nComment=Afterglow Custom Cursor pack.\n" > "$TEMPDIR/theme/index.theme"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/icons"
    cp -r "$TEMPDIR/theme" "$out/share/icons/Afterglow-Recolored-Custom"
    runHook postInstall
  '';

  meta = with lib; {
    description = "A recoloring of the Afterglow Cursors x-cursor theme (now with color scheme settings)";
    longDescription = ''
      This is reworked afterglow-cursors-recolored package from nixpkgs with
      color scheme settings. To install this package with color scheme set you
      will need to do something like that:
        stylix.cursor = nur.repos.nukdokplex.afterglow-cursors-recolored-custom.override {
          colorScheme = {
            main = "#8a80e0";
            stroke = "#1c1a2d";
            accent = "#c1bbfe";
            contextMenu = "#c1bbfe";
            loadingBackground = "#534d86";
            loadingForeground = "#8a80e0";
            notAllowed = "#8a80e0";
          };
        };
    '';
    homepage = "https://github.com/TeddyBearKilla/Afterglow-Cursors-Recolored";
    platforms = platforms.all;
    license = licenses.gpl3Plus;
    broken = true;
  };
}
