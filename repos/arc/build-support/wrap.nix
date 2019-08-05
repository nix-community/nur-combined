{ self, ... }:
let builders = {
  wrapShellScriptBin = { stdenvNoCC, makeWrapper, bash, lib }: name: src: {
    depsRuntimePath ? [], buildInputs ? [],
    ...
  } @env: let
    env' = builtins.removeAttrs env ["depsRuntimePath" "buildInputs"];
  in lib.drvExec "bin/${name}" (stdenvNoCC.mkDerivation ({
    inherit name src;
    source = src;
    nativeBuildInputs = [bash makeWrapper];
    buildInputs = buildInputs ++ depsRuntimePath;
    shouldWrap = if builtins.length depsRuntimePath > 0 then "true" else "false";
    wrapperPath = lib.makeBinPath depsRuntimePath;
    configurePhase = "true";
    buildPhase = "true";
    unpackPhase = "true";
    installPhase = ''
      install -Dm0755 $source $out/bin/$name
      if $shouldWrap; then
        wrapProgram $out/bin/$name --prefix PATH : $wrapperPath
      fi
    '';
    checkPhase = ''
      if [[ -f $out/bin/.$name-wrapped ]]; then
        bash -n $out/bin/.$name-wrapped
      fi
      bash -n $out/bin/$name
    '';
  } // env'));
  substituteShellScriptBin = { wrapShellScriptBin }: name: src: env:
    wrapShellScriptBin name src ({
      source = "${name}.sub";
      buildPhase = ''
        substituteAll $src $source
      '';
    } // env);
  # TODO COME ON THIS IS JUST substituteAll isn't it???
  substituteFile = { stdenvNoCC, lib }: name: src: env: let
    pkg = stdenvNoCC.mkDerivation ({
      inherit name src;
      configurePhase = "true";
      buildPhase = ''
        substituteAll $src $name
      '';
      unpackPhase = "true";
      installPhase = ''
        install -Dm0644 $name $out
      '';
      checkPhase = "true";
    } // env);
    in
    pkg;
}; in builtins.mapAttrs (_: p: self.callPackage p { }) builders
