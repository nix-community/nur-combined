{
  lib,
  source,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname src date;
  version = "unstable-${finalAttrs.date}";

  dontConfigure = true;
  dontBuild = true;
  doCheck = false;

  installPhase = ''
    mkdir -p $out/share/firefox-theme
    cp -r theme configuration userChrome.css userContent.css $_
  '';

  meta = with lib; {
    description = "A GNOME theme for Firefox";
    homepage = "https://github.com/rafaelmardojai/firefox-gnome-theme";
    license = licenses.unlicense;
  };
})
