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
      hash = "sha256-deoqOhnEsYm4RdfX6Gd7Smc1LGph0Rn8705nwhC+F1Y=";
    };
    aarch64-linux = {
      asset = "magpie-cli-linux-arm64";
      hash = "sha256-i4bEnhSwyeCh713aLxNfbVSr4xv3iKjYCdyYySG94Ts=";
    };
    aarch64-darwin = {
      asset = "magpie-cli-darwin-arm64";
      hash = "sha256-DDpG0uvyayk9dQCVZHW16I829MQ8CcM5fcD8XBhGmX8=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "magpie";
  version = "0.1.5019";

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
