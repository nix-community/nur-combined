{ lib
, stdenv
, runCommand
, writeTextFile
, writeShellScript
, nix
, smoke
, coreutils
}: {
  # Reads a given file (either drv, path or string) and returns it's sha256 hash
  hashFile = filename: builtins.hashString "sha256" (builtins.readFile filename);

  noSourceOptions = {
    sourceHashFunc = _: null;
    nodejs = null;
  };

  runTests = tests:
    let
      failures = lib.debug.runTests tests;
      msg = "Tests failed:\n" +
        lib.concatMapStringsSep "\n"
          (v: ''
            FAIL: ${v.name}
              expected: ${builtins.toJSON v.expected}
                   got: ${builtins.toJSON v.result}
          '')
          failures;
    in
    if builtins.length failures == 0 then [ ] else
    builtins.throw msg;

  # Takes an attribute set of tests
  # an creates a smoke file that executes them.
  # Each tests set has this format:
  # { description
  # , shell
  # , command
  # , expected
  # , (optional) expected-stderr
  # , (optional) status
  # , (optional) temporary-directory = true
  # , (optional) setup-command
  # }
  makeIntegrationTests = tests:
    let
      mkTestScript = name: test:
        let
          shellDrv = (test.shell.overrideAttrs (_: { phases = [ "noopPhase" ]; noopPhase = "touch $out"; })).drvPath;
          temporaryDirectory = test.temporary-directory or true;
        in
        writeShellScript name ''
          export PATH="${nix}/bin:${coreutils}/bin"
          set -e
          ${lib.optionalString temporaryDirectory ''
            WORKING_DIR=$(mktemp -d)
            function cleanup {
              rm -rf "$WORKING_DIR"
            }
            trap cleanup EXIT
            cd $WORKING_DIR
          ''}
          ${lib.optionalString (test ? setup-command) test.setup-command}
          ${if test.evalFailure or false then ''
            nix-shell --pure ${../.} -A tests.integration-tests.shells.${name} --run "exit 23"
          '' else ''
            nix-shell --pure ${shellDrv} --run "${writeShellScript "${name}-command" test.command}"
          ''}
        '';
      testScripts = lib.mapAttrs (name: test: test // { script = mkTestScript name test; inherit name; }) tests;

      smokeConfig.tests = map
        (test: {
          inherit (test) name;
          command = test.script;
          stdout = test.expected;
          exit-status = test.status or 0;
        } // lib.optionalAttrs (test ? expected-stderr) {
          stderr = test.expected-stderr;
        })
        (lib.attrValues testScripts);

      testScriptDir = writeTextFile {
        name = "smoke.yml";
        destination = "/smoke.yaml";
        text = builtins.toJSON smokeConfig;
      };
    in
    runCommand "tests"
      {
        name = "tests";
        text = ''
          #!${stdenv.shell}
          exec ${smoke}/bin/smoke ${testScriptDir}
        '';
        passthru = {
          shells = lib.mapAttrs (_: v: v.shell) testScripts;
        };
        passAsFile = [ "text" ];
      } ''
      cp $textPath $out
      chmod +x $out
    '';

  withoutNodeModules = src: lib.cleanSourceWith {
    filter = name: type: ! (type == "directory" && name == "node_modules");
    inherit src;
  };
}
