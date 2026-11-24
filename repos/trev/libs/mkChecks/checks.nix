{
  pkgs,
}:

let

  command =
    name:
    pkgs.writeShellScriptBin name ''
      printf '%s\n' ${pkgs.lib.escapeShellArg name}
    '';

  existingInput = command "mkchecks-existing-input";
  addedInput = command "mkchecks-added-input";

  source = pkgs.stdenvNoCC.mkDerivation {
    pname = "mkchecks-source";
    version = "1";
    src = pkgs.writeTextDir "fixture.txt" "fixture";
    nativeCheckInputs = [ existingInput ];

    dontBuild = true;

    installPhase = ''
      mkdir -p $out
      cp fixture.txt $out/
    '';
  };

  # build and install would fail if they ran, and dontBuild/dontInstall would skip the hooks and $out
  skipped = pkgs.stdenvNoCC.mkDerivation {
    pname = "mkchecks-skipped";
    version = "1";
    outputs = [
      "out"
      "dev"
    ];

    dontUnpack = true;
    dontBuild = true;
    dontInstall = true;

    preBuild = ''
      touch "$TMPDIR/pre-build-ran"
    '';

    buildPhase = ''
      exit 1
    '';

    installPhase = ''
      exit 1
    '';
  };

  # no build platform can run windows binaries, so nixpkgs would force doCheck off
  cross = pkgs.pkgsCross.mingw-msvcrt-x86_64.stdenvNoCC.mkDerivation {
    pname = "mkchecks-cross";
    version = "1";
    src = pkgs.writeTextDir "fixture.txt" "fixture";
    nativeCheckInputs = [ existingInput ];

    dontBuild = true;

    installPhase = ''
      touch $out
    '';
  };

  direct = pkgs.stdenvNoCC.mkDerivation {
    pname = "mkchecks-direct";
    version = "1";

    dontUnpack = true;
    doCheck = true;
    doInstallCheck = true;

    checkPhase = ''
      touch checked
    '';

    installPhase = ''
      test -e checked
      mkdir -p $out
      touch $out/installed
    '';

    installCheckPhase = ''
      test -e checked
      test -e $out/installed
    '';
  };

  checks = pkgs.mkChecks {
    script-only = {
      packages = [ (command "mkchecks-script-only-command") ];
      script = ''
        test "$(mkchecks-script-only-command)" = mkchecks-script-only-command
        test -d "$HOME"
        test "$TREEFMT_TREE_ROOT" = "$PWD"
      '';
    };

    fileset-order = {
      root = ../..;
      files = [
        ./default.nix
        ../mkImage/default.nix
      ];
      filter = file: file.hasExt "nix";
      ignore = [ ../mkImage/default.nix ];
      include = [ ../../README.md ];
      script = ''
        test "''${file#/}" != "$file"

        case "$file" in
          "$PWD/libs/mkChecks/default.nix") touch "$TMPDIR/seen-mkChecks" ;;
          "$PWD/README.md") touch "$TMPDIR/seen-README" ;;
          *) echo "unexpected file: $file" >&2; exit 1 ;;
        esac
      '';
      postCheck = ''
        test -e "$TMPDIR/seen-mkChecks"
        test -e "$TMPDIR/seen-README"
      '';
    };

    src-derivation = {
      src = source;
      packages = [ addedInput ];
      script = ''
        test "$(mkchecks-existing-input)" = mkchecks-existing-input
        test "$(mkchecks-added-input)" = mkchecks-added-input
        test "$(cat fixture.txt)" = fixture
      '';
    };

    src-derivation-skipped = {
      src = skipped;
      env.MKCHECKS_ENV = "env";
      preCheck = ''
        export MKCHECKS_PRE_CHECK=pre-check
      '';
      script = ''
        test -e "$TMPDIR/pre-build-ran"
        test "$MKCHECKS_ENV" = env
        test "$MKCHECKS_PRE_CHECK" = pre-check
      '';
    };

    src-derivation-cross = {
      src = cross;
      packages = [ addedInput ];
      script = ''
        test "$(mkchecks-existing-input)" = mkchecks-existing-input
        test "$(mkchecks-added-input)" = mkchecks-added-input
        test "$(cat fixture.txt)" = fixture
        touch "$TMPDIR/cross-checked"
      '';
      postCheck = ''
        test -e "$TMPDIR/cross-checked"
      '';
    };

    direct-derivation = direct;

    # prefixed with the group name: group-file-script, group-file-derivation
    group-file = ./group-file.nix;

    # resolves to group-dir/checks.nix, which nests another group
    group-dir = ./group-dir;

    group-args = pkgs.callChecks ./group-args.nix { message = "hello"; };
  };

  # mkCheck builds a single check without mkChecks
  individual = pkgs.mkCheck "mkCheck-individual" {
    packages = [ (command "mkcheck-individual-command") ];
    script = ''
      test "$(mkcheck-individual-command)" = mkcheck-individual-command
    '';
  };

  # names are flattened, so a group can collide with another check
  collision = pkgs.mkChecks {
    group-script.script = "true";
    group = ./group-dir;
  };

  # a skipped check would pass, so make sure a failing script fails the cross build
  crossFailure =
    pkgs.testers.testBuildFailure
      (pkgs.mkChecks {
        src-derivation-cross-failure = {
          src = cross;
          script = ''
            echo mkchecks-cross-script-ran
            false
          '';
        };
      }).src-derivation-cross-failure;

  # tryEval drops error messages, so evaluate a broken check with nix-instantiate to read the trace
  errorContextExpr = pkgs.writeText "mkchecks-error-context.nix" ''
    let
      lib = import ${pkgs.path + "/lib"};
      mkChecks = import ${./default.nix} {
        inherit lib;
        mkCheck = name: check: check;
        callChecks = throw "callChecks is not used";
      };
    in
    builtins.attrNames (mkChecks {
      working.script = "true";
      broken = throw "mkchecks-broken-check";
    })
  '';
