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
      asset = "magpie-cli-linux-amd64";
      hash = "sha256-8g+MFl/we+uJL5kC1aQoCCa40ogRosDtpz1s/sPjcfA=";
    };
    aarch64-linux = {
      asset = "magpie-cli-linux-arm64";
      hash = "sha256-PCKzVF8SJ+ai9hftEsFeBbDMVNV3XtK4akkx5/Ph5RA=";
    };
    aarch64-darwin = {
      asset = "magpie-cli-darwin-arm64";
      hash = "sha256-zgqxOdmPqiwRZZ0jk1c8bwxYG60QuUDqAVpJ+9jbvM4=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "magpie";
  version = "0.1.4685";

  src = fetchurl {
    url = "https://github.com/yetone/magpie-releases/releases/download/v${finalAttrs.version}/${source.asset}";
    inherit (source) hash;
  };

  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/magpie"
    runHook postInstall
  '';

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-magpie";
      runtimeInputs = [
        python3
        nix-update
        nix
        gh
        git
      ];
      text = ''
        exec python3 pkgs/magpie/update.py "$@"
      '';
    });
  };

  meta = {
    description = "Local AI model gateway and agent configuration manager";
    homepage = "https://github.com/yetone/magpie";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = "magpie";
  };
})
