{ lib, stdenvNoCC, fetchFromGitHub, sassc }:

stdenvNoCC.mkDerivation {
  pname = "darkly-gtk";
  version = "3de7ec4";

  src = fetchFromGitHub {
    owner = "wrymt";
    repo = "darkly-gtk";
    rev = "3de7ec457dd3855e32a9760910f4f4430679eb98";
    hash = "sha256-E+1WcheJjTprzLRQGNcn0j8IJfmMgtudkzBCvuTz/Zg=";
  };

  nativeBuildInputs = [ sassc ];

  buildPhase = ''
    runHook preBuild
    mkdir -p build
    (
      cd sass
      touch _darkly_user_settings.scss
      sassc -t compact gtk3-light.scss ../build/gtk3-light.css
      sassc -t compact gtk3-dark.scss ../build/gtk3-dark.css
      sassc -t compact gtk4.scss ../build/gtk4.css
    )
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    themeDir="$out/share/themes/Darkly"
    mkdir -p "$themeDir"/{assets,gtk-3.0,gtk-4.0}
    cp -r assets/. "$themeDir/assets/"
    install -m 644 build/gtk3-light.css "$themeDir/gtk-3.0/gtk.css"
    install -m 644 build/gtk3-dark.css "$themeDir/gtk-3.0/gtk-dark.css"
    install -m 644 build/gtk4.css "$themeDir/gtk-4.0/gtk.css"
    ln -s ../assets "$themeDir/gtk-3.0/darkly-gtk-assets"
    ln -s ../assets "$themeDir/gtk-4.0/darkly-gtk-assets"
    ln -s gtk.css "$themeDir/gtk-4.0/gtk-dark.css"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A GTK theme matching the Darkly Qt style";
    homepage = "https://github.com/wrymt/darkly-gtk";
    license = licenses.lgpl21Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = platforms.linux;
  };
}