{
  sources,
  lib,
  buildNpmPackage,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  inherit (sources.n8n-openai-bridge) pname version src;

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
