{ fetchFromGitHub
, fetchpatch2
, lib
, makeBinaryWrapper
, nix-update-script
, stdenv
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
stdenv.mkDerivation (chunker: {
  pname = "chunker";
  version = "1.19.1";
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
    hash = "sha256-dE79a5o+31hSRA+8G9RqqYKwXy3V7DycQ3Cd7PETLJw=";
  });

  patches = [
    # Pending HiveGamesOSS/Chunker#2483 (resolves “Could not find com.android.tools:r8:9.1.31” via GradleUp/shadow#2101)
    (fetchpatch2 {
      url = "https://github.com/HiveGamesOSS/Chunker/commit/df3cbd4ecfdcfa55178a10b7cfd13c38b026947e.patch";
      hash = "sha256-Y11lh/JEqxsIV8E0KLxeJXf7qmtrWQTA9L60qKXdgcQ=";
    })
  ];

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
