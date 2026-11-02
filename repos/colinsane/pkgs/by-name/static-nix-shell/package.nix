{
  bash,
  lib,
  makeBinaryWrapper,
  newScope,
  oils-for-unix,
  pkgs,
  pkgsMusl,
  pkgsStatic,
  python3,
  stdenvNoCC,
  zsh,
}:

let
  pkgs' = pkgs // {
    # XXX(2025-12-08): static bash is way faster than normal bash:
    # `nix-build -A bash && hyperfine './result/bin/sh --version'`
    # - 2.2 ms
    # `nix-build -A pkgsCross.musl64.bash && hyperfine './result/bin/sh --version'`
    # - 835.0 µs
    # `nix-build -A pkgsStatic.bash && hyperfine './result/bin/sh --version'`
    # - 262.8 µs
    # bash' = pkgsStatic.bash;
    # XXX(2026-01-20): `pkgsMusl.pkgsStatic.stdenv` doesn't build (but `pkgsMusl.pkgsMusl.bash` _does_ build.
    inherit (pkgsMusl) bash;
  };
  resolvePkgs = packages: if lib.isList packages then
    packages
  else if lib.isAttrs packages then
    builtins.attrValues packages
  else # lib.isFunction packages
    resolvePkgs (packages pkgs');
  # insert an element `ins` into a list `into`,
  # at its proper location assuming `into` is lexicographically ordered.
  # does not adjust the order of existing elements.
  insertTopo = ins: into: let
    sortKey = v: v.name or v.pname or v;
    insertedUnlessLast = builtins.foldl' (acc: next:
      if builtins.elem ins acc then
        acc ++ [ next ]
      else if (lib.naturalSort [ (sortKey ins) (sortKey next) ]) == [ (sortKey ins) (sortKey next) ] then
        acc ++ [ ins next ]
      else
        acc ++ [ next ]
    ) [] into
    ;
  in
    if lib.isList into then
      if builtins.elem ins insertedUnlessLast then
        insertedUnlessLast
      else
        into ++ [ ins ]
    else if lib.isAttrs into then
      into // {
        "${ins.name or ins.pname}" = ins;
      }
    else
      (pkgs: insertTopo ins (into pkgs))
    ;
