{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  # keep-sorted end
}:
stdenvNoCC.mkDerivation {
  pname = "hyprsplit";
  version = "0-unstable-2026-05-21";

  src = fetchFromGitHub {
    owner = "shezdy";
    repo = "hyprsplit";
    rev = "210158372ddd3f981471c8eae679a32caaf90c1a";
    hash = "sha256-Mqp4df5J+7+zBepqT+XBprIri/J2d+3ZNh+GX5P0FGU=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 init.lua $out/init.lua

    runHook postInstall
  '';

  # keep-sorted start
  dontBuild = true;
  dontConfigure = true;
  # keep-sorted end

  meta = {
    # keep-sorted start
    description = "Hyprland Lua library for separate workspace sets on each monitor";
    homepage = "https://github.com/shezdy/hyprsplit";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    # keep-sorted end
  };
}
