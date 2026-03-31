{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  resolution ? "1920x1080",
}:

let
  rev = "4d9cd37baf56c4f5510cc4ff61be278f11077c81";
  version = "0-unstable-${builtins.substring 0 7 rev}";
  supportedResolutions = [
    "1920x1080"
    "2256x1504"
    "2560x1440"
    "3840x2160"
  ];
in
assert builtins.elem resolution supportedResolutions;
stdenvNoCC.mkDerivation {
  pname = "grub-theme-yorha";
  inherit version;

  src = fetchFromGitHub {
    owner = "OliveThePuffin";
    repo = "yorha-grub-theme";
    inherit rev;
    hash = "sha256-XVzYDwJM7Q9DvdF4ZOqayjiYpasUeMhAWWcXtnhJ0WQ=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r "$src/yorha-${resolution}"/* "$out/"
    runHook postInstall
  '';

  meta = with lib; {
    description = "YoRHa GRUB theme packaged as a pure asset copy with selectable resolution";
    homepage = "https://github.com/OliveThePuffin/yorha-grub-theme";
    platforms = platforms.linux;
    license = licenses.unlicense;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
