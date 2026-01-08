{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  git,
  ripgrep,
  pkg-config,
  glib,
  libsecret,
  fetchNpmDepsWithPackuments,
  npmConfigHook,
  runCommand,
}:

let
  originalSrc = fetchFromGitHub {
    owner = "QwenLM";
    repo = "qwen-code";
    tag = "v0.6.0";
    hash = "sha256-bZNrnwxshk5+KJUOZieRx6014gz6Gzjn4a0L+QWdbHM=";
  };

  src =
    runCommand "qwen-code-patched-src"
      {
        src = originalSrc;
        inherit jq;
      }
      ''
        cp -r $src/. $out
        chmod -R u+w $out

        cd $out
        ${jq}/bin/jq '
          del(.packages."node_modules/node-pty") |
          del(.packages."node_modules/@lydell/node-pty") |
          del(.packages."node_modules/@lydell/node-pty-darwin-arm64") |
          del(.packages."node_modules/@lydell/node-pty-darwin-x64") |
          del(.packages."node_modules/@lydell/node-pty-linux-arm64") |
          del(.packages."node_modules/@lydell/node-pty-linux-x64") |
          del(.packages."node_modules/@lydell/node-pty-win32-arm64") |
          del(.packages."node_modules/@lydell/node-pty-win32-x64") |
          del(.packages."node_modules/keytar") |
          walk(
            if type == "object" and has("dependencies") then
              .dependencies |= with_entries(select(.key | (contains("node-pty") | not) and (contains("keytar") | not)))
            elif type == "object" and has("optionalDependencies") then
              .optionalDependencies |= with_entries(select(.key | (contains("node-pty") | not) and (contains("keytar") | not)))
            else .
            end
          ) |
          walk(
            if type == "object" and has("peerDependencies") then
              .peerDependencies |= with_entries(select(.key | (contains("node-pty") | not) and (contains("keytar") | not)))
            else .
            end
          )
        ' package-lock.json > package-lock.json.tmp && mv package-lock.json.tmp package-lock.json
      '';
in

buildNpmPackage (finalAttrs: {
  pname = "qwen-code";
  version = "0.6.0";
  inherit src npmConfigHook;

  npmDeps = fetchNpmDepsWithPackuments {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    hash = "sha256-dLZkUhD+KiXR8x6SsG30fOsTGBnFurrgC+z0EKCL0Cw=";
    fetcherVersion = 2;
  };
  makeCacheWritable = true;

  nativeBuildInputs = [
    jq
    pkg-config
    git
  ];

  buildInputs = [
    ripgrep
    glib
    libsecret
  ];

  buildPhase = ''
    runHook preBuild

    npm run generate
    npm run bundle

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/qwen-code
    cp -r dist/* $out/share/qwen-code/
    # Install production dependencies only
    npm prune --production
    cp -r node_modules $out/share/qwen-code/
    # Remove broken symlinks that cause issues in Nix environment
    find $out/share/qwen-code/node_modules -type l -delete || true
    patchShebangs $out/share/qwen-code
    ln -s $out/share/qwen-code/cli.js $out/bin/qwen

    runHook postInstall
  '';

  meta = {
    description = "Coding agent that lives in digital world";
    homepage = "https://github.com/QwenLM/qwen-code";
    mainProgram = "qwen";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [
      lonerOrz
    ];
  };
})
