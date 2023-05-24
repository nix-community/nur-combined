{ pkgs
, lib
, makeWrapper
, python3
, stdenv
}:

let
  inherit (builtins) attrNames attrValues concatStringsSep foldl' map typeOf;
  inherit (lib) concatMapAttrs;
  pkgs' = pkgs;
  # create an attrset of
  #   <name> = expected string in the nix-shell invocation
  #   <value> = package to provide
  pkgsToAttrs = prefix: pkgSet: expr: ({
    "lambda" = expr: pkgsToAttrs prefix pkgSet (expr pkgSet);
    "list" = expr: foldl' (acc: pname: acc // {
      "${prefix + pname}" = pkgSet."${pname}";
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
    ...
  }@attrs:
  let
    pkgsStr = concatStringsSep "" (map
      (pname: " -p ${pname}")
      pkgExprs
    );
  in
    stdenv.mkDerivation ({
      version = "0.1.0";  # default version
      patchPhase = ''
        substituteInPlace ${srcPath} \
          --replace '#!/usr/bin/env nix-shell' '#!${interpreter}' \
          --replace \
            '#!nix-shell -i ${interpreterName}${pkgsStr}' \
            '# nix deps evaluated statically'
      '';
      nativeBuildInputs = [ makeWrapper ];
      installPhase = ''
        mkdir -p $out/bin
        mv ${srcPath} $out/bin/${srcPath}

        # ensure that all nix-shell references were substituted
        (! grep nix-shell $out/bin/${srcPath}) || exit 1

        # add runtime dependencies to PATH
        wrapProgram $out/bin/${srcPath} \
          --suffix PATH : ${lib.makeBinPath pkgsEnv }
      '';
    } // (removeAttrs attrs [ "interpreter" "interpreterName" "pkgsEnv" "pkgExprs" "srcPath" ])
  );

  # `mkShell` specialization for `nix-shell -i bash` scripts.
  mkBash = { pname, pkgs ? {}, srcPath ? pname, ...}@attrs:
    let
      pkgsAsAttrs = pkgsToAttrs "" pkgs' pkgs;
      pkgsEnv = attrValues pkgsAsAttrs;
      pkgExprs = attrNames pkgsAsAttrs;
    in mkShell ({
      inherit pkgsEnv pkgExprs;
      interpreter = "${pkgs'.bash}/bin/bash";
    } // (removeAttrs attrs [ "pkgs" ])
  );

  # `mkShell` specialization for invocations of `nix-shell -p "python3.withPackages (...)"`
  # pyPkgs argument is parsed the same as pkgs, except that names are assumed to be relative to `"ps"` if specified in list form.
  mkPython3Bin = { pname, pkgs ? {}, pyPkgs ? {}, srcPath ? pname, ... }@attrs:
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
    } // (removeAttrs attrs [ "pkgs" "pyPkgs" ])
  );
}
