{
  lib,
  stdenv,
  fetchFromGitHub,
  gnome,
  hicolor-icon-theme,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "morewaita";
  version = "44";

  src = fetchFromGitHub {
    owner = "somepaulo";
    repo = "MoreWaita";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GZ7tXrn8Ii1EWp71Ln+D6HxyVRz+d+jt37N02h3q3QY=";
  };

  propagatedBuildInputs = [
    gnome.adwaita-icon-theme
    hicolor-icon-theme
  ];

  installPhase = ''
    mkdir -p $out/share/icons/MoreWaita
    cp -r * $out/share/icons/MoreWaita
  '';

  meta = with lib; {
    description = "An Adwaita style extra icons theme for Gnome Shell";
    homepage = "https://github.com/somepaulo/MoreWaita";
    license = licenses.gpl3Only;
  };
})
