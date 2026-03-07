{
  fetchFromGitHub,
  lib,
  mkHyprlandPlugin,
}:
mkHyprlandPlugin rec {
  pluginName = "hypr-kinetic-scroll";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "savonovv";
    repo = pluginName;
    tag = "v${version}";
    hash = "sha256-M4WoDRz8VzpS1+akcwWywyA8XYM6gzGSOx/BZRrSfLg=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 ${pluginName}.so $out/lib/lib${pluginName}.so
    runHook postInstall
  '';

  meta = {
    description = "Inertial scrolling for Hyprland on touchpads";
    homepage = "https://github.com/savonovv/hypr-kinetic-scroll";
    license = lib.licenses.mit;
    mainProgram = null;
  };
}
