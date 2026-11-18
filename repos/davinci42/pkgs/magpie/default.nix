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
      asset = "magpie-cli-linux-amd64";
      hash = "sha256-noe59QSl45PT0+Ak8eelh6CU5vQxXdtGQJnlNnM4B9w=";
    };
    aarch64-linux = {
      asset = "magpie-cli-linux-arm64";
      hash = "sha256-KcwT6dZL5sqTsJax3JB+7dFasDkr2qrQXV04+oGEvzM=";
    };
    aarch64-darwin = {
      asset = "magpie-cli-darwin-arm64";
      hash = "sha256-h9h0yARtpRqVrQylVu/5CR9+IPS00FLOkCX4JuDlAiQ=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "magpie";
  version = "0.1.4349";

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
    tests.packaging = callPackage ../../tests/pkgs/magpie {
      package = finalAttrs.finalPackage;
    };
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
