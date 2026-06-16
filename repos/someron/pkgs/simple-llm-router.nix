{
  lib,
  fetchFromGitea,
  buildGoModule,
}:
let
  version = "v1.0.1";
  hash = "sha256-YxuFz6rTNjylFW50uQ3jvwWa3eciAGE0zGLMBVJpcjM=";
  vendorHash = "sha256-2UCwsvlpIDldOBH0FreZdBE4D1NBdG43SQIzfwgORUo=";
in
buildGoModule {
  name = "simple-llm-router";
  meta = {
    description = "A simple LLM-proxy that uses OpenRouter-Style model ids to address models from multiple providers.";
    homepage = "https://codeberg.org/someron/simple-llm-router";
    license = lib.licenses.mit;
    mainProgram = "simple-llm-router";
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "someron";
    repo = "simple-llm-router";
    rev = version;
    inherit hash;
  };

  inherit version vendorHash;
}
