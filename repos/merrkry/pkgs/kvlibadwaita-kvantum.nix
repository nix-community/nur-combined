{
  fetchFromGitHub,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "kvlibadwaita-kvantum";
  version = "0-unstable-2025-09-13";

  src = fetchFromGitHub {
    owner = "GabePoel";
    repo = "KvLibadwaita";
    rev = "1f4e0bec44b13dabfa1fe4047aa8eeaccf2f3557";
    sha256 = "sha256-jCXME6mpqqWd7gWReT04a//2O83VQcOaqIIXa+Frntc=";
  };

  installPhase = ''
    mkdir -p $out/share/Kvantum
    cp -a src/KvLibadwaita $out/share/Kvantum
  '';

  meta = {
    description = "A libadwaita style theme for Kvantum, based on Colloid-kde";
    homepage = "https://github.com/GabePoel/KvLibadwaita";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ merrkry ];
    platforms = lib.platforms.linux;
  };
}
