{
  fetchFromGitHub,
  hyprland,
  lib,
  mkHyprlandPlugin,
}:
mkHyprlandPlugin rec {
  pluginName = "hypr-kinetic-scroll";
  version =
    if lib.versionAtLeast hyprland.version "0.54.0"
    then "0.3.0"
    else "0.3.0-hyprland-0.53.3";
  hash =
    if version == "0.3.0"
    then "sha256-M4WoDRz8VzpS1+akcwWywyA8XYM6gzGSOx/BZRrSfLg="
    else "sha256-lfO3GlZ6Pz3iRYYAwqV1ybn5U6WWQ0kiMFfe3dvk2ZQ=";

  src = fetchFromGitHub {
    owner = "savonovv";
    repo = pluginName;
    tag = "v${version}";
    inherit hash;
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
