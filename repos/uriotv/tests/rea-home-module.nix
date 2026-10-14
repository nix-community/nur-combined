let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;

  evaluate =
    settings:
    (lib.evalModules {
      modules = [
        (import ../modules/home-manager/rea.nix)
        ({ lib, ... }: {
          options.home.packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
          };
          options.home.sessionVariables = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
          };
          options.assertions = lib.mkOption {
            type = lib.types.listOf lib.types.attrs;
            default = [ ];
          };
          config.programs.rea = settings;
        })
      ];
      specialArgs = { inherit pkgs; };
    }).config;

  bare = evaluate { enable = true; };
  ghidra = evaluate {
    enable = true;
    ghidra.enable = true;
  };
  allFreeTools = evaluate {
    enable = true;
    freeTools.enable = true;
  };
  selectedTools = evaluate {
    enable = true;
    freeTools.binwalk.enable = true;
    freeTools.chromium.enable = false;
  };

  hasPackage = config: pname: lib.any (package: (package.pname or "") == pname) config.home.packages;

  checks = {
    bareCliOnly =
      bare.home.packages == [ bare.programs.rea.package ] && bare.home.sessionVariables == { };
    ghidraAddsCliAndConfiguration =
      hasPackage ghidra "ghidra"
      && ghidra.home.sessionVariables.GHIDRA_INSTALL_DIR == "${pkgs.ghidra}/lib/ghidra"
      && ghidra.home.sessionVariables.REA_ANALYSIS_PROVIDER == "auto";
    freeToolsBundleIncludesExpectedPackages =
      builtins.all (pname: hasPackage allFreeTools pname) [
        "chromium"
        "android-tools"
        "apktool"
        "ilspycmd"
        "binwalk"
        "unblob"
        "mitmproxy"
        "rea-wakaru"
        "rea-pwndbg"
        "util-linux"
      ]
      && !hasPackage allFreeTools "ghidra"
      && allFreeTools.home.sessionVariables ? REA_JADX_MCP_JAR
      && allFreeTools.home.sessionVariables ? REA_PWNTOOLS_PYTHON;
    individualSwitchesInstallOnlySelectedTools =
      hasPackage selectedTools "binwalk"
      && hasPackage selectedTools "util-linux"
      && !hasPackage selectedTools "chromium"
      && selectedTools.home.sessionVariables ? REA_BINWALK_COMMAND
      && !(selectedTools.home.sessionVariables ? REA_BROWSER_EXECUTABLE);
    platformAssertionsPass =
      builtins.all (assertion: assertion.assertion) allFreeTools.assertions
      && builtins.all (assertion: assertion.assertion) selectedTools.assertions;
  };
in
assert builtins.all (check: check) (builtins.attrValues checks);
checks
