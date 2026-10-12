{ stdenvNoCC, fetchzip, gtk3, lib }:

let
  version = "0.1-alpha.bloom";
in

stdenvNoCC.mkDerivation {
  pname = "tulasi";
  inherit version;

  src = fetchzip {
    url = "https://github.com/ShringarStudio/Tulasi/releases/download/v${version}/Tulasi.v${version}.tar.xz";
    hash = "sha256-7xIEiD0+1DMeYHj3I0uFrJe7LN7S8tSlLqDKEa4u4Fw=";
  };

  nativeBuildInputs = [ gtk3 ];

  installPhase = ''
    mkdir -p $out/share/icons/Tulasi
    cp -r * $out/share/icons/Tulasi/
  '';

  dontDropIconThemeCache = true;

  postFixup = ''
    gtk-update-icon-cache $out/share/icons/Tulasi
  '';

  meta = with lib; {
    description = "A pixel art icon pack for Linux, by Shringar Studio";
    homepage = "https://github.com/shringarstudio/tulasi";
    license = licenses.cc-by-nc-sa-40;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
