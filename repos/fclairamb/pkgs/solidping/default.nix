{
  lib,
  stdenvNoCC,
  fetchurl,
  gzip,
}:

let
  version = "0.40.0";

  sources = {
    x86_64-linux = {
      name = "linux-amd64";
      hash = "sha256-I7LvxxDGE87u7P95G6i0ldr2nHAyzTRxGEsR1DVej78=";
    };
    aarch64-linux = {
      name = "linux-arm64";
      hash = "sha256-h6mvUNoGaJD1wFQC8vRAoBcLLpcowp6/0gshMdhPW44=";
    };
    x86_64-darwin = {
      name = "darwin-amd64";
      hash = "sha256-Qf6qEgJwdlx+6VLi8vAbGiDtf8rX7zCAPxq7/+GpIms=";
    };
    aarch64-darwin = {
      name = "darwin-arm64";
      hash = "sha256-weo1lA9GV3dIqD0FjP+eETJbMgOv7cZ9BW9rrCELxtk=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "solidping: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "solidping";
  inherit version;

  src = fetchurl {
    url = "https://github.com/fclairamb/solidping/releases/download/v${version}/solidping-${source.name}.gz";
    inherit (source) hash;
  };

  nativeBuildInputs = [ gzip ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # Prebuilt, statically linked Go binary.
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    gzip -dc $src > $out/bin/solidping
    chmod 755 $out/bin/solidping
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/solidping --help > help.txt
    grep "SolidPing monitoring service" help.txt
    runHook postInstallCheck
  '';

  meta = {
    description = "Self-hosted uptime and synthetic monitoring with status pages, incidents and alerting";
    homepage = "https://www.solidping.io";
    downloadPage = "https://github.com/fclairamb/solidping/releases";
    changelog = "https://github.com/fclairamb/solidping/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = "solidping";
  };
}
