{ fetchFromGitHub
, lib
, makeBinaryWrapper
, nix-update-script
, stdenv
, versionCheckHook
, writeShellScriptBin

  # Dependencies
, git
, gradle_9
, temurin-bin-17
}:

let
  inherit (builtins) match;
  inherit (lib) concatStrings escapeShellArg escapeShellArgs licenses versionAtLeast;
  inherit (lib.trivial) release;

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
stdenv.mkDerivation (chunker: {
  pname = "chunker";
  version = "1.18.1";
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
  } // (if (versionAtLeast release "26.05") then {
    postCheckout = fakeGitInit;
    hash = "sha256-R+ZzlmqgLe4GlY9M2l1gosAxspZye/GyTBIgpEQh+To=";
  } else {
    leaveDotGit = true;
    hash = "sha256-pelYD/4mHk68UjmJsjokq3ymKUfZJgD5v98P5WXqbwA=";
  }));

  mitmCache =
    let tag = "gradle${concatStrings (match "([[:digit:]]+)\\.([[:digit:]]+).*" gradle_9.version)}"; in
    gradle_9.fetchDeps {
      pkg = chunker.finalPackage;
      data = ./assets/chunker-deps-${tag}.json; # To generate, run `$(nix-build --pure '<nixpkgs>' --attr 'chunker.mitmCache.updateScript')`
    };

  nativeBuildInputs = [ gradle_9 makeBinaryWrapper ]
    ++ [ (if (versionAtLeast release "26.05") then fakeGit else git) ];
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
