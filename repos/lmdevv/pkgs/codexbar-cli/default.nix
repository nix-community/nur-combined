{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "0.74.0";
  sha256BySystem = {
    "x86_64-linux" = "sha256-57C9xtaTGk5v1c5AN+ESWgc+xs84zXLxs72K7s/eUfU=";
    "aarch64-linux" = "sha256-nas58Rl9nMxQHR9ngjTPFflOi4Sqc0m6hxA6WGbdeTs=";
  };
  system = stdenvNoCC.hostPlatform.system;
  arch = if system == "aarch64-linux" then "aarch64" else "x86_64";
in
stdenvNoCC.mkDerivation {
  pname = "codexbar-cli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/steipete/CodexBar/releases/download/v${version}/CodexBarCLI-v${version}-linux-musl-${arch}.tar.gz";
    hash = sha256BySystem.${system} or (throw "codexbar-cli: unsupported system ${system}");
  };

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  # Preserve the upstream static executable and its adjacent resource bundle.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/libexec/codexbar"
    cp -r CodexBarCLI VERSION CodexBar_CodexBarCore.bundle "$out/libexec/codexbar/"
    ln -s ../libexec/codexbar/CodexBarCLI "$out/bin/codexbar"

    runHook postInstall
  '';

  passthru.updateScript = ../../scripts/update-codexbar-cli.sh;

  meta = {
    description = "CLI for AI coding-provider usage and spending";
    homepage = "https://github.com/steipete/CodexBar";
    changelog = "https://github.com/steipete/CodexBar/releases/tag/v${version}";
    license = lib.licenses.mit;
    platforms = builtins.attrNames sha256BySystem;
    maintainers = [ "lmdevv" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "codexbar";
  };
}
