{
  lib,
  stdenvNoCC,
  fetchurl,
  gzip,
}:
let
  versions = lib.importJSON ./versions.json;
  inherit (versions) version;
  assets = builtins.removeAttrs versions [ "version" ];
  asset = assets.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "mihomo-oix";
  inherit version;

  # Pre-Alpha is a rolling release; pin both the revisioned filename and hash.
  src = fetchurl {
    url = "https://github.com/vernesong/mihomo-oix/releases/download/Pre-Alpha/${asset.name}-${version}.gz";
    inherit (asset) hash;
  };

  nativeBuildInputs = [ gzip ];
  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    gzip -dc "$src" > "$out/bin/mihomo"
    chmod +x "$out/bin/mihomo"
    runHook postInstall
  '';

  doInstallCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/mihomo" -v | grep -F '${version}'
    runHook postInstallCheck
  '';

  meta = {
    description = "Mihomo with Smart Groups (amd64-v3 on x86_64)";
    homepage = "https://github.com/vernesong/mihomo-oix";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "mihomo";
    platforms = builtins.attrNames assets;
  };
}
