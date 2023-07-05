{ lib, fetchzip, stdenv, makeWrapper, makeDesktopItem, fetchurl }:

stdenv.mkDerivation rec {
  pname = "maltego";
  version = "4.4.1";

  src = fetchzip {
    url = "https://downloads.maltego.com/maltego-v4/linux/Maltego.v${version}.linux.zip";
    name = "Maltego.v${version}.linux.zip";
    hash = "sha256-r8RTpSs9rHgFrkgWcg9F8og2fiVMdq8ra8hmpJXlOOY=";
  };

  icon = fetchurl {
      url = "https://static.maltego.com/cdn/Maltego%20Branding/Maltego%20logo%20-%20compact/Maltego-Logo-Compact-Black.png";
      hash = "sha256-2dgnvU/2Ur9plGBwZjrj6RO4bavnsfU8FW3wGbuGlII=";
    };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin $out/share/${pname} $out/share/applications $out/share/icons/hicolor/128x128/apps

    cp -r * $out/share/${pname}

    cp ${icon} $out/share/icons/hicolor/128x128/apps/maltego.png

    ln -s "${desktopItem}/share/applications" "$out/share/applications"

    makeWrapper $out/share/${pname}/bin/maltego $out/bin/maltego

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    name = "Maltego";
    exec = "${pname}";
    icon = "maltego";
    desktopName = "Maltego";
    genericName = "Maltego";
    comment = meta.description;
    categories = [ "Security" "System" ];
  };

  meta = with lib; {
    description = "An open source intelligence and forensics application, enabling to easily gather information about DNS, domains, IP addresses, websites, persons, etc.";
    homepage = "https://www.maltego.com/";
    mainProgram = "maltego";
    license = licenses.unfree;
    platforms = platforms.unix;
  };
}
