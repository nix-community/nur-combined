{ pkgs
, maintainers
, ...
}:

let
  lib = pkgs.lib;

  pname = "pi-furry-partner-hd";
  # Tracks the upstream release tag. Note that the HD edition carries its own
  # manifest version (`editions/hd/package.json`, currently 2.5.1-preview.8) and
  # is released from `hd-v2.5.1-preview.*` tags; `v2.5.6` is the repository
  # release the HD edition currently builds from.
  version = "2.5.6";

  # Pinned to the release tag. Bump this deliberately instead of following the
  # branch, so a rebuild always describes the same tree.
  #
  # Upstream filters this tree down to `editions/hd` with `cleanSourceWith`,
  # because there `src` is the flake's own `self`. That does not carry over:
  # `cleanSourceWith` reads the path while evaluating and a fetcher output is
  # not realized yet at that point, so evaluation fails on a clean store. The
  # filter would only save ~120 MiB of the ~1.9 GiB tree, so use the pinned
  # tree as-is; the build scripts only ever touch `editions/hd`.
  src = pkgs.fetchFromGitHub {
    owner = "KouzakiUmi";
    repo = "pi-furry-partner";
    rev = "v${version}";
    hash = "sha256-t3+k/j4itnB2KCo+SAW5WnezqlRaotEZcRnbOLvu4+M=";
  };

  node = pkgs.nodejs_24;

  pythonWithValidation = pkgs.python3.withPackages (pythonPackages: [
    pythonPackages.numpy
    pythonPackages.pillow
  ]);

  # The HD build runs its suite against four pinned Pi runtimes. They are pure
  # npm dependency closures, so pin the dependency hashes exactly like upstream
  # does rather than installing anything at build time. Copying the runtime
  # directories in a derivation (instead of `builtins.path`) keeps evaluation
  # free of store reads on the not-yet-realized source.
  testRuntimeSource = runtimeName:
    pkgs.runCommand "pi-test-runtime-${runtimeName}" { } ''
      cp -R ${src}/editions/hd/test-runtimes/${runtimeName} $out
    '';

  mkPiTestRuntime = { runtimeName, version, npmDepsHash }:
    pkgs.buildNpmPackage {
      pname = "pi-furry-partner-pi-test-runtime";
      inherit version npmDepsHash;
      src = testRuntimeSource runtimeName;
      dontNpmBuild = true;
      npmRebuildFlags = [ "--ignore-scripts" ];
      installPhase = ''
        mkdir -p "$out"
        cp -R node_modules "$out/node_modules"
      '';
    };

  piTestRuntime12 = mkPiTestRuntime {
    runtimeName = "pi-1.2";
    version = "1.2.0";
    npmDepsHash = "sha256-ekvuj0ET7Ppze0NYOXHiMlJBRAz03DhdZ0h2nnYk7dA=";
  };

  piTestRuntime13 = mkPiTestRuntime {
    runtimeName = "pi-1.3";
    version = "1.3.0";
    npmDepsHash = "sha256-4Ji/yjhDhOAU+tZKQ5EF+DkczowJgzxWlnwzF5la4gU=";
  };

  piTestRuntime14 = mkPiTestRuntime {
    runtimeName = "pi-1.4";
    version = "1.4.0";
    npmDepsHash = "sha256-KkB5B+ZbsOn1ZXVjZ1hbrVRX4qKEpV5jPqsZL3aV9Cw=";
  };

  piTestRuntime15 = mkPiTestRuntime {
    runtimeName = "pi-1.5";
    version = "1.5.0";
    npmDepsHash = "sha256-sdGC7Bpjual3rhCXZ6eeeV25PZ7N3dDaUyHGwRRyI/s=";
  };
in
# Mirrors the upstream `pi-hd-extension` output. `out` is the unpacked Pi
# extension tree; `bundle` is the release archive with its reports. Both come
# from one verified build because either output must pass the same four-runtime
# suite, edition audit and packaging smoke test.
pkgs.stdenvNoCC.mkDerivation {
  inherit pname version;

  outputs = [ "out" "bundle" ];
  inherit src;
  nativeBuildInputs = [
    node
    pythonWithValidation
    piTestRuntime12
    piTestRuntime13
    piTestRuntime14
    piTestRuntime15
  ];
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    export HOME="$NIX_BUILD_TOP/home"
    mkdir -p "$HOME"
    sourceDir="$NIX_BUILD_TOP/$sourceRoot/editions/hd"
    rm -rf "$sourceDir/dist"
    cd "$sourceDir"
    python tools/build-editions.py --edition full-animation --platform pi --test \
      --test-modules "${piTestRuntime12}/node_modules" \
      --test-modules "${piTestRuntime13}/node_modules" \
      --test-modules "${piTestRuntime14}/node_modules" \
      --test-modules "${piTestRuntime15}/node_modules"
    python tools/audit-edition-bundles.py
    python tools/write-edition-release.py
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out" "$bundle"
    cp -R "$NIX_BUILD_TOP/$sourceRoot/editions/hd/dist/releases/." "$bundle/"
    python "$NIX_BUILD_TOP/$sourceRoot/editions/hd/tools/rebase-release-report-paths.py" \
      --directory "$bundle"
    cp -R "$NIX_BUILD_TOP/$sourceRoot/editions/hd/dist/verified/full-animation-pi/package/." \
      "$out/"
    test -f "$out/package.json"
    test -f "$out/index.ts"
    runHook postInstall
  '';

  meta = {
    description = "Pi companion HD extension: one verified build shared by the installable package and the release archive";
    homepage = "https://github.com/KouzakiUmi/pi-furry-partner";
    # Apache-2.0 covers the extension code. The bundled artwork follows
    # editions/hd/ASSET_LICENSE.md, which this derivation does not relicense.
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    maintainers = [ maintainers.srcres258 ];
    # Pi extension tree, not an executable: there is no mainProgram to expose.
  };
}
