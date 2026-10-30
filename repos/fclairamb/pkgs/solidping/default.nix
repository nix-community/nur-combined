{
  lib,
  stdenvNoCC,
  fetchurl,
  gzip,
}:

let
  version = "0.42.1";

  sources = {
    x86_64-linux = {
      name = "linux-amd64";
      hash = "sha256-vZMf2sFubXffgftH0OzGMIwUlr6DGjKdw1J+0NezbyM=";
    };
    aarch64-linux = {
      name = "linux-arm64";
      hash = "sha256-V1rF+Oximu93szS4Eb/ALmUExTONDz6vIV6l1fUjPAk=";
    };
    x86_64-darwin = {
      name = "darwin-amd64";
      hash = "sha256-4ToP4FNE2ajN9a9Q+VPI0E/MEzApgocSc7oOIBu5Qkw=";
    };
    aarch64-darwin = {
      name = "darwin-arm64";
      hash = "sha256-Honfk2GKWt71vVt9ihah8Jw2Ocg73vI0uSqsDedCtkA=";
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
