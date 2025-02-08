{
  source,
  lib,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;

  nativeBuildInputs = [ unzip ];

  preferLocalBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applicatoins/Hammerspoon
    cp -r . $out/Applicatoins/Hammerspoon

    runHook postInstall
  '';

  meta = {
    description = "Staggeringly powerful macOS desktop automation with Lua";
    homepage = "https://github.com/Hammerspoon/hammerspoon";
    changelog = "https://github.com/Hammerspoon/hammerspoon/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
