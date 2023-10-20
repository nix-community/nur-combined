{ lib, stdenvNoCC, fetchFromGitHub, makeFontsConf }:

stdenvNoCC.mkDerivation (finalAttrs: rec {
  pname = "ModernX";
  version = "unstable-2023-01-12";

  src = fetchFromGitHub {
    owner = "cyl0";
    repo = pname;
    rev = "d053ea602d797bdd85d8b2275d7f606be067dc21";
    hash = "sha256-Gpofl529VbmdN7eOThDAsNfNXNkUDDF82Rd+csXGOQg=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mpv/scripts
    cp modernx.lua $out/share/mpv/scripts/
    mkdir -p $out/share/fonts
    cp Material-Design-Iconic-Font.ttf $out/share/fonts/

    runHook postInstall
  '';

  passthru.scriptName = "modernx.lua";
  passthru.extraWrapperArgs = [
    "--set"
    "FONTCONFIG_FILE"
    (toString (makeFontsConf {
      fontDirectories = [ "${finalAttrs.finalPackage}/share/fonts" ];
    }))
  ];

  meta = with lib; {
    description = "A modern OSC UI replacement for MPV that retains the functionality of the default OSC";
    homepage = "https://github.com/cyl0/ModernX";
    license = licenses.unlicense;
    maintainers = with maintainers; [ xyenon ];
  };
})
