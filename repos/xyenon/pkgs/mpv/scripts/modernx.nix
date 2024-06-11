{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  makeFontsConf,
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
  pname = "ModernX";
  version = "0.3.5.5";

  src = fetchFromGitHub {
    owner = "zydezu";
    repo = pname;
    rev = version;
    hash = "sha256-sPpVwI8w5JsP/jML0viOSqhyYBVKfxWuKbxHkX3GVug=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mpv/scripts
    cp modernx.lua $out/share/mpv/scripts/
    mkdir -p $out/share/fonts
    cp Material-Design-Iconic-Font.ttf $out/share/fonts/
    cp Material-Design-Iconic-Round.ttf $out/share/fonts/

    runHook postInstall
  '';

  passthru = {
    scriptName = "modernx.lua";
    extraWrapperArgs = [
      "--set"
      "FONTCONFIG_FILE"
      (toString (makeFontsConf {
        fontDirectories = [ "${finalAttrs.finalPackage}/share/fonts" ];
      }))
    ];
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "A modern OSC UI replacement for MPV that retains the functionality of the default OSC";
    homepage = "https://github.com/zydezu/ModernX";
    license = licenses.unlicense;
    maintainers = with maintainers; [ xyenon ];
  };
})
