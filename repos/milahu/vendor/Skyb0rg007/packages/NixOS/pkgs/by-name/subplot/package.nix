{
  fetchFromRadicle,
  graphviz-nox,
  jre,
  lib,
  makeWrapper,
  plantuml,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "subplot";
  version = "0.14.0";

  src = fetchFromRadicle {
    seed = "radicle.subplot.tech";
    repo = "zjxyd2A1A7FnxtC69qDfoAajfTHo"; # subplot
    rev = "7551e2d55af928323ce7edc89f4672b789d2819c"; # 0.14.0
    hash = "sha256-tId6lHDYqUiqJJalRi8leJn6ykZEw8fj08DKJWjmc9U=";
  };

  cargoHash = "sha256-GiTrdBUVkGITpC0aTzRNRwFvjZvf0K063BI9XaNGCtM=";

  env = {
    SUBPLOT_PLANTUML_JAR_PATH = "${plantuml}/lib/plantuml.jar";
    SUBPLOT_JAVA_PATH = "${lib.getExe jre}";
    SUBPLOT_DOT_PATH = "${lib.getExe' graphviz-nox "dot"}";
  };

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [
    graphviz-nox
    jre
  ];
  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;

  postInstall = ''
    wrapProgram $out/bin/subplot \
      --set-default SUBPLOT_PLANTUML_JAR_PATH "$SUBPLOT_PLANTUML_JAR_PATH" \
      --set-default SUBPLOT_JAVA_PATH "$SUBPLOT_JAVA_PATH" \
      --set-default SUBPLOT_DOT_PATH "$SUBPLOT_DOT_PATH"
  '';

  meta = {
    description = "Automated tool for acceptance testing";
    longDescription = ''
      Subplot is a set of tools for specifying, documenting, and
      implementing automated acceptance tests for systems and software.
      Subplot tools help produce a human-readable document of acceptance
      criteria and a program that automatically tests a system against
      those criteria.
    '';
    mainProgram = "subplot";
    homepage = "https://subplot.tech/";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    license = lib.licenses.mit0;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
