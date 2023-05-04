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
in {
  # transform a file which uses `#!/usr/bin/env nix-shell` shebang with a `python3` interpreter
  # into a derivation that can be built statically.
  #
  # pkgs and pyPkgs may take the following form:
  # - [ "pkgNameA" "pkgNameB" ... ]
  # - { pkgNameA = pkgValueA; pkgNameB = pkgValueB; ... }
  # - ps: <evaluate to one of the above exprs>
  #
  # for pyPkgs, names are assumed to be relative to `"ps"` if specified in list form.
  mkPython3Bin = { pname, pkgs ? {}, pyPkgs ? {}, srcPath ? pname, ... }@attrs:
    let
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
      pyEnv = python3.withPackages (ps: attrValues (
        pkgsToAttrs "ps." ps pyPkgs
      ));
      pyPkgsStr = concatStringsSep " " (attrNames (
        pkgsToAttrs "ps." {} pyPkgs
      ));

      pkgsAsAttrs = pkgsToAttrs "" pkgs' pkgs;
      pkgsEnv = attrValues pkgsAsAttrs;
      pkgsStr = concatStringsSep "" (map
        (pname: " -p ${pname}")
        (attrNames pkgsAsAttrs)
      );
    in stdenv.mkDerivation ({
      version = "0.1.0";  # default version
      patchPhase = ''
        substituteInPlace ${srcPath} \
          --replace '#!/usr/bin/env nix-shell' '#!${pyEnv.interpreter}' \
          --replace \
            '#!nix-shell -i python3 -p "python3.withPackages (ps: [ ${pyPkgsStr} ])"${pkgsStr}' \
            '# nix deps evaluated statically'
      '';
      nativeBuildInputs = [ makeWrapper ];
      installPhase = ''
        mkdir -p $out/bin
        mv ${srcPath} $out/bin/${srcPath}

        # ensure that all nix-shell references were substituted
        ! grep nix-shell $out/bin/${srcPath}

        # add runtime dependencies to PATH
        wrapProgram $out/bin/${srcPath} \
          --suffix PATH : ${lib.makeBinPath pkgsEnv }
      '';
    } // (removeAttrs attrs [ "pkgs" "pyPkgs" "srcPath" ])
  );
}
