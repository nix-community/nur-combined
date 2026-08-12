{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  # keep-sorted end
}:
stdenvNoCC.mkDerivation {
  pname = "hyprsplit";
  version = "0.54.3-unstable-2026-06-11";

  src = fetchFromGitHub {
    owner = "shezdy";
    repo = "hyprsplit";
    rev = "6b00b677d8905fb38779c91e12d6294e0e586a44";
    hash = "sha256-PaoUtmk+qIP/ESdxkxnY7mUMpMHjix88qu22R5GLQqE=";
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
