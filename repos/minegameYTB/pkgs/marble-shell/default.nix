{ stdenvNoCC, lib, fetchurl, variant ? "" }:
let
  ### Definition of metadata by variant
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
  pname = themeName;
  inherit version;
  src = fetchurl {
    url = "https://github.com/imarkoff/${baseName}-theme/releases/download/${version}/${themeName}.tar.xz";
    hash = themeType.hash;
  };
  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out/share/themes
    ### Conditional handling of folder names based on variant
    if [ "${variant}" = "filled" ]; then
      ### Filled variant: add -filled suffix to directories that don't already have it
      for dir in Marble-*; do
        if [[ "$dir" != *-filled ]]; then
          cp -r "$dir" "$out/share/themes/''${dir}-filled"
        else
          cp -r "$dir" "$out/share/themes/"
        fi
      done
    else
      ### Standard variant: ensure no directory has the -filled suffix
      for dir in Marble-*; do
        if [[ "$dir" == *-filled ]]; then
          ### If by chance a directory has the -filled suffix, remove it
          newName=$(echo "$dir" | sed 's/-filled$//')
          cp -r "$dir" "$out/share/themes/$newName"
        else
          ### Otherwise, copy normally
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
