{ self, super, ... }: with self; builtins.mapAttrs (_: f: { }: f) {
  writeShellScriptBin = name: contents:
    lib.drvExec "bin/${name}" (super.writeShellScriptBin name contents);
  writeShellScript = name: contents:
    lib.drvExec "" (super.writeShellScript name contents);
  nixRunner = { binName }: stdenvNoCC.mkDerivation {
    preferLocalBuild = true;
    allowSubstitutes = false;
    name = "nix-run-wrapper-${builtins.baseNameOf (builtins.unsafeDiscardStringContext binName)}";
    defaultCommand = "bash"; # `nix run` execvp's bash by default
    inherit binName;
    inherit runtimeShell;
    passAsFile = [ "buildCommand" "script" ];
    buildCommand = ''
      mkdir -p $out/bin
      substituteAll $scriptPath $out/bin/$defaultCommand
      chmod +x $out/bin/$defaultCommand
      ln -s $out/bin/$defaultCommand $out/bin/run
    '';
    script = ''
      #!@runtimeShell@
      set -eu

      if [[ -n ''${CI_NO_RUN-} ]]; then
        # escape hatch
        exec bash "$@"
      fi

      # also bail out if we're not called via `nix run`
      #PPID=($(@ps@/bin/ps -o ppid= $$))
      #if [[ $(readlink /proc/$PPID/exe) = */nix ]]; then
      #  exec bash "$@"
      #fi

      IFS=: PATHS=($PATH)
      join_path() {
        local IFS=:
        echo "$*"
      }

      # remove us from PATH
      OPATH=()
      for p in "''${PATHS[@]}"; do
        if [[ $p != @out@/bin ]]; then
          OPATH+=("$p")
        fi
      done
      export PATH=$(join_path "''${OPATH[@]}")

      exec @binName@ "$@" ''${CI_RUN_ARGS-}
    '';
  };
  nixRunWrapper = {
    package,
    binName ? package.exec
  }: stdenvNoCC.mkDerivation {
    name = "nix-run-${builtins.baseNameOf (builtins.unsafeDiscardStringContext binName)}";
    preferLocalBuild = true;
    allowSubstitutes = false;
    wrapper = nixRunner { inherit binName; };
    inherit package;
    buildCommand = ''
      mkdir -p $out/nix-support
      echo $package $wrapper > $out/nix-support/propagated-user-env-packages
      if [[ -e $package/bin ]]; then
        ln -s $package/bin $out/bin
      fi
    '';
    meta = package.meta or {};
    passthru = package.passthru or {};
  };
}
