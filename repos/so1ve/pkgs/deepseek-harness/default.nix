{
  lib,
  stdenv,
  buildNpmPackage,
  nodejs_24,
  makeWrapper,
  autoPatchelfHook,
  source ? callPackage ./source.nix { },
  callPackage,
}:

let
  koffiArch = stdenv.hostPlatform.node.arch;
  unusedKoffiVariant =
    if stdenv.hostPlatform.isMusl then "linux_${koffiArch}" else "musl_${koffiArch}";
in
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
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/deepseek-harness
    cp -r node_modules $out/share/deepseek-harness/
    rm -r \
      $out/share/deepseek-harness/node_modules/@koromix/koffi-linux-${koffiArch}/${unusedKoffiVariant}

    makeWrapper ${lib.getExe nodejs_24} $out/bin/dsh \
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
