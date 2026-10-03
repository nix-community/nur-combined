{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  sources = {
    x86_64-linux = {
      arch = "x64";
      hash = "sha256-I4Fz2F6XV7mR835goyM9CZsfYkfvGok0wUxCmDvxBL0=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-rv+vLF1a+3UQBjVl2JuXTjE8vAqoz2dcYCk+IX3w8L8=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fluxdown-server";
  version = "0.5.3";

  src = fetchurl {
    url = "https://github.com/zerx-lab/FluxDown/releases/download/v${finalAttrs.version}/FluxDown-Server-${finalAttrs.version}-linux-${source.arch}.tar.gz";
    inherit (source) hash;
  };

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 fluxdown-agent fluxdownd -t "$out/bin"
    runHook postInstall
  '';

  meta = {
    description = "Multi-protocol download server with an embedded Web UI";
    homepage = "https://github.com/zerx-lab/FluxDown";
    license = lib.licenses.agpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = "fluxdown-agent";
  };
})
