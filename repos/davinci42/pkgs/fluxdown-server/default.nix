{
  lib,
  stdenvNoCC,
  fetchurl,
  callPackage,
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
      hash = "sha256-g6fVRVlnlQZQoPKLxUlbFwYZwf9/kn/zZAv4u2hVm/c=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-EniqQB3W9/psvDryOzLpdDYYfZyOl4s8++SlS5EMRnc=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fluxdown-server";
  version = "0.6.0";

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
    tests.packaging = callPackage ../../tests/pkgs/fluxdown {
      package = finalAttrs.finalPackage;
    };
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
