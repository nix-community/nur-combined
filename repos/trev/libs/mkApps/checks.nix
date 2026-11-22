{
  pkgs,
}:

let
  command =
    name:
    pkgs.writeShellScriptBin name ''
      printf '%s\n' ${pkgs.lib.escapeShellArg name}
    '';

  shellPackage = command "mkapps-shell-package";
  buildInput = command "mkapps-build-input";
  nativeBuildInput = command "mkapps-native-build-input";
  propagatedBuildInput = command "mkapps-propagated-build-input";
  propagatedNativeBuildInput = command "mkapps-propagated-native-build-input";
  explicitPackage = command "mkapps-explicit-package";
  legacyPackage = command "mkapps-legacy-package";

  # Multi-output packages: mkDerivation turns inputs into their `dev` output,
  # so mkApps has to find the binaries in `out` or `bin` instead.
  multiOutputPackage =
    name: outputs:
    pkgs.stdenvNoCC.mkDerivation {
      inherit name outputs;
      dontUnpack = true;
      installPhase = ''
        for output in $outputs; do
          mkdir -p "''${!output}"
        done
        install -D ${command name}/bin/${name} "''${!outputBin}/bin/${name}"
      '';
    };
  outDevPackage = multiOutputPackage "mkapps-out-dev-package" [
    "out"
    "dev"
  ];
  binDevPackage = multiOutputPackage "mkapps-bin-dev-package" [
    "bin"
    "out"
    "dev"
  ];

  devShell = pkgs.mkShell {
    packages = [
      shellPackage
      outDevPackage
      binDevPackage
    ];
    buildInputs = [ buildInput ];
    nativeBuildInputs = [ nativeBuildInput ];
    propagatedBuildInputs = [ propagatedBuildInput ];
    propagatedNativeBuildInputs = [ propagatedNativeBuildInput ];
  };

  apps = pkgs.mkApps {
    inputsFrom = {
      packages = [ explicitPackage ];
      inputsFrom = [ devShell ];
      script = ''
        test "$(mkapps-shell-package)" = mkapps-shell-package
        test "$(mkapps-out-dev-package)" = mkapps-out-dev-package
        test "$(mkapps-bin-dev-package)" = mkapps-bin-dev-package
        test "$(mkapps-build-input)" = mkapps-build-input
        test "$(mkapps-native-build-input)" = mkapps-native-build-input
        test "$(mkapps-propagated-build-input)" = mkapps-propagated-build-input
        test "$(mkapps-propagated-native-build-input)" = mkapps-propagated-native-build-input
        test "$(mkapps-explicit-package)" = mkapps-explicit-package
      '';
    };

    legacy = {
      packages = [ legacyPackage ];
      script = ''
        test "$(mkapps-legacy-package)" = mkapps-legacy-package
      '';
    };

    string = "true";
  };
in
{
  inputsFrom = pkgs.runCommand "mkApps-inputsFrom" { nativeBuildInputs = [ pkgs.gitMinimal ]; } ''
    mkdir repo
    cd repo
    git init --quiet

    ${apps.inputsFrom.program}
    ${apps.legacy.program}
    ${apps.string.program}

    touch $out
  '';
}
