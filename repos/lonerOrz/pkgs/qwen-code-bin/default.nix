{
  lib,
  buildNpmPackage,
  fetchurl,
  fetchNpmDeps,
  runCommand,
}:
let
  pname = "qwen-code";
  version = "0.25.2";
  srcHash = "sha256-T/RsLiSbQc80KxTYOzHK4ksN3Vf3e8ur/rOWJBc4zyU=";
  npmDepsHash = "sha256-VnMeZZhZ/Fj8iogFN2bjjbg0ISnRzT1LG3TMAN/gUvw=";

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
