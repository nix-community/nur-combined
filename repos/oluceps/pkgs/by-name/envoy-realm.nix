{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "1.40.0";
  releases = {
    x86_64-linux = {
      arch = "x86_64";
      hash = "sha256-iqE3p9AJlM5D9hNVb1oSBwkin2O+24bu3eXMvEAsK4A=";
    };
    aarch64-linux = {
      arch = "aarch_64";
      hash = "sha256-A8rMlSVhY1wLfSqCkpHzQdrb68MgUEde++cyGxu+GMI=";
    };
  };
  release = releases.${stdenv.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "envoy";
  inherit version;
  src = fetchurl {
    url = "https://github.com/envoyproxy/envoy/releases/download/v${version}/envoy-${version}-linux-${release.arch}";
    inherit (release) hash;
  };
  dontUnpack = true;
  dontStrip = true;
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];
  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/envoy"
    runHook postInstall
  '';
  meta = {
    description = "Envoy service proxy with SPIRE SDS and forward-proxy address filtering";
    homepage = "https://www.envoyproxy.io/";
    changelog = "https://github.com/envoyproxy/envoy/releases/tag/v${version}";
    license = lib.licenses.asl20;
    platforms = builtins.attrNames releases;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "envoy";
  };
}
