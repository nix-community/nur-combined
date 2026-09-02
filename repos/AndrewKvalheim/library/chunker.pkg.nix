{ fetchFromGitHub
, lib
, makeBinaryWrapper
, nix-update-script
, stdenvNoCC
, versionCheckHook
, writeShellScriptBin

  # Dependencies
, gradle_9
, temurin-bin-17
}:

let
  inherit (builtins) match;
  inherit (lib) concatStrings escapeShellArg escapeShellArgs licenses;

  # Workaround for NixOS/nixpkgs#8567
  fakeGitCommands = [
    "git branch --show-current"
    "git describe --tags --always"
  ];
  fakeGitInit = ''
    for command in ${escapeShellArgs fakeGitCommands}; do
      env --chdir "$out" $command > "$out/.$command"
    done
  '';
  fakeGit = writeShellScriptBin "git" ''
    exec cat ".git $*"
  '';
in
stdenvNoCC.mkDerivation (chunker: {
  pname = "chunker";
  version = "1.20.0";
  meta = {
    description = "Convert Minecraft worlds between game versions";
    homepage = "https://www.chunker.app/";
    license = licenses.mit;
    mainProgram = "chunker";
  };

  passthru.updateScript = nix-update-script { };

  src = fetchFromGitHub ({
    owner = "HiveGamesOSS";
    repo = "Chunker";
    rev = "refs/tags/${chunker.version}";
    postCheckout = fakeGitInit;
    hash = "sha256-FTPXicy58L3LrbM6pBqli1CMtEWc5C+mgnc/1yMq8GU=";
  });

  mitmCache =
    let tag = "gradle${concatStrings (match "([[:digit:]]+)\\.([[:digit:]]+).*" gradle_9.version)}"; in
    gradle_9.fetchDeps {
      pkg = chunker.finalPackage;
      data = ./assets/chunker-deps-${tag}.json; # To generate, run `$(nix-build --pure '<nixpkgs>' --attr 'chunker.mitmCache.updateScript')`
    };

  nativeBuildInputs = [ fakeGit gradle_9 makeBinaryWrapper ];
  gradleFlags = [ "-Dorg.gradle.java.home=${temurin-bin-17}" ];

  installPhase = ''
    runHook preInstall

    jar="$out/share/chunker/chunker.jar"
    install -D 'build/libs/chunker-cli-'${escapeShellArg chunker.version}'.jar' "$jar"
    makeWrapper "${temurin-bin-17}/bin/java" "$out/bin/chunker" --add-flags "-jar $jar"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
})
