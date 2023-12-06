{lib, stdenv, fetchurl, jre, gsettings-desktop-schemas, wrapGAppsHook, glib }:

stdenv.mkDerivation rec {
  pname = "mcaselector";
  version = "1.17.1";

  src = fetchurl {
    url = "https://github.com/Querz/mcaselector/releases/download/${version}/mcaselector-${version}.jar";
    sha256 = "0nrr21hj05ng1w02aygkh8a2s85gypxyjmc1bikp3farlgcjc5l3";
  };

  dontUnpack = true;

  nativeBuildInputs = [ wrapGAppsHook glib ];
#  buildInputs = [ gsettings-desktop-schemas ];

  dontWrapGApps = true;  

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java $out/bin
    cp $src $out/share/java/mcaselector-${version}.jar

    echo "''${gappsWrapperArgs[@]}"

    makeWrapper ${jre}/bin/java $out/bin/mcaselector \
      --add-flags "-jar $out/share/java/mcaselector-${version}.jar" \
      --set _JAVA_OPTIONS '-Dawt.useSystemAAFontSettings=on' \
      --set _JAVA_AWT_WM_NONREPARENTING 1 \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      "''${gappsWrapperArgs[@]}"

    runHook postInstall
  '';

}
