{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gnome-themes-extra,
  gtk-engine-murrine,
}:
stdenvNoCC.mkDerivation rec {
  pname = "mono-gtk-theme";
  version = "unstable-2024-07-14";

  src = fetchFromGitHub {
    owner = "witalihirsch";
    repo = "Mono-gtk-theme";
    rev = "89fa83a14b4e26c5b8fc4dbfa5558a7df704d5a4";
    hash = "sha256-NaZgOOo5VVTlEand3qWryZ5ceNmyHaEt0aeT7j/KwvE=";
  };

  dontBuild = true;

  buildInputs = [ gnome-themes-extra ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes
    cp -a MonoTheme* $out/share/themes
    runHook postInstall
  '';

  meta = with lib; {
    description = " Mono Theme for Gnome ";
    homepage = "https://github.com/witalihirsch/Mono-gtk-theme";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ jk ];
  };
}
