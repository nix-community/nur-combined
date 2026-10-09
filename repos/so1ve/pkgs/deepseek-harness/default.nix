{
  lib,
  bashInteractive,
  bubblewrap,
  buildNpmPackage,
  gitMinimal,
  nodejs_24,
  pnpm,
  python3,
  makeWrapper,
  source ? callPackage ./source.nix { },
  callPackage,
}:

buildNpmPackage {
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

    # The native addon cannot load internals from this Nix Node build.
    # Use Node's require with the wrapper's --expose-internals flag instead.
    substituteInPlace \
      $out/share/deepseek-harness/node_modules/@deepseek-ai/dsh-app-boot/lib/index.js \
      --replace-fail \
        'const addon = createRequire(import.meta.url)("node-addon-require-builtin");' \
        'const addon = { requireBuiltin: createRequire(import.meta.url) };'

    makeWrapper ${lib.getExe nodejs_24} $out/bin/dsh \
      --prefix PATH : ${
        lib.makeBinPath [
          bubblewrap
          gitMinimal
          nodejs_24
          pnpm
        ]
      } \
      --add-flags "--expose-internals" \
      --add-flags $out/share/deepseek-harness/node_modules/@deepseek-ai/dsh/lib/bin.js

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    DSH_HOME="$TMPDIR/dsh-check" "$out/bin/dsh" --profile headless --dump-config-schema > /dev/null

    runHook postInstallCheck
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
}
