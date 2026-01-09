{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "layan-sddm-theme";
  version = "2025-02-13";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "Layan-kde";
    rev = version;
    hash = "sha256-T69bGjfZeOsJLmOZKps9N2wMv5VKYeo1ipGEsLAS+Sg=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/sddm/themes
    cp -a sddm/6.0/Layan $out/share/sddm/themes/Layan
    cp -a sddm/6.0/Layan-light $out/share/sddm/themes/Layan-light

    runHook postInstall
  '';

  meta = with lib; {
    description = "Layan SDDM themes for KDE Plasma (Qt6)";
    homepage = "https://github.com/vinceliuice/Layan-kde";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
