{
  lib,
  stdenvNoCC,
  source,
}:

stdenvNoCC.mkDerivation {
  inherit (source) pname src;
  version = "0-unstable-${source.date}";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r "$src/themes" "$out"

    runHook postInstall
  '';

  meta = with lib; {
    description = "😽 Soothing pastel theme for Kitty";
    homepage = "https://github.com/catppuccin/kitty";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