in
# derivations are passed through untouched so their hashes match the packages
assert checks.direct-derivation.outPath == direct.outPath;
assert
  builtins.attrNames checks == [
    "direct-derivation"
    "fileset-order"
    "group-args-script"
    "group-dir-nested-args-script"
    "group-dir-script"
    "group-file-derivation"
    "group-file-script"
    "script-only"
    "src-derivation"
    "src-derivation-cross"
    "src-derivation-skipped"
  ];
# checks built by mkChecks are named after their prefixed name, derivations keep theirs
assert checks.group-file-script.name == "group-file-script";
assert checks.group-file-derivation.name == "mkchecks-group-file-derivation";
assert !(builtins.tryEval collision.group-script).success;
assert individual.name == "mkCheck-individual";
checks
// {
  inherit individual;

  src-derivation-cross-failure = pkgs.runCommand "mkChecks-src-derivation-cross-failure" { } ''
    grep -F mkchecks-cross-script-ran ${crossFailure}/testBuildFailure.log
    touch $out
  '';

  error-context =
    pkgs.runCommand "mkChecks-error-context"
      {
        nativeBuildInputs = [ pkgs.nix ];
      }
      ''
        # a private store, so nix-instantiate doesn't need the daemon or /nix/var
        export HOME="$TMPDIR"
        export NIX_STORE_DIR="$TMPDIR/store"
        export NIX_STATE_DIR="$TMPDIR/state"
        export NIX_LOG_DIR="$TMPDIR/log"
        export NIX_CONF_DIR="$TMPDIR/etc"

        if nix-instantiate --eval --strict --show-trace ${errorContextExpr} 2>error.log; then
          echo "expected listing the check names to fail" >&2
          exit 1
        fi

        cat error.log >&2
        grep -F mkchecks-broken-check error.log
        grep -F "while checking whether check 'broken' is a check group (mkChecks evaluates every check value to list check names)" error.log
        touch $out
      '';
}
