{
  lib,
  bashInteractive,
  bubblewrap,
  buildNpmPackage,
  nodejs_24,
  python3,
  makeWrapper,
  source ? callPackage ./source.nix { },
  callPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "deepseek-harness";
  inherit (source) version;

  src = ./.;

  nodejs = nodejs_24;
  inherit (source) npmDepsHash;

  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;

  nativeBuildInputs = [
    makeWrapper
    python3
  ];

  dontPatchELF = true;

  buildPhase = ''
    runHook preBuild

    npm rebuild node-pty --offline

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/deepseek-harness
    cp -r node_modules $out/share/deepseek-harness/
    substituteInPlace \
      $out/share/deepseek-harness/node_modules/@deepseek-ai/dsh-terminal-bash/lib/index.js \
      --replace-fail \
        '"/bin/bash"' \
        '"${lib.getExe bashInteractive}"'

    makeWrapper ${lib.getExe nodejs_24} $out/bin/dsh \
      --prefix PATH : ${lib.makeBinPath [ bubblewrap ]} \
      --add-flags "--expose-internals" \
      --add-flags $out/share/deepseek-harness/node_modules/@deepseek-ai/dsh/lib/bin.js

    runHook postInstall
  '';

  meta = {
    description = "Open-source, plugin-based agent harness developed by DeepSeek AI";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.mit;
    mainProgram = "dsh";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
