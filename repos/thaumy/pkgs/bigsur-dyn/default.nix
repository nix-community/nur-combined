{ lib
, stdenv
, fetchFromGitHub
}:
let
  name = "bigsur-dyn";

  src = fetchFromGitHub {
    owner = "Thaumy";
    repo = "gnome-dyn-wallpapers";
    rev = "1f9ab3063967a675bf3b5f34dfa852dfc42663b2";
    hash = "sha256-wT+BPGFfZG8EUG5n4grIxRFFo9cqPj8qVA09RPKBRV4=";
  };
in
stdenv.mkDerivation {
  inherit name src;

  installPhase = ''
    declare inner_xml_root=$out/share/backgrounds/macOS/${name}
    declare name_xml_root=$out/share/gnome-background-properties
    mkdir -p $inner_xml_root
    mkdir -p $name_xml_root

    cp $src/${name}/inner.xml $inner_xml_root
    sed -i "s,ROOT,$src/${name},g" $inner_xml_root/inner.xml

    cp $src/${name}/${name}.xml $name_xml_root
    sed -i "s,ROOT,$inner_xml_root,g" $name_xml_root/${name}.xml
  '';

  meta = {
    description = "macOS bigsur dynamic wallpaper for GNOME";
    license = lib.licenses.mit;
    maintainers = [ "thaumy" ];
    platforms = lib.platforms.linux;
  };
}
