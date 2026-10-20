{
  pkgs,
  self,
}:

let
  testPkgs = pkgs.extend self.overlays.libs;
  inherit (testPkgs) lib;

  # named like fetched sources, the dependency derivation uses the directory name
  src = builtins.path {
    name = "source";
    path = ./fixture;
  };

  bumpedSrc = builtins.path {
    name = "source";
    path = ./fixture-bumped;
  };

  mkFixture =
    args:
    testPkgs.mkRustPackage (
      {
        pname = "fixture";
        version = "1.0.0";
        inherit src;

        # runs after the artifacts are restored, cargo rewrites the files of the
        # crates it compiles
        preBuild = ''
          touch "$NIX_BUILD_TOP/restored"
        '';

        # after both the build and check phases, the -tmp directories are copies
        # made by cargoInstallPostBuildHook
        preInstall = ''
          changed() {
            find target -path '*-tmp' -prune -o -newer "$NIX_BUILD_TOP/restored" -name "$1" -print
          }
          if ! changed '*fixture*' | grep --quiet .; then
            echo "the package wasn't built" >&2
            exit 1
          fi
          if changed '*cfg*if*' | grep .; then
            echo "the dependency was rebuilt" >&2
            exit 1
          fi
        '';
      }
      // args
    );

  fixture = mkFixture { };

  bumped = mkFixture {
    version = "1.1.0";
    src = bumpedSrc;
  };

  withCargoDeps = mkFixture {
    cargoDeps = null;
  };

  # paths and sources from lib.sources or lib.fileset are read through their
  # path, which works in read-only evaluation. The result has to be the same as
  # when reading their store path, including the filter, which also applies to
  # the files in excluded directories
  withPath = mkFixture { src = ./fixture; };
  withStorePath = mkFixture { src = builtins.path { path = ./fixture; }; };

  withFileset = mkFixture {
    src = lib.fileset.toSource {
      root = ./fixture;
      fileset = lib.fileset.unions [
        ./fixture/Cargo.toml
        ./fixture/Cargo.lock
        ./fixture/src
      ];
    };
  };

  withoutSrcDir = path: _: baseNameOf path != "src";
  withFilter = mkFixture {
    src = lib.cleanSourceWith {
      name = "source";
      src = ./fixture;
      filter = withoutSrcDir;
    };
  };
  withFilteredStorePath = mkFixture {
    src = builtins.path {
      name = "source";
      path = ./fixture;
      filter = withoutSrcDir;
    };
  };

  # the dependencies are built with the same check phase, against the stubs
  withClippy = mkFixture {
    nativeCheckInputs = [ testPkgs.clippy ];
    checkPhase = ''
      runHook preCheck
      cargo clippy --offline --all-targets -- -D warnings
      runHook postCheck
    '';
  };
in
# the dependencies don't change with the version or the workspace's sources
assert fixture.cargoArtifacts.outPath == bumped.cargoArtifacts.outPath;
assert fixture.outPath != bumped.outPath;
assert !(builtins.tryEval withCargoDeps.drvPath).success;
assert withPath.cargoArtifacts.outPath == withStorePath.cargoArtifacts.outPath;
assert withFileset.cargoArtifacts.outPath == fixture.cargoArtifacts.outPath;
assert withFilter.cargoArtifacts.outPath == withFilteredStorePath.cargoArtifacts.outPath;
assert withFilter.cargoArtifacts.outPath != fixture.cargoArtifacts.outPath;
{
  mkRustPackage-build = testPkgs.runCommand "mkRustPackage-build" { } ''
    test "$(${fixture}/bin/fixture)" = "hello from unix"
    test "$(${bumped}/bin/fixture)" = "hello from bumped unix"
    test "$(${withClippy}/bin/fixture)" = "hello from unix"

    # the vendor directory is remapped in the dependencies' panic locations
    panic=$(${fixture}/bin/fixture panic 2>&1 || true)
    if [[ $panic != *"panicked at /cargo-vendor/smallvec-"* ]]; then
      echo "$panic" >&2
      exit 1
    fi

    touch $out
  '';
}
