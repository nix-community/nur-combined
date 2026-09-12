{
  lib,
  stdenvNoCC,
  callPackage,
  jdk17,
  makeWrapper,
  source ? callPackage ./source.nix { },
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gradle-language-server";
  inherit (source) version;

  # The VSIX is a ZIP archive, but the unzip hook requires a .zip filename.
  src = source.src.overrideAttrs {
    name = "gradle-language-server-${finalAttrs.version}.zip";
  };

  nativeBuildInputs = [
    jdk17
    makeWrapper
    unzip
  ];
  sourceRoot = "extension";

  # The upstream VS Code distribution starts the server over a named pipe. Supply a
  # stdio entry point for Neovim while keeping the upstream implementation.
  buildPhase = ''
    runHook preBuild
    cp ${./GradleLanguageServerStdio.java} GradleLanguageServerStdio.java
    javac -cp 'lib/*' -d lib GradleLanguageServerStdio.java
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gradle-language-server
    cp -r lib $out/share/gradle-language-server/
    install -Dm644 LICENSE.md $out/share/licenses/gradle-language-server/LICENSE
    makeWrapper ${lib.getExe jdk17} $out/bin/gradle-language-server \
      --add-flags "-cp $out/share/gradle-language-server/lib:$out/share/gradle-language-server/lib/* GradleLanguageServerStdio"
    runHook postInstall
  '';

  meta = {
    description = "Gradle language server with a stdio launcher";
    homepage = "https://github.com/microsoft/vscode-gradle";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    mainProgram = "gradle-language-server";
    platforms = lib.platforms.unix;
  };
})
