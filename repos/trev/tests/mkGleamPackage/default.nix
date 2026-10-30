{
  pkgs,
  self,
}:

let
  testPkgs = pkgs.extend self.overlays.libs;

  # app/ depends on dep/ by path, gleam_stdlib from hex and justin from git.
  # lib/ is a library with tests, depending on dep/ and telemetry (rebar3)
  src = builtins.path {
    name = "source";
    path = ./fixture;
  };

  bumpedSrc = testPkgs.runCommand "source" { } ''
    cp -r ${src} $out
    chmod -R u+w $out
    substituteInPlace $out/app/src/fixture.gleam --replace-fail 'import gleam/io' 'import gleam/io // bumped'
  '';

  mkFixture =
    args:
    testPkgs.mkGleamPackage (
      {
        pname = "fixture";
        version = "1.0.0";
        inherit src;
        gleamRoot = "app";
      }
      // args
    );

  # the executable is installed before postInstall
  erlang = mkFixture {
    postInstall = ''
      test -x "$out/bin/fixture"
    '';
  };

  javascript = mkFixture {
    gleamTarget = "javascript";
    postInstall = ''
      test -x "$out/bin/fixture"
    '';
  };

  library = mkFixture {
    gleamRoot = "lib";
    gleamLibrary = true;
  };

  libraryJavascript = mkFixture {
    gleamRoot = "lib";
    gleamLibrary = true;
    gleamTarget = "javascript";
  };

  # gleam test compiles the rebar3 dependencies without gleamBuildPhase
  libraryCheckOnly = mkFixture {
    gleamRoot = "lib";
    gleamLibrary = true;
    dontUseGleamBuild = true;
    installPhase = ''
      touch $out
    '';
  };

  bumped = mkFixture {
    version = "1.1.0";
    src = bumpedSrc;
  };

  withManifest = mkFixture {
    src = bumpedSrc;
    manifest = ./fixture/app/manifest.toml;
  };

  # fetched with gleamFetchDeps
  hashed = mkFixture {
    gleamDepsHash = "sha256-dPS4MhHgq5r8Whw/K/tdECSD1+AnDsxmc0SbHJEHY58=";
  };

  # the source isn't read during evaluation, so it's never built
  hashedUnbuildable = mkFixture {
    src = testPkgs.runCommand "source" { } "exit 1";
    gleamDepsHash = "sha256-dPS4MhHgq5r8Whw/K/tdECSD1+AnDsxmc0SbHJEHY58=";
  };

  hashedWithManifest = mkFixture {
    gleamDepsHash = "sha256-dPS4MhHgq5r8Whw/K/tdECSD1+AnDsxmc0SbHJEHY58=";
    manifest = ./fixture/app/manifest.toml;
  };

  invalidTarget = mkFixture {
    gleamTarget = "wasm";
  };
in
# the dependencies don't change with the version or the sources
assert erlang.gleamDeps.outPath == bumped.gleamDeps.outPath;
assert erlang.gleamDeps.outPath == javascript.gleamDeps.outPath;
assert erlang.outPath != bumped.outPath;
assert erlang.gleamDeps.outPath == withManifest.gleamDeps.outPath;
assert !(builtins.tryEval invalidTarget.drvPath).success;
assert (builtins.tryEval hashedUnbuildable.drvPath).success;
assert !(builtins.tryEval hashedWithManifest.drvPath).success;
{
  mkGleamPackage-build = testPkgs.runCommand "mkGleamPackage-build" { } ''
    test "$(${erlang}/bin/fixture)" = "hello_from_dep"
    test "$(${javascript}/bin/fixture)" = "hello_from_dep"
    test "$(${bumped}/bin/fixture)" = "hello_from_dep"
    test "$(${hashed}/bin/fixture)" = "hello_from_dep"
    test -f ${library}/index.html
    test -f ${library}/fixture_lib.html
    test ! -e ${library}/bin
    test -f ${libraryJavascript}/fixture_lib.html
    test -f ${libraryCheckOnly}
    touch $out
  '';
}
