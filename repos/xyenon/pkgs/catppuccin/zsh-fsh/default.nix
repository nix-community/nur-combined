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
    description = "🐚 Soothing pastel theme for fast-syntax-highlighting";
    homepage = "https://github.com/catppuccin/zsh-fsh";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
