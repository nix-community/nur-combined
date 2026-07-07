{
  sources,
  lib,
  buildNpmPackage,
  nodejs,
  versionCheckHook,
}:

buildNpmPackage (finalAttrs: {
  inherit (sources.command-code) pname version src;

  sourceRoot = "package";

  npmDepsHash = "sha256-HRRgeqa8MH1Bk7LAVxCF1v+od80JMzNh3KdSHDqe+H8=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/command-code \
      --add-flags "$out/lib/node_modules/command-code/dist/index.mjs"
    makeWrapper ${lib.getExe nodejs} $out/bin/cmd \
      --add-flags "$out/lib/node_modules/command-code/dist/index.mjs"
    makeWrapper ${lib.getExe nodejs} $out/bin/cmdc \
      --add-flags "$out/lib/node_modules/command-code/dist/index.mjs"
    makeWrapper ${lib.getExe nodejs} $out/bin/commandcode \
      --add-flags "$out/lib/node_modules/command-code/dist/index.mjs"
  '';

  meta = {
    description = "Coding agent that continuously learns your coding taste";
    homepage = "https://github.com/CommandCodeAI/command-code";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "command-code";
    platforms = lib.platforms.linux;
  };
})
