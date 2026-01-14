# NOTE: This is untested
{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "redream-dev";
  version = "1.5.0-1133-g03c2ae9";

  src = fetchurl {
    url = "https://redream.io/download/redream.universal-mac-v${version}.tar.gz";
    hash = "sha256-iXKvOE+CUSWqRIGdxWr8SI9yy1FCrqj3gTtAZVQifMo=";
  };

  nativeBuildInputs = [unzip];

  sourceRoot = ".";

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    app=$(find . -maxdepth 2 -name "*.app" -type d | head -n1)
    cp -R "$app" $out/Applications/
    runHook postInstall
  '';

  meta = {
    description = "Dreamcast emulator";
    homepage = "https://redream.io";
    maintainers = ["Prinky"];
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}