in lib.makeScope newScope (self: {
  # transform a file which uses `#!/usr/bin/env nix-shell` shebang
  # into a derivation that can be built statically.
  #
  # packages may take the following form:
  # - { pkgNameA = pkgValueA; "pkg.name.b" = pkg.value.b; ... }
  # - [ pkgValueA pkgValueB ... ]
  # - ps: <evaluate to one of the above exprs>
  mkShell = lib.extendMkDerivation {
    constructDrv = stdenvNoCC.mkDerivation;
    excludeDrvArgNames = [
      "builderName"
      "interpreter"
      "interpreterName"
      "packages"
      "pname"
      "srcPath"
    ];
    extendDrvArgs = finalAttrs: {
      pname ? "static-nix-shell",
      interpreterPackage,
      interpreter ? if (interpreterPackage.meta.mainProgram or null) != null then lib.getExe interpreterPackage else lib.getExe' interpreterPackage interpreterName,
      interpreterName ? lib.last (builtins.split "/" interpreter),
      builderName,
      packages ? [ ],
      merge ? "append",  #< "append" new {PATH,XDG_DATA_DIRS} entries to existing {PATH,XDG_DATA_DIRS}? or "prepend"?
      srcPath ? pname, #< N.B.: should not contain `/`'s
      srcRoot ? null,
      src ? null,
      ...
    }@attrs:
  let
    extraDerivArgs = lib.optionalAttrs (srcRoot != null) {
      # user can use `srcRoot` instead of `src` in most scenarios, to avoid including the entire directory containing their
      # source file in the closure, but *just* the source file itself.
      # `lib.fileset` docs: <https://ryantm.github.io/nixpkgs/functions/library/fileset/>
      src = lib.fileset.toSource {
        root = srcRoot; fileset = lib.path.append srcRoot srcPath;
      };
    };
    srcText =
      if (extraDerivArgs.src.origSrc or null) != null then
        builtins.readFile (
          lib.path.append extraDerivArgs.src.origSrc srcPath
        )
      else if src != null then
        builtins.readFile (
          lib.path.append src srcPath
        )
      else
        null
    ;
    nixShellLineTemplate = "(.*\n)?#!nix-shell -i ${interpreterName} ([^ \n]+) -A static-nix-shell.${builderName} --arg packages '([^'\n]*)'(\n.*)?";
    nixShellLine = builtins.match nixShellLineTemplate srcText;
    nixShellMatch = if srcText != null then
      lib.throwIf (nixShellLine == null) "could not extract expected text from ${attrs.pname or attrs.name}\nexpected\n${nixShellLineTemplate}" nixShellLine
    else
      null;
    packagesText = if nixShellMatch != null then builtins.elemAt nixShellMatch 2 else null;

    shellRootText = builtins.elemAt nixShellMatch 1;
    scriptDir = if srcRoot != null then srcRoot else src;
    shellRoot = scriptDir + "/${shellRootText}";  #< `path + string` normalizes `..` components; lib.path.append would not.
    shellRootPkgs = let
      expr = import shellRoot;
    in
      if lib.isFunction expr then expr { } else expr;
    checkedShellRootText =
      lib.throwIfNot (builtins.pathExists shellRoot)
        "${pname}: `#!nix-shell` path '${shellRootText}' (${toString shellRoot}) does not exist"
      (lib.throwIfNot (shellRootPkgs ? static-nix-shell.${builderName})
        "${pname}: `#!nix-shell` path '${shellRootText}' (${toString shellRoot}) does not provide `static-nix-shell.${builderName}`"
        shellRootText);
    embeddedPackages = import (builtins.toFile "static-nix-shell-packages.nix" packagesText);
    # allow any package to be a list of packages, to support things like
    # -p python3.pkgs.foo.propagatedBuildInputs
    resolvedPkgs = if srcText != null then
      lib.flatten (resolvePkgs embeddedPackages)
    else
      null;
    # resolvedSpec = insertTopo interpreterPackage (lib.flatten (resolvePkgs packages));
    resolvedSpec = lib.flatten (resolvePkgs (insertTopo interpreterPackage packages));

  in {
      __structuredAttrs = true;
      inherit pname;
      version = attrs.version or "0.1.0";  # default version
      preferLocalBuild = attrs.preferLocalBuild or true;

      nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [
        makeBinaryWrapper
      ];

      runtimePrefixes = attrs.runtimePrefixes or (
        if resolvePkgs != null then
          resolvedPkgs
        else
          resolvedSpec
      );

      configurePhase = attrs.configurePhase or ''
        runHook preConfigure

        # generate `extraPaths`, `extraXdgDataDirs` colon-separated paths for use in the build phase.
        # first, gather the entire buildInputs closure:
        runtimePrefixesList=()
        crawlPackage() {
          # only crawl each package *once*
          for p in "''${runtimePrefixesList[@]}"; do
            if [[ "$p" == "$1" ]]; then
              return
            fi
          done

          # ingest this package
          runtimePrefixesList=("''${runtimePrefixesList[@]}" "$1")

          # crawl everything this package propagates.
          # this is *required* for Python packages.
          local prop=$1/nix-support/propagated-build-inputs
          if [ -e "$prop" ]; then
            crawlPackages $(cat "$prop")
          fi
        }
        crawlPackages() {
          for p in "$@"; do
            crawlPackage "$p"
          done
        }
        crawlPackages "''${runtimePrefixes[@]}"
        append_PATH=
        prepend_PATH=
        append_XDG_DATA_DIRS=
        prepend_XDG_DATA_DIRS=
        for p in "''${runtimePrefixesList[@]}"; do
          echo "considering if dependency needs to be added to runtime environment(s): $p"
          # `addToSearchPath` behaves as no-op if the provided path doesn't exist
          addToSearchPath ${merge}_PATH "$p/bin"
          addToSearchPath ${merge}_XDG_DATA_DIRS "$p/share"
        done

        runHook postConfigure
      '';

      buildPhase = attrs.buildPhase or ''
        runHook preBuild

        die() {
          echo "$@"
          exit 1
        }

        if [ -n "$shellPreamble" ]; then
        shellPreamble="
        # --- BEGIN: nix-shell preamble (generated code) ---
        $shellPreamble
        # --- END:   nix-shell preamble (generated code) ---
        "
        fi
        substituteInPlace ${srcPath} \
          --replace-fail '#!/usr/bin/env -S NIX_BUILD_SHELL=/bin/sh nix-shell' '#!${interpreter}' \
          ${lib.optionalString (packagesText != null) ''
            --replace-fail \
              '#!nix-shell -i ${interpreterName} ${checkedShellRootText} -A static-nix-shell.${builderName} --arg packages '"'"'${packagesText}'"'"$'\n' \
              $'# nix deps evaluated statically\n'"''${shellPreamble:-}"
          ''}

        # if no specialized `shellPreamble` was populated, then inject dependencies via wrapper
        if [[ -z "''${shellPreamble:-}" ]]; then
          if [[ -n "$append_PATH" ]]; then
            makeWrapperArgs+=("--suffix" "PATH" ":" "$append_PATH")
          fi
          if [[ -n "$prepend_PATH" ]]; then
            makeWrapperArgs+=("--prefix" "PATH" ":" "$prepend_PATH")
          fi
          if [[ -n "$append_XDG_DATA_DIRS" ]]; then
            makeWrapperArgs+=("--suffix" "XDG_DATA_DIRS" ":" "$append_XDG_DATA_DIRS")
          fi
          if [[ -n "$prepend_XDG_DATA_DIRS" ]]; then
            makeWrapperArgs+=("--prefix" "XDG_DATA_DIRS" ":" "$prepend_XDG_DATA_DIRS")
          fi
        else
          if [[ -n "$append_PATH" ]]; then
            die "shellPreamble failed to clear 'append_PATH' variable: $append_PATH"
          fi
          if [[ -n "$prepend_PATH" ]]; then
            die "shellPreamble failed to clear 'prepend_PATH' variable: $prepend_PATH"
          fi
          if [[ -n "$append_XDG_DATA_DIRS" ]]; then
            die "shellPreamble failed to clear 'append_XDG_DATA_DIRS' variable: $append_XDG_DATA_DIRS"
          fi
          if [[ -n "$prepend_XDG_DATA_DIRS" ]]; then
            die "shellPreamble failed to clear 'prepend_XDG_DATA_DIRS' variable: $prepend_XDG_DATA_DIRS"
          fi
        fi

        runHook postBuild
      '';

      installPhase = let
        names = lib.map (p: p.pname or p.name);
      in
        attrs.installPhase or ''
        runHook preInstall

        install -Dm755 ${srcPath} $out/bin/${finalAttrs.meta.mainProgram}

        if [ -z ''${dontCheckPackageConsistency:-} ]; then
          ${lib.optionalString (resolvedSpec != null && resolvedPkgs != null) ''
            if [[ "${toString (names resolvedSpec)}" != "${toString (names resolvedPkgs)}" ]]; then
              # weaker name-based comparison
              die "embedded package lists for '${pname}' differs from that specified in nix:"$'\n'"${toString (names resolvedPkgs)}"$'\n'"${toString (names resolvedSpec)}"
            fi
            if [ -z "''${relaxPackageConsistency:-}" ]; then
              if [[ "${toString resolvedSpec}" != "${toString resolvedPkgs}" ]]; then
                # stronger path-based comparison (in case one package was `.override`n while another wasn't)
                die "embedded package lists for '${pname}' differs from that specified in nix:"$'\n'"${toString resolvedPkgs}"$'\n'"${toString resolvedSpec}"
              fi
            fi
          ''}
          # if declare -p resolvedPkgs && declare -p resolvedSpec; then
          #   if [[ "''${resolvedPkgs[*]" != "''${resolvedSpec[*]}" ]]; then
          #     die "embedded package lists for '${pname}' differs from that specified in nix:\n''${resolvedPkgs[*]}\n''${resolvedSpec[*]}"
          #   fi
          # fi
        fi

        # ensure that all nix-shell references were substituted
        (! grep '#![ \t]*nix-shell' $out/bin/${finalAttrs.meta.mainProgram}) || die 'not all #!nix-shell directives were processed in ${finalAttrs.meta.mainProgram}'
        # ensure that there weren't some trailing deps we *didn't* substitute
        grep '^# nix deps evaluated statically$' $out/bin/${finalAttrs.meta.mainProgram} || die 'trailing characters in nix-shell directive for ${finalAttrs.meta.mainProgram}'

        if [[ ''${#makeWrapperArgs[@]} != 0 ]]; then
          wrapProgram $out/bin/${finalAttrs.meta.mainProgram} \
            "''${makeWrapperArgs[@]}"
        fi

        runHook postInstall
      '';

      # TODO: should assert that `--help` actually prints something reasonable (e.g. program name),
      # and isn't inadvertently a no-op
      installCheckPhase = attrs.installCheckPhase or ''
        runHook preInstallCheck

        timeout 15 $out/bin/${finalAttrs.meta.mainProgram} --help

        runHook postInstallCheck
      '';

      doInstallCheck = attrs.doInstallCheck or true;

      meta = (attrs.meta or {}) // {
        mainProgram = (attrs.meta or {}).mainProgram or srcPath;
      };
    } // extraDerivArgs;
  };

  # `mkShell` specialization for `nix-shell -i bash` scripts.
  # must be a function (not lib.extendMkDerivation), to support CLI-based invocations
  mkBash = { packages ? [ ] , ... }@shellArgs: lib.extendMkDerivation {
    constructDrv = self.mkShell;
    excludeDrvArgNames = [ "bash" ];
    extendDrvArgs = finalAttrs: {...}@attrs: {
      builderName = "mkBash";
      interpreterPackage = attrs.interpreterPackage or pkgs'.bash;
      postConfigure = attrs.postConfigure or ''
        DOLLAR='$'
        if [[ -n "$append_PATH" ]]; then
          shellPreamble="$shellPreamble"$'\n'
          shellPreamble="$shellPreamble"'export PATH=''${PATH:+$PATH:}'"$append_PATH"
          unset append_PATH
        fi

        if [[ -n "$prepend_PATH" ]]; then
          shellPreamble="$shellPreamble"$'\n'
          shellPreamble="$shellPreamble""export PATH=$prepend_PATH""$DOLLAR"'{PATH:+:$PATH}'
          unset prepend_PATH
        fi

        if [[ -n "$append_XDG_DATA_DIRS" ]]; then
          shellPreamble="$shellPreamble"$'\n'
          shellPreamble="$shellPreamble"'export XDG_DATA_DIRS=''${XDG_DATA_DIRS:+$XDG_DATA_DIRS:}'"$append_XDG_DATA_DIRS"
          unset append_XDG_DATA_DIRS
        fi

        if [[ -n "$prepend_XDG_DATA_DIRS" ]]; then
          shellPreamble="$shellPreamble"$'\n'
          shellPreamble="$shellPreamble""export XDG_DATA_DIRS=$prepend_XDG_DATA_DIRS""$DOLLAR"'{XDG_DATA_DIRS:+:$XDG_DATA_DIRS}'
          unset prepend_XDG_DATA_DIRS
        fi
      '';
    };
  } shellArgs;

  # `mkShell` specialization for `nix-shell -i ysh` (oil) scripts.
  # must be a function (not lib.extendMkDerivation), to support CLI-based invocations
  mkYsh = { packages ? [ ] , ... }@shellArgs: lib.extendMkDerivation {
    constructDrv = self.mkShell;
    excludeDrvArgNames = [ "oils-for-unix" ];
    extendDrvArgs = finalAttrs: {...}@attrs: {
      builderName = "mkYsh";
      interpreterPackage = attrs.interpreterPackage or pkgs'.oils-for-unix;
      interpreterName = attrs.interpreterName or "ysh";
      postConfigure = attrs.postConfigure or ''
        shellPreambleBody=
        if [[ -n "$append_PATH" ]]; then
          shellPreambleBody="$shellPreambleBody"$'\n'
          shellPreambleBody="$shellPreambleBody"'appendToSearchPath "PATH" "'"$append_PATH"'"'
          unset append_PATH
        fi
        if [[ -n "$prepend_PATH" ]]; then
          shellPreambleBody="$shellPreambleBody"$'\n'
          shellPreambleBody="$shellPreambleBody"'prependToSearchPath "PATH" "'"$prepend_PATH"'"'
          unset prepend_PATH
        fi
        if [[ -n "$append_XDG_DATA_DIRS" ]]; then
          shellPreambleBody="$shellPreambleBody"$'\n'
          shellPreambleBody="$shellPreambleBody"'appendToSearchPath "XDG_DATA_DIRS" "'"$append_XDG_DATA_DIRS"'"'
          unset append_XDG_DATA_DIRS
        fi
        if [[ -n "$prepend_XDG_DATA_DIRS" ]]; then
          shellPreambleBody="$shellPreambleBody"$'\n'
          shellPreambleBody="$shellPreambleBody"'prependToSearchPath "XDG_DATA_DIRS" "'"$prepend_XDG_DATA_DIRS"'"'
          unset prepend_XDG_DATA_DIRS
        fi

        if [[ -n "$shellPreambleBody" ]]; then
        shellPreamble='
        {
          proc appendToSearchPath(envName, appendValue) {
            var value = get(ENV, envName)
            if (value === null) {
              setglobal ENV[envName] = "$appendValue"
            } else {
              setglobal ENV[envName] = "$value:$appendValue"
            }
          }
          proc prependToSearchPath(envName, prependValue) {
            var value = get(ENV, envName)
            if (value === null) {
              setglobal ENV[envName] = "$prependValue"
            } else {
              setglobal ENV[envName] = "$prependValue:$value"
            }
          }
        '"$shellPreambleBody"'

          unset appendToSearchPath
          unset prependToSearchPath
        }
        '
        fi
      '';
    };
  } shellArgs;

  # `mkShell` specialization for `nix-shell -i zsh` scripts.
  # must be a function (not lib.extendMkDerivation), to support CLI-based invocations
  mkZsh = { packages ? [ ], ... }@shellArgs: lib.extendMkDerivation {
    constructDrv = self.mkShell;
    excludeDrvArgNames = [ "zsh" ];
    extendDrvArgs = finalAttrs: {...}@attrs: {
      builderName = "mkZsh";
      interpreterPackage = attrs.interpreterPackage or pkgs'.zsh;
      interpreterName = attrs.interpreterName or "zsh";
      postConfigure = attrs.postConfigure or ''
        DOLLAR='$'
        if [[ -n "$append_PATH" ]]; then
          shellPreamble="$shellPreamble"$'\n'
          shellPreamble="$shellPreamble"'export PATH=''${PATH:+$PATH:}'"$append_PATH"
          unset append_PATH
        fi

        if [[ -n "$prepend_PATH" ]]; then
          shellPreamble="$shellPreamble"$'\n'
          shellPreamble="$shellPreamble""export PATH=$prepend_PATH""$DOLLAR"'{PATH:+:$PATH}'
          unset prepend_PATH
        fi

        if [[ -n "$append_XDG_DATA_DIRS" ]]; then
          shellPreamble="$shellPreamble"$'\n'
          shellPreamble="$shellPreamble"'export XDG_DATA_DIRS=''${XDG_DATA_DIRS:+$XDG_DATA_DIRS:}'"$append_XDG_DATA_DIRS"
          unset append_XDG_DATA_DIRS
        fi

        if [[ -n "$prepend_XDG_DATA_DIRS" ]]; then
          shellPreamble="$shellPreamble"$'\n'
          shellPreamble="$shellPreamble""export XDG_DATA_DIRS=$prepend_XDG_DATA_DIRS""$DOLLAR"'{XDG_DATA_DIRS:+:$XDG_DATA_DIRS}'
          unset prepend_XDG_DATA_DIRS
        fi
      '';
    };
  } shellArgs;

  # `mkShell` specialization for invocations of `nix-shell -i python3 -p python3 ...`
  # must be a function (not lib.extendMkDerivation), to support CLI-based invocations
  mkPython3 = { packages ? [ ], ... }@shellArgs: lib.extendMkDerivation {
    constructDrv = self.mkShell;
    excludeDrvArgNames = [ "python3" ];
    extendDrvArgs = finalAttrs: {...}@attrs: {
      builderName = "mkPython3";
      interpreterPackage = attrs.interpreterPackage or python3;
      interpreterName = attrs.interpreterName or "python3";
      # the logic for dealing with PYTHONPATH (which governs `import` search path)
      # comes from <repo:nixos/nixpkgs:pkgs/development/interpreters/python/wrap.sh>
      # and <repo:nixos/nixpkgs:pkgs/development/interpreters/python/wrap-python.nix>
      postConfigure = attrs.postConfigure or ''
        for p in "''${runtimePrefixesList[@]}"; do
          # XXX: python site dirs appear to be unordered?
          addToSearchPath add_PYTHONPATH "$p/${python3.sitePackages}"
        done

        shellPreambleBody=
        if [[ -n "$append_PATH" ]]; then
          shellPreambleBody="$shellPreambleBody"$'\n'
          shellPreambleBody="$shellPreambleBody"'appendToSearchPath("PATH", "'"$append_PATH"'")'
          unset append_PATH
        fi
        if [[ -n "$prepend_PATH" ]]; then
          shellPreambleBody="$shellPreambleBody"$'\n'
          shellPreambleBody="$shellPreambleBody"'prependToSearchPath("PATH", "'"$prepend_PATH"'")'
          unset prepend_PATH
        fi
        if [[ -n "$append_XDG_DATA_DIRS" ]]; then
          shellPreambleBody="$shellPreambleBody"$'\n'
          shellPreambleBody="$shellPreambleBody"'appendToSearchPath("XDG_DATA_DIRS", "'"$append_XDG_DATA_DIRS"'")'
          unset append_XDG_DATA_DIRS
        fi
        if [[ -n "$prepend_XDG_DATA_DIRS" ]]; then
          shellPreambleBody="$shellPreambleBody"$'\n'
          shellPreambleBody="$shellPreambleBody"'prependToSearchPath("XDG_DATA_DIRS", "'"$prepend_XDG_DATA_DIRS"'")'
          unset prepend_XDG_DATA_DIRS
        fi

        if [[ -n "$add_PYTHONPATH" ]]; then
          shellPreambleBody="$shellPreambleBody"$'\n'
          shellPreambleBody="$shellPreambleBody"'addSiteDirs("'"$add_PYTHONPATH"'")'
          unset add_PYTHONPATH
        fi

        if [[ -n "$shellPreambleBody" ]]; then
          shellPreamble='
        # this preamble is unaware of the tab-style used in the rest of the file,
        # so wrap it in a big `exec` to avoid conflicting tab styles
        # (and to avoid polluting the globals)
        exec("""
        def appendToSearchPath(envName, appendValue):
          import os
          value = os.environ.get(envName)
          if value is None:
            os.environ[envName] = appendValue
          else:
            os.environ[envName] = value + ":" + appendValue

        def prependToSearchPath(envName, prependValue):
          import os
          value = os.environ.get(envName)
          if value is None:
            os.environ[envName] = prependValue
          else:
            os.environ[envName] = prependValue + ":" + value

        def addSiteDirs(joinedDirs):
          import site
          known = site._init_pathinfo()
          for p in joinedDirs.split(":"):
            known = site.addsitedir(p, known)

        '"$shellPreambleBody"'
        """, globals={})
        '
        fi
      '';
    };
  } shellArgs;
})
