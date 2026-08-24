{
  fetchFromGitHub,
  lib,
  buildNpmPackage,
  nix-update-script,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "n8n-openai-bridge";
  version = "0.0.17";
  src = fetchFromGitHub {
    owner = "sveneisenschmidt";
    repo = "n8n-openai-bridge";
    tag = "v0.0.17";
    hash = "sha256-tti1VBvY4UA1cGax99bRIkYWLbuuolI1MPbl9Ky1TxM=";
  };
  npmDepsHash = "sha256-El0CL6jlyEIH73caqm6VU3V/eA3CMVSaD6Uno381QUg=";

  postPatch = ''
    substituteInPlace package.json --replace-fail '"name": "n8n-openai-bridge"' '"name": "n8n-openai-bridge", "version": "${finalAttrs.version}"'
  '';

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} "$out/bin/n8n-openai-bridge" \
      --add-flags "$out/lib/node_modules/n8n-openai-bridge/src/server.js"
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    description = "OpenAI-compatible API middleware for n8n workflows";
    homepage = "https://github.com/sveneisenschmidt/n8n-openai-bridge";
    changelog = "https://github.com/sveneisenschmidt/n8n-openai-bridge/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "n8n-openai-bridge";
    platforms = lib.platforms.linux;
  };
})
