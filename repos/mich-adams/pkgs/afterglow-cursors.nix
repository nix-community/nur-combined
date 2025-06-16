{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  xcursorgen,
  inkscape,
  colors ? {
    base = "3c3836"; # black
    main = "d79921"; # yellow
    main-bright = "fabd2f"; # bright yellow
  },
  ...
}:
stdenvNoCC.mkDerivation {
  name = "afterglow-cursors";
  version = "0-unstable-2023-10-04";

  src = fetchFromGitHub {
    owner = "TeddyBearKilla";
    repo = "Afterglow-Cursors-Recolored";
    rev = "940a5d30e52f8c827fa249d2bbcc4af889534888";
    hash = "sha256-GR+d+jrbeIGpqal5krx83PxuQto2PQTO3unQ+jaJf6s=";
  };
  buildInputs = [
    xcursorgen
    inkscape
  ];

  buildPhase = ''
    export HOME=$(pwd)
    unset DISPLAY
      SRC=$PWD/src
      cd "$SRC"
      cp -r svg custom
      cd "$SRC"/custom && sed -i "s/#111111/#${colors.main}/g" `ls` && sed -i "s/#222222/#${colors.base}/g" `ls` && sed -i "s/#333333/#${colors.main-bright}/g" `ls` && sed -i "s/#444444/#${colors.main}/g" `ls` && sed -i "s/#555555/#${colors.base}/g" `ls` && sed -i "s/#666666/#${colors.main}/g" `ls` && sed -i "s/#777777/#${colors.main}/g" `ls`
      THEME="Afterglow Custom"
      BUILD="$SRC/custom"

    # Create function from buildall.sh
    cd "$SRC"; mkdir -p x1 x1_25 x1_5 x2; cd "$SRC"/custom
    	find . -name "*.svg" -type f -exec sh -c 'inkscape -o "../x1/''${0%.svg}.png" -w 32 -h 32 $0' {} \;
    	find . -name "*.svg" -type f -exec sh -c 'inkscape -o "../x1_25/''${0%.svg}.png" -w 40 -w 40 $0' {} \;
    	find . -name "*.svg" -type f -exec sh -c 'inkscape -o "../x1_5/''${0%.svg}.png" -w 48 -w 48 $0' {} \;
    	find . -name "*.svg" -type f -exec sh -c 'inkscape -o "../x2/''${0%.svg}.png" -w 64 -w 64 $0' {} \;
    	cd "$SRC"; OUTPUT="$BUILD"/cursors ALIASES="$SRC"/cursorList

    	if [ ! -d "$BUILD" ]; then mkdir "$BUILD"; fi
    	if [ ! -d "$OUTPUT" ]; then mkdir "$OUTPUT"; fi

    	echo -ne "Generating cursor theme...\\r"
    	for CUR in config/*.cursor; do
    		BASENAME="$CUR"
    		BASENAME="''${BASENAME##*/}"
    		BASENAME="''${BASENAME%.*}"
    		xcursorgen "$CUR" "$OUTPUT/$BASENAME"; done
    	echo -e "Generating cursor theme... DONE"

    	cd "$OUTPUT"	#generate aliases

    	echo -ne "Generating shortcuts...\\r"
    	while read ALIAS; do
    	FROM="''${ALIAS#* }"
    	TO="''${ALIAS% *}"

    		if [ -e $TO ]; then
    		continue; fi
    		ln -sr "$FROM" "$TO"; done < "$ALIASES"
    	echo -e "Generating shortcuts... DONE"

    	cd "$PWD"

    	echo -ne "Generating Theme Index...\\r"
    	INDEX="$OUTPUT/../index.theme"
    	if [ ! -e "$OUTPUT/../$INDEX" ]; then
    	touch "$INDEX"
    		echo -e "[Icon Theme]\nName=$THEME\nComment=$THEME Cursor pack.\n" > "$INDEX"; fi
    	echo -e "Generating Theme Index... DONE"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/icons"
    cp -r "$SRC/custom" "$out/share/icons/Afterglow-Custom"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Recoloring of the Afterglow Cursors x-cursor theme";
    homepage = "https://github.com/TeddyBearKilla/Afterglow-Cursors-Recolored";
    platforms = platforms.all;
    license = licenses.gpl3Plus;
  };
}
