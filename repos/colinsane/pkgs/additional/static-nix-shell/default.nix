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
  pkgs' = pkgs;
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
    srcRoot ? null,
    extraMakeWrapperArgs ? [],
    ...
  }@attrs:
  let
    extraDerivArgs = lib.optionalAttrs (srcRoot != null) {
      # use can use `srcRoot` instead of `src` in most scenarios, to avoid include the entire directory containing their
      # source file in the closure, but *just* the source file itself.
      # `lib.fileset` docs: <https://ryantm.github.io/nixpkgs/functions/library/fileset/>
      src = lib.fileset.toSource {
        root = srcRoot; fileset = lib.path.append srcRoot srcPath;
      };
    };
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
      preferLocalBuild = true;

      nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [
        makeWrapper
      ];

      makeWrapperArgs = [
        "--suffix" "PATH" ":" (lib.makeBinPath pkgsEnv')
      ] ++ extraMakeWrapperArgs;

      patchPhase = ''
        substituteInPlace ${srcPath} \
          --replace-fail '#!/usr/bin/env nix-shell' '#!${interpreter}' \
          --replace-fail \
            '#!nix-shell -i ${interpreterName}${pkgsStr}' \
            '# nix deps evaluated statically'
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        mv ${srcPath} $out/bin/${srcPath}

        # ensure that all nix-shell references were substituted
        (! grep '#![ \t]*nix-shell' $out/bin/${srcPath}) || exit 1

      '' + lib.optionalString doWrap ''
        # add runtime dependencies to PATH
        wrapProgram $out/bin/${srcPath} \
          ${lib.escapeShellArgs final.makeWrapperArgs}
      '' + ''

        runHook postInstall
      '';
      meta = {
        mainProgram = srcPath;
      } // (attrs.meta or {});
    } // extraDerivArgs // (removeAttrs attrs [
      "extraMakeWrapperArgs"
      "interpreter"
      "interpreterName"
      "meta"
      "nativeBuildInputs"
      "pkgExprs"
      "pkgsEnv"
      "srcPath"
    ])
  );

  # `mkShell` specialization for `nix-shell -i bash` scripts.
  mkBash = { pname, pkgs ? {}, ...}@attrs:
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
  mkZsh = { pname, pkgs ? {}, ...}@attrs:
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
  mkPython3Bin = { pname, pkgs ? {}, pyPkgs ? {}, ... }@attrs:
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
