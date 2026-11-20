{
  lib,
  stdenvNoCC,
  fetchurl,
  writeShellApplication,
  python3,
  nix-update,
  nix,
  gh,
  git,
}:
let
  sources = {
    x86_64-linux = {
      arch = "x64";
      hash = "sha256-bTn20E3t+f4Rqn2fMr1ihAIIH/EJ2FxqlCx8p/KHEg4=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-V4o6PRZz2KXYueDZd8B0fIx4jn/rRp/ca/m7GWeS0Vc=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fluxdown-server";
  version = "0.6.8";

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

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-fluxdown-server";
      runtimeInputs = [
        python3
        nix-update
        nix
        gh
        git
      ];
      text = ''
        exec python3 pkgs/fluxdown-server/update.py "$@"
      '';
    });
  };

  meta = {
    description = "Multi-protocol download server with an embedded Web UI";
    homepage = "https://github.com/zerx-lab/FluxDown";
    license = lib.licenses.agpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = "fluxdown-agent";
  };
})
