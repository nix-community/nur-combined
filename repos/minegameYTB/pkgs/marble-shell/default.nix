{ stdenvNoCC, lib, fetchurl, variant ? "" }:
let
  # Définition des métadonnées par variante
  themeType = if variant == "filled" then {
    suffix = "-filled";
    hash = "sha256-+2WYApmfXxRa1ezp2vzHHr1P+uhe1XbgML7xVytU5bo=";
  } else {
    suffix = "";
    hash = "sha256-I8lxpljtXXZ6NpM3ZdVUYnvdYcjhG4/juYYvnqMkvrg=";
  };
  baseName = "Marble-shell";
  themeName = baseName + themeType.suffix;
  version = "47.0";
in
stdenvNoCC.mkDerivation rec {
  pname = baseName;
  inherit version;
  src = fetchurl {
    url = "https://github.com/imarkoff/${baseName}-theme/releases/download/${version}/${themeName}.tar.xz";
    hash = themeType.hash;
  };
  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out/share/themes
    
    # Gestion conditionnelle des noms de dossiers selon la variante
    if [ "${variant}" = "filled" ]; then
      # Variante filled: ajouter le suffixe -filled aux dossiers qui ne l'ont pas déjà
      for dir in Marble-*; do
        if [[ "$dir" != *-filled ]]; then
          cp -r "$dir" "$out/share/themes/''${dir}-filled"
        else
          cp -r "$dir" "$out/share/themes/"
        fi
      done
    else
      # Variante standard: s'assurer qu'aucun dossier n'a le suffixe -filled
      for dir in Marble-*; do
        if [[ "$dir" == *-filled ]]; then
          # Si par hasard un dossier a le suffixe -filled, on le retire
          newName=$(echo "$dir" | sed 's/-filled$//')
          cp -r "$dir" "$out/share/themes/$newName"
        else
          # Sinon, on copie normalement
          cp -r "$dir" "$out/share/themes/"
        fi
      done
    fi
  '';
  meta = with lib; {
    description = "Shell theme for GNOME DE" + (if variant == "filled" then " (filled variant)" else "");
    homepage = "https://github.com/imarkoff/Marble-shell-theme";
    license = licenses.gpl3;
  };
}
