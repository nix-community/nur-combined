{
  pkgs,
  self,
}:

let
  existingInput = pkgs.writeShellScriptBin "deno-existing-input" ''
    printf '%s\n' deno-existing-input
  '';

  deno =
    pkgs.writeShellScriptBin "deno" ''
      printf '%s\n' "$@" > "$TMPDIR/deno-args"

      target=
      output=
      while [ "$#" -gt 0 ]; do
        case "$1" in
          --target)
            target=$2
            shift 2
            ;;
          --output)
            output=$2
            shift 2
            ;;
          *) shift ;;
        esac
      done

      test -n "$target"
      test -n "$output"
      test -f "$DENO_DIR/dl/release/v2.6.5/denort-$target.zip"

      mkdir -p "$(dirname "$output")"
      cp "$TMPDIR/deno-args" "$output"
      chmod +x "$output"
    ''
    // {
      version = "2.6.5";
    };

  denoCompile = import ../../libs/denoCompile {
    inherit (pkgs) lib jq;
    inherit deno;
    fetchurl = args: pkgs.writeText "denort-${builtins.baseNameOf args.url}" args.url;
  };

  mkSource =
    name: script:
    pkgs.runCommand "${name}-source" { } ''
      mkdir -p $out
      ${script}
    '';

  mkPackage =
    pname: src:
    pkgs.stdenvNoCC.mkDerivation {
      inherit pname src;
      version = "1";
      nativeBuildInputs = [ existingInput ];

      dontBuild = true;

      preInstall = ''
        test "$(deno-existing-input)" = deno-existing-input
      '';

      installPhase = ''
        mkdir -p $out
      '';

      meta.description = "preserved metadata";
    };

  packageMain = mkPackage "deno-package-main" (
    mkSource "deno-package-main" ''
      cat > $out/package.json <<'EOF'
      { "main": "src/main.ts" }
      EOF
      mkdir -p $out/src
      touch $out/src/main.ts
    ''
  );

  buildIndex = mkPackage "deno-build-index" (
    mkSource "deno-build-index" ''
      printf '%s\n' '{}' > $out/package.json
      mkdir -p $out/build
      touch $out/build/index.js
    ''
  );

  explicitWindows = mkPackage "deno-explicit-windows" (
    mkSource "deno-explicit-windows" ''
      touch $out/explicit.ts
    ''
  );

  compiledPackageMain = denoCompile {
    package = packageMain;
  };

  compiledBuildIndex = denoCompile {
    package = buildIndex;
  };

  compiledExplicitWindows = denoCompile {
    package = explicitWindows;
    target = "x86_64-pc-windows-msvc";
    entrypoint = "explicit.ts";
    allow-read = false;
    allow-write = false;
    allow-net = false;
    allow-env = false;
    allow-run = false;
  };
in
{
  denoCompile-package-main =
    assert !compiledPackageMain.doCheck;
    assert compiledPackageMain.meta.description == "preserved metadata";
    assert compiledPackageMain.meta.mainProgram == "deno-package-main";
    pkgs.runCommand "denoCompile-package-main" { } ''
      output=${compiledPackageMain}/bin/deno-package-main
      test -x "$output"
      grep --fixed-strings --line-regexp compile "$output"
      grep --fixed-strings --line-regexp -- --no-check "$output"
      grep --fixed-strings --line-regexp -- --allow-read "$output"
      grep --fixed-strings --line-regexp -- --allow-write "$output"
      grep --fixed-strings --line-regexp -- --allow-net "$output"
      grep --fixed-strings --line-regexp -- --allow-env "$output"
      grep --fixed-strings --line-regexp -- --allow-run "$output"
      grep --fixed-strings --line-regexp x86_64-unknown-linux-gnu "$output"
      grep --fixed-strings --line-regexp src/main.ts "$output"
      grep --fixed-strings --line-regexp "$output" "$output"
      touch $out
    '';

  denoCompile-build-index = pkgs.runCommand "denoCompile-build-index" { } ''
    output=${compiledBuildIndex}/bin/deno-build-index
    test -x "$output"
    grep --fixed-strings --line-regexp build/index.js "$output"
    touch $out
  '';

  denoCompile-explicit-windows =
    assert compiledExplicitWindows.meta.mainProgram == "deno-explicit-windows.exe";
    pkgs.runCommand "denoCompile-explicit-windows" { } ''
      output=${compiledExplicitWindows}/bin/deno-explicit-windows.exe
      test -x "$output"
      grep --fixed-strings --line-regexp x86_64-pc-windows-msvc "$output"
      grep --fixed-strings --line-regexp explicit.ts "$output"
      grep --fixed-strings --line-regexp -- --deny-read "$output"
      grep --fixed-strings --line-regexp -- --deny-write "$output"
      grep --fixed-strings --line-regexp -- --deny-net "$output"
      grep --fixed-strings --line-regexp -- --deny-env "$output"
      grep --fixed-strings --line-regexp -- --deny-run "$output"
      touch $out
    '';
}
