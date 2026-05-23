{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  # keep-sorted end
}:
stdenvNoCC.mkDerivation {
  pname = "hyprsplit";
  version = "0-unstable-2026-05-22";

  src = fetchFromGitHub {
    owner = "shezdy";
    repo = "hyprsplit";
    rev = "0fc01e7930625ecb3e069f5dc8e1d61eab929f3b";
    hash = "sha256-XpwuFhwnfwPbzImZeUWWns///UEpoKNkpl1hN90C3Ag=";
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
