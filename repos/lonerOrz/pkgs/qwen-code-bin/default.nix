{
  lib,
  buildNpmPackage,
  fetchurl,
  fetchNpmDeps,
  runCommand,
}:
let
  pname = "qwen-code";
  version = "0.21.7";
  srcHash = "sha256-mlxu+h6GMvjjJDRV9VPYdJNg2X+Vh1C2ZmtiLOLMHSU=";
  npmDepsHash = "sha256-CUL9KAJ/ibHG1BzyVENNVGbfzh6fK0mv+TkKQAfMJF8=";

  src = runCommand "gemini-cli-src-with-lock" { } ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@qwen-code/qwen-code/-/qwen-code-${version}.tgz";
        hash = "${srcHash}";
      }
    } -C $out --strip-components=1
    cp ${./package-lock.json} $out/package-lock.json
  '';
in
buildNpmPackage (finalAttrs: {
  inherit pname version src;

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "${npmDepsHash}";
  };

  # The package from npm is already built
  dontNpmBuild = true;

  npmFlags = [ "--ignore-scripts" ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Qwen-code is a coding agent that lives in digital world";
    homepage = "https://github.com/QwenLM/qwen-code";
    mainProgram = "qwen";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
