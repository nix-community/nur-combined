{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
# TODO: use buildLua
# error: evaluation aborted with the following error message: 'lib.customisation.callPackageWith: Function called without required argument "buildLua"
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "modernx";
  version = "0.2.7.6";

  # zydezu's fork
  src = fetchFromGitHub {
    owner = "zydezu";
    repo = "ModernX";
    rev = finalAttrs.version;
    hash = "sha256-WWwnxhFMDjlQb0+5+hD9CRe/BYt4CWHw3JGZOI3IQiE=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -Dm644 modernx.lua $out/share/mpv/scripts/modernx.lua

    # I dont know how to handle the font...
    install -Dm644 Material-Design-Iconic-Font.ttf $out/share/mpv/fonts/Material-Design-Iconic-Font.ttf
    install -Dm644 Material-Design-Iconic-Round.ttf $out/share/mpv/fonts/Material-Design-Iconic-Round.ttf
  '';

  passthru.scriptName = "modernx.lua";
  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "A modern OSC UI replacement for MPV that retains the functionality of the default OSC. (@zydezu's fork)";
    homepage = "https://github.com/zydezu/ModernX/";
    license = licenses.gpl2; # https://github.com/maoiscat/mpv-osc-modern/issues/43
    platforms = platforms.all;
  };
})
