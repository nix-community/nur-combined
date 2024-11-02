{
  lib,
  sources,
  stdenvNoCC,
  lyrica,
}:
stdenvNoCC.mkDerivation {
  inherit (sources.lyrica) pname version src;

  postInstall = ''
    mkdir -p $out/share/plasma/plasmoids/ink.chyk.LyricaPlasmoid
    cp -r plasmoid/* $out/share/plasma/plasmoids/ink.chyk.LyricaPlasmoid

    substituteInPlace $out/share/plasma/plasmoids/ink.chyk.LyricaPlasmoid/contents/ui/main.qml \
      --replace-fail '$HOME/.local/share/plasma/plasmoids/ink.chyk.LyricaPlasmoid/contents/bin/lyrica' '${lyrica}/bin/lyrica'
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Linux desktop lyrics widget focused on simplicity and integration (Plasmoid component)";
    homepage = "https://github.com/chiyuki0325/lyrica";
    # Upsteam did not specify license
    license = lib.licenses.unfreeRedistributable;
  };
}
