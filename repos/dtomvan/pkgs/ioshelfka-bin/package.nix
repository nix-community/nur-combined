{
  lib,
  stdenvNoCC,
  fetchzip,
  variant ? "MonoNerd",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ioshelfka-bin";
  version = "0.1.3";

  src = fetchzip {
    url = "${finalAttrs.meta.homepage}/releases/download/v0.1.3/Ioshelfka${variant}.zip";
    hash =
      {
        # Mono and Term are redundant as the Nerd-variants contain both normal
        # _and_ nerd font
        Mono = "sha256-ujRn/vmLii7SEDepY/NY8GPNE3wX6z08FLvr/STcNCQ=";
        MonoNerd = "sha256-xKzxDvC67yQfvQl+U1hw2dLW1/MczPm3lMIlQMRdsxQ=";
        Term = "sha256-4lgchtKzv+P8ZSX4AGdc9pdGaUt4aU+mGm+QmwoJ4qE=";
        TermNerd = "sha256-002uoBL93A0sWyzxxFqeUbSOyDzuHeDddXEqfyYMTls=";
      }
      .${variant};
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r share $out

    runHook postInstall
  '';

  meta = {
    description = "Iosevka variant by notashelf";
    homepage = "https://github.com/NotAShelf/Ioshelfka";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
