{ stdenv, lib, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "catppuccin-gtk";
  version = "update_23_02_2022";

  # the build script references the git source path and wasn't trivial to fix
  # so get the release and just unpack it

  # TODO: add other colors
  src = fetchurl {
    url = "https://github.com/catppuccin/gtk/releases/download/update_23_02_2022/Catppuccin-blue.zip";
    hash = "sha256-7bX6s3qetDW/6izfBIB9qFVn9anL4OCc1aPpki74rOA=";
  };

  nativeBuildInputs = [
    unzip
  ];

  dontBuild = true;

  installPhase = ''
    mkdir -p "$out/share/themes"
    cp -r "Catppuccin-blue-hdpi" \
          "Catppuccin-blue-xhdpi" \
          "Catppuccin-blue" \
          "$out/share/themes"
  '';

  unpackPhase = ''
    unzip $src
  '';

  meta = with lib; {
    description = "GTK theme for catppuccin. Warm dark theme for the masses!";
    homepage = "https://github.com/catppuccin/gtk";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
