{ lib
, stdenvNoCC
, fetchFromGitHub
, gtk3
, gnome-themes-extra
, gtk-engine-murrine
, sassc
, accentColor ? "default"
}:

stdenvNoCC.mkDerivation rec {
  pname = "orchis";
  version = "2022-01-15";

  src = fetchFromGitHub {
    repo = "Fluent-gtk-theme";
    owner = "vinceliuice";
    rev = version;
    sha256 = "sha256-vi7HS9tsCqSvIeZDLSTLj21Rj7/XpmVN1TDEtHjvYNk=";
  };

  nativeBuildInputs = [ gtk3 sassc ];

  buildInputs = [ gnome-themes-extra ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  preInstall = ''
    mkdir -p $out/share/themes
  '';

  installPhase = ''
    runHook preInstall
    bash install.sh -d $out/share/themes -t ${accentColor}
    runHook postInstall
  '';

  meta = with lib; {
    description = "A Material Design theme for GNOME/GTK based desktop environments.";
    homepage = "https://github.com/vinceliuice/Fluent-gtk-theme";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
