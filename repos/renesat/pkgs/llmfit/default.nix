{
  fetchFromGitHub,
  rustPlatform,
  buildNpmPackage,
  lib,
}:
rustPlatform.buildRustPackage (
  finalAttrs: let
    frontend = buildNpmPackage {
      pname = "${finalAttrs.pname}-web";
      inherit (finalAttrs) version;

      src = "${finalAttrs.src}/llmfit-web";

      npmDepsHash = "sha256-9zQNWWp8sWuS4DFWjgrQfng+TK0DJacNbD8hJN5QnUA=";

      installPhase = ''
        runHook preInstall
        mkdir -p $out/share
        mv dist $out/share/llmfit-web
        runHook postInstall
      '';
    };
  in {
    pname = "llmfit";
    version = "0.8.0";

    src = fetchFromGitHub {
      owner = "AlexsJones";
      repo = "llmfit";
      rev = "v${finalAttrs.version}";
      hash = "sha256-ftzvoUxid6t1VTVGvGjruSMIi7tYcbzS53MOEh3PPBE=";
    };

    cargoHash = "sha256-ag051opJrIO1l8lCMZMZX/ac+LKBvgNCqZtI9eZC7Vw=";

    preBuild = ''
      cp -r ${frontend}/share/llmfit-web llmfit-web/dist
    '';

    meta = {
      description = "A terminal tool that right-sizes LLM models to your system's RAM, CPU, and GPU.";
      homepage = "https://github.com/AlexsJones/llmfit";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [renesat];
    };
  }
)
