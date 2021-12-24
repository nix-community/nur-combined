{ lib, stdenvNoCC, fetchFromGitLab }:

stdenvNoCC.mkDerivation rec {
  pname = "monochrome-kde";
  version = "20210222";

  src = fetchFromGitLab {
    owner = "pwyde";
    repo = pname;
    rev = version;
    sha256 = "142p22jw7aj637x56ycarc09g711aq95p9csiw538wx2dq5lxha0";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp -a {aurorae,color-schemes,konsole,Kvantum,plasma,sddm,yakuake} $out/share
    runHook postInstall
  '';

  # Make this a fixed-output derivation
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash =
    "91d43b6d0d8e5a7dd2ea2057c74780c7f44e014fa85c2c295aa55f7f6da4c8ef";

  meta = with lib; {
    description = "A dark theme inspired by black and white photography.";
    longDescription = ''
      A dark theme for the KDE Plasma desktop environment inspired by black and white photography.
      The complete theme consists of the following components:
        Aurorae Theme
        Konsole Colour Scheme
        Kvantum Theme
        Plasma Colour Scheme
        Plasma Desktop Theme
        Plasma Look and Feel
        Plasma Splash Screen
        SDDM Theme
        Yakuake Skin
    '';
    homepage = "https://gitlab.com/pwyde/monochrome-kde";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
