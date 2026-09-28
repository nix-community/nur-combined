{
  pkgs,
  self,
}:

let
  testPkgs = pkgs.extend self.overlays.libs;

  command =
    name:
    testPkgs.writeShellScriptBin name ''
      printf '%s\n' ${testPkgs.lib.escapeShellArg name}
    '';

  existingInput = command "mkchecks-existing-input";
  addedInput = command "mkchecks-added-input";

  source = testPkgs.stdenvNoCC.mkDerivation {
    pname = "mkchecks-source";
    version = "1";
    src = testPkgs.writeTextDir "fixture.txt" "fixture";
    nativeCheckInputs = [ existingInput ];

    dontBuild = true;

    installPhase = ''
      mkdir -p $out
      cp fixture.txt $out/
    '';
  };

  # build and install would fail if they ran, and dontBuild/dontInstall would skip the hooks and $out
  skipped = testPkgs.stdenvNoCC.mkDerivation {
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

  direct = testPkgs.stdenvNoCC.mkDerivation {
    pname = "mkchecks-direct";
    version = "1";

    dontUnpack = true;

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

  checks = testPkgs.mkChecks {
    mkChecks-script-only = {
      packages = [ (command "mkchecks-script-only-command") ];
      script = ''
        test "$(mkchecks-script-only-command)" = mkchecks-script-only-command
        test -d "$HOME"
        test "$TREEFMT_TREE_ROOT" = "$PWD"
      '';
    };

    mkChecks-fileset-order = {
      root = ../..;
      files = [
        ../../libs/mkChecks/default.nix
        ../../libs/mkImage/default.nix
      ];
      filter = file: file.hasExt "nix";
      ignore = [ ../../libs/mkImage/default.nix ];
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

    mkChecks-src-derivation = {
      src = source;
      packages = [ addedInput ];
      script = ''
        test "$(mkchecks-existing-input)" = mkchecks-existing-input
        test "$(mkchecks-added-input)" = mkchecks-added-input
        test "$(cat fixture.txt)" = fixture
      '';
    };

    mkChecks-src-derivation-skipped = {
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

    mkChecks-direct-derivation = direct;
  };
in
assert checks.mkChecks-direct-derivation.doCheck;
assert checks.mkChecks-direct-derivation.doInstallCheck;
checks
