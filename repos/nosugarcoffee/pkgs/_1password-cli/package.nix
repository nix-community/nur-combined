# nixpkgs carries the 1Password CLI too, but trails upstream by several minor
# releases; this follows the release feed nightly. It repacks AgileBits'
# per-platform zips, which unlike the macOS .pkg nixpkgs unpacks put a single
# signed `op` at the root, so one URL template covers every system. The
# desktop app only trusts an `op` carrying AgileBits' signature, which is why
# nothing here may strip or re-sign it.
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  autoPatchelfHook,
  installShellFiles,
}:
let
  pin = import ../../lib/release-pin.nix {
    inherit lib fetchurl;
  } ./pin.json stdenvNoCC.hostPlatform.system;
in
stdenvNoCC.mkDerivation {
  pname = "1password-cli";
  inherit (pin) version src;

  nativeBuildInputs = [
    unzip
    installShellFiles
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isLinux autoPatchelfHook;
  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -D op $out/bin/op
    runHook postInstall
  '';

  postInstall = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    HOME=$TMPDIR
    installShellCompletion --cmd op \
      --bash <($out/bin/op completion bash) \
      --fish <($out/bin/op completion fish) \
      --zsh <($out/bin/op completion zsh)
  '';

  meta = {
    description = "1Password command-line tool (official signed release)";
    homepage = "https://developer.1password.com/docs/cli/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "op";
    inherit (pin) platforms;
  };
}
