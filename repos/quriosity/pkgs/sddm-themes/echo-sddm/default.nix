{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "echo-sddm";
  version = "e004121";

  src = fetchFromGitHub {
    owner = "xCaptaiN09";
    repo = "echo-sddm";
    rev = "e004121450ff71050d3d76a998b86eafdbb6bf47";
    hash = "sha256-J8JCTkbQhhxJam3GmmHLAt8sRqGqLUsBdkehUjvJZbs=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/sddm/themes/echo
    cp -r Main.qml metadata.desktop theme.conf assets \
      $out/share/sddm/themes/echo/

    substituteInPlace $out/share/sddm/themes/echo/Main.qml \
      --replace-fail 'property string realDistro: "Arch Linux"' \
        'property string realDistro: config.distro || "Arch Linux"' \
      --replace-fail 'if (dm) realDistro = dm[1]' \
        'if (dm && !config.distro) realDistro = dm[1]'

    runHook postInstall
  '';

  meta = with lib; {
    description = "macOS Terminal-inspired SDDM theme";
    homepage = "https://github.com/xCaptaiN09/echo-sddm";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}