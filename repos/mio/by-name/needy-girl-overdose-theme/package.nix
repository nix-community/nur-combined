{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

let
  themeName = "NEEDY-GIRL-OVERDOSE";
in
stdenvNoCC.mkDerivation {
  pname = "needy-girl-overdose-theme";
  version = "0-unstable-2022-11-04";

  src = fetchFromGitHub {
    owner = "Natsuhane-Ayari";
    repo = "Needy_girl_overdose_theme";
    rev = "227babfdc288cbc805b9f2644a9d23ea030b80ad";
    hash = "sha256-S9uK4t4a8XhfLB69t3kUQuVrYx6AFvurSoOWzM5wN2Q=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/themes/${themeName}"
    cp -a \
      assets \
      gtk-3.0 \
      gtk-3.20 \
      images \
      index.theme \
      xfce-notify-4.0 \
      xfwm4 \
      "$out/share/themes/${themeName}/"
    runHook postInstall
  '';

  meta = {
    description = "Needy Girl Overdose GTK/Xfwm4 theme";
    homepage = "https://github.com/Natsuhane-Ayari/Needy_girl_overdose_theme";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
}
