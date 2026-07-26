{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  makeFontsConf,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "ModernX";
  version = "0.4.7";
  src = fetchFromGitHub {
    owner = "zydezu";
    repo = "ModernX";
    rev = finalAttrs.version;
    hash = "sha256-EekTzSC2Komh3H18IK1xr5bpQuAlulsc6CnmGb4aZ+A=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mpv/scripts
    cp modernx.lua $out/share/mpv/scripts/
    mkdir -p $out/share/fonts
    cp fluent-system-icons.ttf $out/share/fonts/

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

  meta = {
    description = "A modern OSC UI replacement for MPV that retains the functionality of the default OSC";
    homepage = "https://github.com/zydezu/ModernX";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ xyenon ];
  };
})
