{
  pkgs,
  self,
}:

let
  testPkgs = pkgs.extend self.overlays.libs;

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
in
# the dependencies don't change with the version or the workspace's sources
assert fixture.cargoArtifacts.outPath == bumped.cargoArtifacts.outPath;
assert fixture.outPath != bumped.outPath;
assert !(builtins.tryEval withCargoDeps.drvPath).success;
{
  mkRustPackage-build = testPkgs.runCommand "mkRustPackage-build" { } ''
    test "$(${fixture}/bin/fixture)" = "hello from unix"
    test "$(${bumped}/bin/fixture)" = "hello from bumped unix"
    touch $out
  '';
}
