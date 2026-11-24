{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  glibc,
}:

let
  version = "2.1.330";

  sources = {
    x86_64-linux = {
      arch = "linux-x64";
      hash = "sha256-QP8wxXaHI5WAMhMgZeb83R4tw6Kz/5oL82xmIO8cQO8=";
    };
    aarch64-linux = {
      arch = "linux-arm64";
      hash = "sha256-VGDULGlmcPT9Kn7GGXGe3aFKV2so7jwomzSK3pbvv20=";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "claude-code is not packaged for ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "claude-code";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code-${source.arch}/-/claude-code-${source.arch}-${version}.tgz";
    inherit (source) hash;
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ glibc ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 claude "$out/bin/claude"
    runHook postInstall
  '';

  meta = {
    description = "Anthropic Claude Code CLI (native binary distributed via npm)";
    homepage = "https://code.claude.com/";
    license = lib.licenses.unfree;
    mainProgram = "claude";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ ];
  };
}