{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "pciids";
  version = "unstable-2025-07-11";

  src = fetchFromGitHub {
    owner = "pciutils";
    repo = "pciids";
    rev = "461b41990a0e4d4165e21a2f4ce91ba6ca7fea9d";
    hash = "sha256-WtbZrguZMOLx53ESU1eKJq6ZXdOq+J4Yn4VteyyB9KU=";
  };

  installPhase = ''
    install -Dm644 "$src/pci.ids" "$out/pci.ids"
  '';

  meta = {
    description = "The pci.ids file";
    homepage = "https://github.com/pciutils/pciids";
    license = with lib.licenses; [ gpl2Plus bsd3 ];
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    platforms = lib.platforms.all;
  };
}
