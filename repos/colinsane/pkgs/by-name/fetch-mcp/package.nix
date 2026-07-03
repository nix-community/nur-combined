{
  buildNpmPackage,
  esbuild,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "fetch-mcp";
  version = "1.1.2-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "zcaceres";
    repo = "fetch-mcp";
    rev = "1ddb1a59cb09a2d38e759f2d7a97829680cbe514";
    hash = "sha256-1sds6oVjqSiZhgRGvY5/oS1PEGkJwHgBsV0u81O+2rQ=";
  };

  npmDepsHash = "sha256-heUVTTnvUIqUBcRoIpb5cj5s32GsUKHvefTfST6JorU=";

  # lockfile generated using `npm install --package-lock-only`
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  nativeBuildInputs = [ esbuild ];

  # Override the build to use esbuild instead of bun build
  preBuild = ''
    esbuild src/index.ts src/cli.ts \
      --outdir=dist \
      --platform=node \
      --target=node18 \
      --external:jsdom \
      --external:@mozilla/readability \
      --external:turndown \
      --format=esm \
      --bundle
  '';

  # Skip the default npm build
  dontNpmBuild = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--generate-lockfile" ];
  };

  meta = {
    description = "MCP server and CLI for fetching web content as HTML, Markdown, plain text, JSON, or YouTube transcripts";
    homepage = "https://github.com/zcaceres/fetch-mcp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
