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
      hash = "sha256-43m9qlIRSpzhTHNbamgcki3W56jm0QDoCUlxCSBVyDg=";
    };
    aarch64-linux = {
      asset = "magpie-cli-linux-arm64";
      hash = "sha256-OS+Gz2IsSoLCYR0nQ0uWlRr/q40Rg2aarAo4bnGcQ8g=";
    };
    aarch64-darwin = {
      asset = "magpie-cli-darwin-arm64";
      hash = "sha256-HzlhOcR21p3dk/3YYUcn91mX4h2/8214dNJFUQR6uVg=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "magpie";
  version = "0.1.4667";

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
