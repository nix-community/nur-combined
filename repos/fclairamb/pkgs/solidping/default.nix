{
  lib,
  stdenvNoCC,
  fetchurl,
  gzip,
}:

let
  version = "0.41.0";

  sources = {
    x86_64-linux = {
      name = "linux-amd64";
      hash = "sha256-yad/RWYi2qm2VzKECWdyg0XN8yWaAgCdk0lES4h+FAg=";
    };
    aarch64-linux = {
      name = "linux-arm64";
      hash = "sha256-hqE+Mp7Z8aoVHyBsj61GCIMEE6EGbKub1T2eXIZe3Ao=";
    };
    x86_64-darwin = {
      name = "darwin-amd64";
      hash = "sha256-UrvMYxZxwUNf9+BUnvlepioL5+20DY7eIvspNm93X98=";
    };
    aarch64-darwin = {
      name = "darwin-arm64";
      hash = "sha256-hZKB1TpOo1iwxYvShJbLQI73KalCIP4o9Rv3CGmRhB8=";
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
