{ pkgs
, maintainers
, ...
}:

let
  lib = pkgs.lib;

  pname = "pi-furry-partner-hd";
  version = "2.5.1-preview.6";

  # Pinned to the `nix/hd-packaging` branch of the upstream repository. The
  # branch keeps moving, so bump this rev deliberately instead of following it.
  #
  # Upstream filters this tree down to `editions/hd` with `cleanSourceWith`,
  # because there `src` is the flake's own `self`. That does not carry over:
  # `cleanSourceWith` reads the path while evaluating and a fetcher output is
  # not realized yet at that point, so evaluation fails on a clean store. The
  # filter would only save ~120 MiB of the ~2.4 GiB tree, so use the pinned
  # tree as-is; the build scripts only ever touch `editions/hd`.
  src = pkgs.fetchFromGitHub {
    owner = "srcres258";
    repo = "pi-furry-partner";
    rev = "97084a903f9a7c0a8dc11c8c9e49ee6b1f866185";
    hash = "sha256-5U6udmO+oHZgz9hqPgeKnOKKM36J0veSpZBhCWWzQps=";
  };

  node = pkgs.nodejs_24;

  pythonWithValidation = pkgs.python3.withPackages (pythonPackages: [
    pythonPackages.numpy
    pythonPackages.pillow
  ]);

  # The HD build runs its suite against two pinned Pi runtimes. Both are pure
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
    npmDepsHash = "sha256-7cN1q36ijhAxwiUcQzb7+WPWKJU3Al6tpkPV6pz6pI4=";
  };

  piTestRuntime13 = mkPiTestRuntime {
    runtimeName = "pi-1.3";
    version = "1.3.0";
    npmDepsHash = "sha256-BSJT7Vj4ag8EJ+qnV49pM+SOV3iIeTjyXk/ykTcPDE0=";
  };
in
# Mirrors the upstream `pi-hd-extension` output. `out` is the unpacked Pi
# extension tree; `bundle` is the release archive with its reports. Both come
# from one verified build because either output must pass the same dual-runtime
# suite, edition audit and packaging smoke test.
pkgs.stdenvNoCC.mkDerivation {
  inherit pname version;

  outputs = [ "out" "bundle" ];
  inherit src;
  nativeBuildInputs = [ node pythonWithValidation piTestRuntime12 piTestRuntime13 ];
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
      --test-modules "${piTestRuntime13}/node_modules"
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
    homepage = "https://github.com/srcres258/pi-furry-partner";
    # Apache-2.0 covers the extension code. The bundled artwork follows
    # editions/hd/ASSET_LICENSE.md, which this derivation does not relicense.
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    maintainers = [ maintainers.srcres258 ];
    # Pi extension tree, not an executable: there is no mainProgram to expose.
  };
}
