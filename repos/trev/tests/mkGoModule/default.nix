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

  fixtureArgs = {
    pname = "fixture";
    version = "1.0.0";
    inherit src;
    vendorHash = "sha256-QMeGa7qA7zvyX7ZB7cgl0BGIyDuEU19vqFlewKubAz0=";
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
      if grep -E -- ' -p (example\.com/dep|github\.com/google/uuid) ' "$NIX_BUILD_TOP/build.log"; then
        echo "the dependencies were rebuilt" >&2
        exit 1
      fi

      grep --quiet -- ' -p main ' "$NIX_BUILD_TOP/check.log"
      # cache entries for tests depend on the build directory
      if [ "$(cat "$goCache/dir")" = "$PWD" ]; then
        if grep -E -- ' -p (example\.com/dep|github\.com/google/uuid|testing) ' "$NIX_BUILD_TOP/check.log"; then
          echo "the dependencies of tests were rebuilt" >&2
          exit 1
        fi
      fi
    '';
  };

  mkFixture = args: testPkgs.mkGoModule (fixtureArgs // args);

  # the dependencies are fetched from gomod2nix.toml, without vendorHash
  mkModulesFixture =
    args:
    testPkgs.mkGoModule (
      removeAttrs fixtureArgs [ "vendorHash" ]
      // {
        modules = ./fixture/gomod2nix.toml;
      }
      // args
    );

  fixture = mkFixture { };

  bumped = mkFixture {
    version = "1.1.0";
    src = bumpedSrc;
  };

  # go names the binary after the module path
  renamed = mkFixture {
    meta.mainProgram = "renamed";
  };

  withoutChecks = mkFixture {
    doCheck = false;
  };

  proxyVendor = mkFixture {
    proxyVendor = true;
  };

  # go's own linker can't build static PIE binaries
  withoutCgo = mkFixture {
    env.CGO_ENABLED = 0;
  };

  withoutPie = mkFixture {
    pie = false;
  };

  # static PIE binaries, linked by the external linker
  static = testPkgs.pkgsStatic.mkGoModule fixtureArgs;

  staticAarch64 = testPkgs.pkgsCross.aarch64-multiplatform-musl.pkgsStatic.mkGoModule {
    inherit (fixtureArgs)
      pname
      version
      src
      vendorHash
      subPackages
      ;
  };

  # buildGoModule defaults to go's platforms, which don't include windows
  windows = testPkgs.pkgsCross.mingwW64.mkGoModule {
    pname = "fixture";
    version = "1.0.0";
    inherit src;
    vendorHash = "sha256-QMeGa7qA7zvyX7ZB7cgl0BGIyDuEU19vqFlewKubAz0=";
    meta.platforms = testPkgs.lib.platforms.all;
  };

  modules = mkModulesFixture { };

  modulesBumped = mkModulesFixture {
    version = "1.1.0";
    src = bumpedSrc;
  };

  withoutHash = testPkgs.mkGoModule {
    pname = "fixture";
    version = "1.0.0";
    inherit src;
  };

  # readelf, to check for an interpreter
  elfTools = testPkgs.lib.optional testPkgs.stdenv.hostPlatform.isLinux testPkgs.binutils;

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
assert fixture.goCache.outPath == renamed.goCache.outPath;
assert fixture.goCache.buildTestDeps;
assert !withoutChecks.goCache.buildTestDeps;
assert !(builtins.tryEval proxyVendor.drvPath).success;
assert (builtins.tryEval windows.goCache.drvPath).success;
assert nodeps.goCache == null;
assert nodeps.passthru.goCache == null;
assert modules.goModules.outPath == modulesBumped.goModules.outPath;
assert modules.goCache.outPath == modulesBumped.goCache.outPath;
assert modules.outPath != modulesBumped.outPath;
assert !(builtins.tryEval withoutHash.drvPath).success;
assert fixture.pie == testPkgs.stdenv.hostPlatform.isLinux;
assert fixture.goCache.pie == fixture.pie;
assert !withoutPie.goCache.pie;
assert !(fixture.overrideAttrs { pie = false; }).goCache.pie;
assert static.pie == testPkgs.stdenv.hostPlatform.isLinux;
assert !windows.pie;
{
  mkGoModule-build = testPkgs.runCommand "mkGoModule-build" { nativeBuildInputs = elfTools; } ''
    test "$(${fixture}/bin/fixture)" = "hello from dep"
    test "$(${bumped}/bin/fixture)" = "hello from dep"
    test "$(${renamed}/bin/renamed)" = "hello from dep"
    test ! -e ${renamed}/bin/fixture
    test "$(${nodeps}/bin/nodeps)" = "hello without deps"
    test "$(${modules}/bin/fixture)" = "hello from dep"
    test "$(${modulesBumped}/bin/fixture)" = "hello from dep"
    # the same as `go mod vendor`
    diff ${fixture.goModules}/modules.txt ${modules.goModules}/modules.txt
    ${testPkgs.lib.optionalString testPkgs.stdenv.hostPlatform.isLinux ''
      # the ELF type, 3 for position-independent executables and 2 for others
      elfType() { od -An -tu1 -j16 -N1 "$1" | tr -d ' '; }
      test "$(elfType ${fixture}/bin/fixture)" = 3
      test "$(elfType ${withoutCgo}/bin/fixture)" = 2
      test "$(elfType ${withoutPie}/bin/fixture)" = 2

      # static PIE binaries don't have an interpreter
      isStaticPie() {
        test "$(elfType "$1")" = 3 || return 1
        local headers
        # exits even when called as a condition
        headers=$(readelf -lW "$1") || exit 1
        [[ $headers != *INTERP* ]]
      }
      test "$(${static}/bin/fixture)" = "hello from dep"
      isStaticPie ${static}/bin/fixture
      isStaticPie ${staticAarch64}/bin/fixture
      if isStaticPie ${fixture}/bin/fixture; then
        echo "dynamically linked binaries were detected as static PIE" >&2
        exit 1
      fi
    ''}
    touch $out
  '';
}
