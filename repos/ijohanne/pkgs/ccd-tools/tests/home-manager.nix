{ pkgs }:
let
  inherit (pkgs) lib;
  # A nonexistent runtime secret path verifies the wrapper never reads it at build time.
  accountsFile = "/run/secrets/ccd accounts'file.csv";
  probe = name: pkgs.writeShellScriptBin name ''
    printf '%s\n' "$CCD_TOOLS_ACCOUNTS"
  '';
  probePackage = pkgs.symlinkJoin {
    name = "ccd-tools-wrapper-probe";
    paths = [ (probe "ccd-status") (probe "ccd-future-command") ];
  };
  evaluate = extra: lib.evalModules {
    specialArgs = { inherit pkgs; };
    modules = [
      ../../../home-manager/ccd-tools.nix
      ({ lib, ... }: {
        options.home.packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
        };
      })
      extra
    ];
  };
  enabled = evaluate {
    programs.ccd-tools = {
      enable = true;
      package = probePackage;
      inherit accountsFile;
    };
  };
  wrapped = lib.head enabled.config.home.packages;
  disabled = evaluate { };
  defaultPackage = (evaluate {
    programs.ccd-tools = { enable = true; inherit accountsFile; };
  }).config.programs.ccd-tools.package;
in
assert disabled.config.home.packages == [ ];
assert defaultPackage.pname == "ccd-tools";
pkgs.runCommand "ccd-tools-home-manager-check" { } ''
  unset CCD_TOOLS_ACCOUNTS
  for command in ccd-status ccd-future-command; do
    test "$(${wrapped}/bin/$command)" = ${lib.escapeShellArg accountsFile}
    test "$(CCD_TOOLS_ACCOUNTS=/override.csv ${wrapped}/bin/$command)" = /override.csv
  done
  touch "$out"
''
