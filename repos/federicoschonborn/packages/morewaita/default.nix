{ lib
, stdenv
, fetchFromGitHub
, gnome
, hicolor-icon-theme
, nix-update-script
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "morewaita";
  version = "45";

  src = fetchFromGitHub {
    owner = "somepaulo";
    repo = "MoreWaita";
    rev = "v${finalAttrs.version}";
    hash = "sha256-UtwigqJjkin53Wg3PU14Rde6V42eKhmP26a3fDpbJ4Y=";
  };

  propagatedBuildInputs = [
    gnome.adwaita-icon-theme
    hicolor-icon-theme
  ];

  installPhase = ''
    mkdir -p $out/share/icons/MoreWaita
    cp -r * $out/share/icons/MoreWaita
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "An Adwaita style extra icons theme for Gnome Shell";
    homepage = "https://github.com/somepaulo/MoreWaita";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
