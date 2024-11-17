{
  pkgs,
  bash,
  lib,
  makeBinaryWrapper,
  python3,
  stdenv,
  zsh,
}:

let
  # insert an element `ins` into a list `into`,
  # at its proper location assuming `into` is lexicographically ordered.
  # does not adjust the order of existing elements.
  insertTopo = ins: into: let
    insertedUnlessLast = builtins.foldl' (acc: next:
      if builtins.elem ins acc then
        acc ++ [ next ]
      else if (lib.naturalSort [ ins next ]) == [ ins next ] then
        acc ++ [ ins next ]
      else
        acc ++ [ next ]
    ) [] into
    ;
  in
    if builtins.elem ins insertedUnlessLast then
      insertedUnlessLast
    else
      into ++ [ ins ]
    ;
  pkgs' = pkgs;
  # create an attrset of
  #   <name> = expected string in the nix-shell invocation
  #   <value> = package to provide
  pkgsToAttrs = prefix: pkgSet: expr: {
    # branch based on the type of `expr`
    "lambda" = expr: pkgsToAttrs prefix pkgSet (expr pkgSet);
    "list" = expr: builtins.foldl' (acc: pname: acc // {
      "${prefix + pname}" = lib.getAttrFromPath (lib.splitString "." pname) pkgSet;
    }) {} expr;
    "set" = expr: expr;
  }."${builtins.typeOf expr}" expr;
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
    pkgsStr = builtins.concatStringsSep "" (builtins.map
      (pname: " -p ${pname}")
      pkgExprs
    );
    # allow any package to be a list of packages, to support things like
    # -p python3.pkgs.foo.propagatedBuildInputs
    pkgsEnv' = lib.flatten pkgsEnv;

    makeWrapperArgs = lib.optionals (pkgsEnv' != []) [
      "--suffix" "PATH" ":" (lib.makeBinPath pkgsEnv')
    ] ++ extraMakeWrapperArgs;
    doWrap = makeWrapperArgs != [];
  in
    stdenv.mkDerivation (final: {
      version = "0.1.0";  # default version
      preferLocalBuild = true;

      nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [
        makeBinaryWrapper
      ];

      inherit makeWrapperArgs;

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

        die() {
          echo "$@"
          exit 1
        }
        # ensure that all nix-shell references were substituted
        (! grep '#![ \t]*nix-shell' $out/bin/${srcPath}) || die 'not all #!nix-shell directives were processed in ${srcPath}'
        # ensure that there weren't some trailing deps we *didn't* substitute
        grep '^# nix deps evaluated statically$' $out/bin/${srcPath} || die 'trailing characters in nix-shell directive for ${srcPath}'

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
  mkBash = { pkgs ? {}, ...}@attrs:
    let
      pkgsAsAttrs = pkgsToAttrs "" pkgs' pkgs;
      pkgsEnv = [ bash ] ++ (builtins.attrValues pkgsAsAttrs);
      pkgExprs = insertTopo "bash" (builtins.attrNames pkgsAsAttrs);
    in mkShell ({
      inherit pkgsEnv pkgExprs;
      interpreter = lib.getExe bash;
    } // (removeAttrs attrs [ "bash" "pkgs" ])
  );

  # `mkShell` specialization for `nix-shell -i zsh` scripts.
  mkZsh = { pkgs ? {}, ...}@attrs:
    let
      pkgsAsAttrs = pkgsToAttrs "" pkgs' pkgs;
      pkgsEnv = [ zsh ] ++ (builtins.attrValues pkgsAsAttrs);
      pkgExprs = insertTopo "zsh" (builtins.attrNames pkgsAsAttrs);
    in mkShell ({
      inherit pkgsEnv pkgExprs;
      interpreter = lib.getExe zsh;
    } // (removeAttrs attrs [ "pkgs" "zsh" ])
  );

  # `mkShell` specialization for invocations of `nix-shell -i python3 -p python3 ...`
  mkPython3 = { pkgs ? {}, ... }@attrs:
    let
      pkgsAsAttrs = pkgsToAttrs "" pkgs' pkgs;
      pkgsEnv = builtins.attrValues pkgsAsAttrs;
      pkgExprs = insertTopo "python3" (builtins.attrNames pkgsAsAttrs);
    in mkShell ({
      inherit pkgsEnv pkgExprs;
      interpreter = lib.getExe python3;
      interpreterName = "python3";
      # "wrapPythonPrograms" only adds libraries that are on `propagatedBuildInputs` onto the site path.
      propagatedBuildInputs = lib.flatten pkgsEnv;

      nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [
        python3.pkgs.wrapPython
      ];
      postFixup = ''
        wrapPythonPrograms
      '';
    } // (removeAttrs attrs [ "pkgs" "python3" ])
  );
}
