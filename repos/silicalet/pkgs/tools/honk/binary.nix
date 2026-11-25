{
  lib,
  stdenvNoCC,
  fetchurl,
  withDoona ? true,
}:

let
  sources = {
    x86_64-linux = import ./sources/x86_64-linux.nix;
    aarch64-linux = import ./sources/aarch64-linux.nix;
  };
  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "honk-bin is unsupported on ${stdenvNoCC.hostPlatform.system}");
  inherit (source) version;
  target = stdenvNoCC.hostPlatform.uname.processor;
  variant = if withDoona then "full" else "native-api";
  hash = if withDoona then source.hash else source.noDoonaHash;
  src = fetchurl {
    url = "https://github.com/daeuniverse/honk/releases/download/v${version}/honk-core-v${version}-${target}-unknown-linux-musl-${variant}.tar.gz";
    inherit hash;
  };
in
stdenvNoCC.mkDerivation {
  pname = "honk-core-bin";
  inherit version src;
  dontBuild = true;
  dontFixup = true; # Static, already stripped by upstream.
  passthru = { inherit withDoona; };

  installPhase = ''
    runHook preInstall
    install -Dm555 honk-core "$out/bin/honk-core"
    install -Dm444 README.md "$out/share/doc/honk-core/README.md"
    install -Dm444 LICENSE "$out/share/licenses/honk-core/LICENSE"
    ${lib.optionalString withDoona ''
      for edition in doona doona-lite; do
        mkdir -p "$out/share/licenses/honk-core/$edition"
        cp -a "$edition"/. "$out/share/licenses/honk-core/$edition/"
      done
    ''}
    runHook postInstall
  '';

  doInstallCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  installCheckPhase = ''
    "$out/bin/honk-core" --version
    "$out/bin/honk-core" --help >/dev/null
  '';

  meta = {
    description = "Linux eBPF transparent proxy engine (official ${variant} release)";
    homepage = "https://github.com/daeuniverse/honk";
    license = [
      lib.licenses.gpl3Only
    ]
    ++ lib.optionals withDoona (
      with lib.licenses;
      [
        asl20
        ofl
        mit
      ]
    );
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "honk-core";
    platforms = builtins.attrNames sources;
  };
}
