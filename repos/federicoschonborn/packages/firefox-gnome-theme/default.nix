{ lib
, stdenvNoCC
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "firefox-gnome-theme";
  version = "114";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "firefox-gnome-theme";
    rev = "v${finalAttrs.version}";
    hash = "sha256-o53fws/jwhLfxiYfTyYpKSGi61d5LHzGgSCkt3DNGRI=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    cp -r $src/* $out/

    runHook postInstall
  '';

  meta = with lib; {
    description = "A GNOME theme for Firefox";
    homepage = "https://github.com/rafaelmardojai/firefox-gnome-theme";
    license = licenses.unlicense;
    maintainers = with maintainers; [ federicoschonborn ];
  };
})
