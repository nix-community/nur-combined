{ pkgs
, bash
, lib
, makeWrapper
, python3
, stdenv
, zsh
}:

let
  inherit (builtins) attrNames attrValues concatStringsSep foldl' map typeOf;
  inherit (lib) concatMapAttrs;
  bash' = bash;
  pkgs' = pkgs;
  python3' = python3;
  zsh' = zsh;
  # create an attrset of
  #   <name> = expected string in the nix-shell invocation
  #   <value> = package to provide
  pkgsToAttrs = prefix: pkgSet: expr: ({
    # branch based on the type of `expr`
    "lambda" = expr: pkgsToAttrs prefix pkgSet (expr pkgSet);
    "list" = expr: foldl' (acc: pname: acc // {
      "${prefix + pname}" = lib.getAttrFromPath (lib.splitString "." pname) pkgSet;
    }) {} expr;
    "set" = expr: expr;
  })."${typeOf expr}" expr;
in rec {
  # transform a file which uses `#!/usr/bin/env nix-shell` shebang
  # into a derivation that can be built statically.
  #
  # pkgs may take the following form:
  # - [ "pkgNameA" "pkgNameB" ... ]
  # - { pkgNameA = pkgValueA; pkgNameB = pkgValueB; ... }
  # - ps: <evaluate to one of the above exprs>
  mkShell = {
    pname,
    interpreter,
    interpreterName ? lib.last (builtins.split "/" interpreter),
    pkgsEnv,
    pkgExprs,
    srcPath ? pname,
    extraMakeWrapperArgs ? [],
    ...
  }@attrs:
  let
    pkgsStr = concatStringsSep "" (map
      (pname: " -p ${pname}")
      pkgExprs
    );
    # allow any package to be a list of packages, to support things like
    # -p python3Packages.foo.propagatedBuildInputs
    pkgsEnv' = lib.flatten pkgsEnv;
    doWrap = pkgsEnv' != [];
  in
    stdenv.mkDerivation (final: {
      version = "0.1.0";  # default version
      patchPhase = ''
        substituteInPlace ${srcPath} \
          --replace '#!/usr/bin/env nix-shell' '#!${interpreter}' \
          --replace \
            '#!nix-shell -i ${interpreterName}${pkgsStr}' \
            '# nix deps evaluated statically'
      '';
      nativeBuildInputs = [ makeWrapper ];
      makeWrapperArgs = [
        "--suffix" "PATH" ":" (lib.makeBinPath pkgsEnv')
      ] ++ extraMakeWrapperArgs;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        mv ${srcPath} $out/bin/${srcPath}

        # ensure that all nix-shell references were substituted
        (! grep nix-shell $out/bin/${srcPath}) || exit 1

      '' + lib.optionalString doWrap ''
        # add runtime dependencies to PATH
        wrapProgram $out/bin/${srcPath} \
          ${lib.escapeShellArgs final.makeWrapperArgs}
      '' + ''

        runHook postInstall
      '';
    } // (removeAttrs attrs [ "extraMakeWrapperArgs" "interpreter" "interpreterName" "pkgsEnv" "pkgExprs" "srcPath" ])
  );

  # `mkShell` specialization for `nix-shell -i bash` scripts.
  mkBash = { pname, pkgs ? {}, srcPath ? pname, bash ? bash', ...}@attrs:
    let
      pkgsAsAttrs = pkgsToAttrs "" pkgs' pkgs;
      pkgsEnv = attrValues pkgsAsAttrs;
      pkgExprs = attrNames pkgsAsAttrs;
    in mkShell ({
      inherit pkgsEnv pkgExprs;
      interpreter = "${bash}/bin/bash";
    } // (removeAttrs attrs [ "bash" "pkgs" ])
  );

  # `mkShell` specialization for `nix-shell -i zsh` scripts.
  mkZsh = { pname, pkgs ? {}, srcPath ? pname, zsh ? zsh', ...}@attrs:
    let
      pkgsAsAttrs = pkgsToAttrs "" pkgs' pkgs;
      pkgsEnv = attrValues pkgsAsAttrs;
      pkgExprs = attrNames pkgsAsAttrs;
    in mkShell ({
      inherit pkgsEnv pkgExprs;
      interpreter = "${zsh}/bin/zsh";
    } // (removeAttrs attrs [ "pkgs" "zsh" ])
  );

  # `mkShell` specialization for invocations of `nix-shell -p "python3.withPackages (...)"`
  # pyPkgs argument is parsed the same as pkgs, except that names are assumed to be relative to `"ps"` if specified in list form.
  # TODO: rename to `mkPython3` for consistency with e.g. `mkBash`
  mkPython3Bin = { pname, pkgs ? {}, pyPkgs ? {}, srcPath ? pname, python3 ? python3', ... }@attrs:
    let
      pyEnv = python3.withPackages (ps: attrValues (
        pkgsToAttrs "ps." ps pyPkgs
      ));
      pyPkgsStr = concatStringsSep " " (attrNames (
        pkgsToAttrs "ps." {} pyPkgs
      ));

      pkgsAsAttrs = pkgsToAttrs "" pkgs' pkgs;
      pkgsEnv = attrValues pkgsAsAttrs;
      pkgExprs = [
        "\"python3.withPackages (ps: [ ${pyPkgsStr} ])\""
      ] ++ (attrNames pkgsAsAttrs);
    in mkShell ({
      inherit pkgsEnv pkgExprs;
      interpreter = pyEnv.interpreter;
      interpreterName = "python3";
    } // (removeAttrs attrs [ "pkgs" "pyPkgs" "python3" ])
  );
}
