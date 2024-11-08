# Base adwaita-icon-theme
# 2 Name: Fluent-cursors, Fluent-cursors-dark

{ lib
, stdenv
, fetchFromGitHub
, gtk3
, nix-update-script
, pkg-config
, gdk-pixbuf
, librsvg
, hicolor-icon-theme
}:


stdenv.mkDerivation rec{
  pname = "fluent-cursors-theme";
  version = "2024-02-25";
  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "Fluent-icon-theme";
    rev = version;
    hash = "sha256-Cadp2+4kBZ74kdD5x0O85FszxvN6/sg6yccxughyX1Q=";
  };

  dontBuild = true;
  nativeBuildInputs = [
    pkg-config
    gtk3
  ];
  buildInputs = [
    gdk-pixbuf
    librsvg
  ];

  propagatedBuildInputs = [
    # For convenience, we can specify adwaita-icon-theme only in packages
    hicolor-icon-theme
  ];
  dontDropIconThemeCache = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r cursors/dist $out/share/icons/Fluent-cursors
    cp -r cursors/dist $out/share/icons/Fluent-cursors-dark
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = with lib; {
    description = "Fluent cursors theme for linux desktops";
    homepage = "https://github.com/vinceliuice/Fluent-icon-theme";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
