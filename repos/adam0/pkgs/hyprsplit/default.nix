{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  # keep-sorted end
}:
stdenvNoCC.mkDerivation {
  pname = "hyprsplit";
  version = "0-unstable-2026-05-11";

  src = fetchFromGitHub {
    owner = "shezdy";
    repo = "hyprsplit";
    rev = "ea230fc65b4bd591451d2305140a2e3fbce894ca";
    hash = "sha256-VeVHk55Vg9+0BfUS+GleE7vZfa7ssb4yM+p+noJ349w=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 init.lua $out/init.lua
    install -Dm644 init.lua $out/hyprsplit/init.lua
    install -Dm644 init.lua $out/share/lua/5.4/hyprsplit/init.lua

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
