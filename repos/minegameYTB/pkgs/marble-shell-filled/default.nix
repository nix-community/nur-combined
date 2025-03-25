{ stdenvNoCC, lib, fetchurl }:

let
  baseName = "Marble-shell";
  themeName = "${baseName}-filled";
in

stdenvNoCC.mkDerivation rec {
  pname = themeName;
  version = "48.0.1";
  src = fetchurl {
    url = "https://github.com/imarkoff/${baseName}-theme/releases/download/${version}/${pname}.tar.xz";
    hash = "sha256-+2WYApmfXxRa1ezp2vzHHr1P+uhe1XbgML7xVytU5bo=";
  };
  
  sourceRoot = ".";
  
  installPhase = ''
    mkdir -p $out/share/themes
    
    # Add "filled" suffix to all Marble directories
    for dir in Marble*; do
      if [[ "$dir" != *-filled ]]; then
        cp -r "$dir" "$out/share/themes/''${dir}-filled"
      else
        cp -r "$dir" "$out/share/themes/"
      fi
    done
  '';
  
  meta = with lib; {
    description = "Shell theme for GNOME DE (filled variant)";
    homepage = "https://github.com/imarkoff/Marble-shell-theme";
    license = licenses.gpl3;
  };
}
