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

  bumpedSrc = testPkgs.runCommand "source" { } ''
    cp -r ${src} $out
    chmod -R u+w $out
    substituteInPlace $out/main.go --replace-fail '"fmt"' '"fmt" // bumped'
  '';

  mkFixture =
    args:
    testPkgs.mkGoModule (
      {
        pname = "fixture";
        version = "1.0.0";
        inherit src;
        vendorHash = "sha256-BaQE3EMAEWUx46qS48fPY55MxEQILqB39maYRuKh3GM=";
        # dep/ is a separate module, replaced in go.mod
        subPackages = [ "." ];

        # logs the commands go runs, to check which packages are compiled
        preBuild = ''
          export GOFLAGS="$GOFLAGS -x"
          goLog="$NIX_BUILD_TOP/build.log"
          go() {
            local status=0
            command go "$@" 2> "$NIX_BUILD_TOP/go.stderr" || status=$?
            tee -a "$goLog" < "$NIX_BUILD_TOP/go.stderr" >&2
            return "$status"
          }
        '';

        preCheck = ''
          goLog="$NIX_BUILD_TOP/check.log"
        '';

        preInstall = ''
          grep --quiet -- ' -p main ' "$NIX_BUILD_TOP/build.log"
          if grep -- ' -p example.com/dep ' "$NIX_BUILD_TOP/build.log"; then
            echo "the dependency was rebuilt" >&2
            exit 1
          fi

          grep --quiet -- ' -p main ' "$NIX_BUILD_TOP/check.log"
          # cache entries for tests depend on the build directory
          if [ "$(cat "$goCache/dir")" = "$PWD" ]; then
            if grep -E -- ' -p (example\.com/dep|testing) ' "$NIX_BUILD_TOP/check.log"; then
              echo "the dependencies of tests were rebuilt" >&2
              exit 1
            fi
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

  withoutChecks = mkFixture {
    doCheck = false;
  };

  proxyVendor = mkFixture {
    proxyVendor = true;
  };

  # buildGoModule defaults to go's platforms, which don't include windows
  windows = testPkgs.pkgsCross.mingwW64.mkGoModule {
    pname = "fixture";
    version = "1.0.0";
    inherit src;
    vendorHash = "sha256-BaQE3EMAEWUx46qS48fPY55MxEQILqB39maYRuKh3GM=";
    meta.platforms = testPkgs.lib.platforms.all;
  };

  # without dependencies there's no vendor directory to build a cache from
  nodeps = testPkgs.mkGoModule {
    pname = "nodeps";
    version = "1.0.0";
    src = builtins.path {
      name = "source";
      path = ./fixture-nodeps;
    };
    vendorHash = null;
  };
in
# the dependencies don't change with the version or the main module's sources
assert fixture.goCache.outPath == bumped.goCache.outPath;
assert fixture.goModules.outPath == bumped.goModules.outPath;
assert fixture.outPath != bumped.outPath;
assert fixture.goCache.buildTestDeps;
assert !withoutChecks.goCache.buildTestDeps;
assert !(builtins.tryEval proxyVendor.drvPath).success;
assert (builtins.tryEval windows.goCache.drvPath).success;
assert nodeps.goCache == null;
assert nodeps.passthru.goCache == null;
{
  mkGoModule-build = testPkgs.runCommand "mkGoModule-build" { } ''
    test "$(${fixture}/bin/fixture)" = "hello from dep"
    test "$(${bumped}/bin/fixture)" = "hello from dep"
    test "$(${nodeps}/bin/nodeps)" = "hello without deps"
    touch $out
  '';
}
