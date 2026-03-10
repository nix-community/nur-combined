{
  lib,
  stdenvNoCC,
  sources,
  source ? sources.superpowers-skills,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname src;
  version = source.date;

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share
    cp -r skills $out/share/superpowers
  '';

  meta = {
    homepage = "https://github.com/obra/superpowers";
    description = "Agentic skills framework & software development methodology that works";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.all;
  };
})
