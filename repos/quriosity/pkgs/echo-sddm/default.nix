{ lib, stdenvNoCC, fetchFromGitHub, enableWallpaper ? false, wallpaper ? null}:

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

    ${lib.optionalString enableWallpaper ''
      substituteInPlace $out/share/sddm/themes/echo/theme.conf \
        --replace-fail "type=pure" "type=frosted"
    ''}
    ${lib.optionalString (wallpaper != null) ''
      cp ${wallpaper} $out/share/sddm/themes/echo/assets/backgrounds/background.png
    ''}
    runHook postInstall
  '';

  meta = with lib; {
    description = "macOS Terminal-inspired SDDM theme";
    homepage = "https://github.com/xCaptaiN09/echo-sddm";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
