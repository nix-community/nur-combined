{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "echo-sddm";
  version = "7fbce9a";

  src = fetchFromGitHub {
    owner = "xCaptaiN09";
    repo = "echo-sddm";
    rev = "7fbce9a3fb1aaed05bda7f522c4949658422c5c7";
    hash = "sha256-7Us7dzaGc/x1Vf8XFfHEMjB+xzhmMd4U5rtJJLI8e18=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/sddm/themes/echo
    cp -r Main.qml metadata.desktop theme.conf install.sh assets \
      $out/share/sddm/themes/echo/
      echo "QtVersion=6" >> $out/share/sddm/themes/echo/metadata.desktop
    runHook postInstall
  '';

  meta = with lib; {
    description = "macOS Terminal-inspired SDDM theme";
    homepage = "https://github.com/xCaptaiN09/echo-sddm";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
