{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  # keep-sorted end
}:
stdenvNoCC.mkDerivation {
  pname = "hyprsplit";
  version = "0.54.3-unstable-2026-06-06";

  src = fetchFromGitHub {
    owner = "shezdy";
    repo = "hyprsplit";
    rev = "8f0627b3f0380ce730d8d89f25680f4f601ecd33";
    hash = "sha256-n7jG8wF0lhiky3/jJr8lCFyUtqZEInYA0J0K9W6Bq3I=";
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
