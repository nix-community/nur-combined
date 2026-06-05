{
  bash,
  lib,
  makeBinaryWrapper,
  newScope,
  oils-for-unix,
  pkgsMusl,
  pkgsStatic,
  python3,
  stdenvNoCC,
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
in lib.makeScope newScope (self: {
  # transform a file which uses `#!/usr/bin/env nix-shell` shebang
  # into a derivation that can be built statically.
  #
  # pkgs may take the following form:
  # - { pkgNameA = pkgValueA; "pkg.name.b" = pkg.value.b; ... }
  # - ps: <evaluate to one of the above exprs>
  mkShell = {
    pname,
    interpreter,
    interpreterName ? lib.last (builtins.split "/" interpreter),
    pkgsEnv,
    pkgExprs,
    merge ? "append",  #< "append" new {PATH,XDG_DATA_DIRS} entries to existing {PATH,XDG_DATA_DIRS}? or "prepend"?
    srcPath ? pname, #< N.B.: should not contain `/`'s
    srcRoot ? null,
    src ? null,
    ...
  }@attrs:
  let
    repoRoot = ../../..;
    getPathToRoot = ascended: at:
      if at == repoRoot then
        ascended
      else
        getPathToRoot "../${ascended}" (dirOf at)
    ;
    pathToRepoRoot = getPathToRoot "" (if srcRoot != null then srcRoot else src);

    extraDerivArgs = lib.optionalAttrs (srcRoot != null) {
      # user can use `srcRoot` instead of `src` in most scenarios, to avoid including the entire directory containing their
      # source file in the closure, but *just* the source file itself.
      # `lib.fileset` docs: <https://ryantm.github.io/nixpkgs/functions/library/fileset/>
      src = lib.fileset.toSource {
        root = srcRoot; fileset = lib.path.append srcRoot srcPath;
      };
    };
    pkgStrs = map (pname: "ps.${pname}") pkgExprs;
    argStr = builtins.concatStringsSep " " (
      [ "ps:" "[" ] ++ pkgStrs ++ [ "]" ]
    );
    nixShellImport = "${pathToRepoRoot}integrations/nix-shell";
    # allow any package to be a list of packages, to support things like
    # -p python3.pkgs.foo.propagatedBuildInputs
    pkgsEnv' = lib.flatten pkgsEnv;
  in
    stdenvNoCC.mkDerivation (finalAttrs: {
      version = "0.1.0";  # default version
      preferLocalBuild = true;

      nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [
        makeBinaryWrapper
      ];

      runtimePrefixes = pkgsEnv';

      configurePhase = ''
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
        crawlPackages $runtimePrefixes
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

      buildPhase = ''
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
          --replace-fail \
            '#!nix-shell -i ${interpreterName} ${nixShellImport} --arg f '"'"'${argStr}'"'"$'\n' \
            $'# nix deps evaluated statically\n'"''${shellPreamble:-}"

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

      installPhase = ''
        runHook preInstall

        install -Dm755 ${srcPath} $out/bin/${srcPath}

        # ensure that all nix-shell references were substituted
        (! grep '#![ \t]*nix-shell' $out/bin/${srcPath}) || die 'not all #!nix-shell directives were processed in ${srcPath}'
        # ensure that there weren't some trailing deps we *didn't* substitute
        grep '^# nix deps evaluated statically$' $out/bin/${srcPath} || die 'trailing characters in nix-shell directive for ${srcPath}'

        if [[ ''${#makeWrapperArgs[@]} != 0 ]]; then
          wrapProgram $out/bin/${srcPath} \
            "''${makeWrapperArgs[@]}"
        fi

        runHook postInstall
      '';

      # TODO: should assert that `--help` actually prints something reasonable (e.g. program name),
      # and isn't inadvertently a no-op
      installCheckPhase = ''
        runHook preInstallCheck

        timeout 15 $out/bin/${srcPath} --help

        runHook postInstallCheck
      '';

      doInstallCheck = true;

      meta = {
        mainProgram = srcPath;
      } // (attrs.meta or {});
    } // extraDerivArgs // (removeAttrs attrs [
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
      # XXX(2025-12-08): static bash is way faster than normal bash:
      # `nix-build -A bash && hyperfine './result/bin/sh --version'`
      # - 2.2 ms
      # `nix-build -A pkgsCross.musl64.bash && hyperfine './result/bin/sh --version'`
      # - 835.0 µs
      # `nix-build -A pkgsStatic.bash && hyperfine './result/bin/sh --version'`
      # - 262.8 µs
      # bash' = pkgsStatic.bash;
      # XXX(2026-01-20): `pkgsMusl.pkgsStatic.stdenv` doesn't build (but `pkgsMusl.pkgsMusl.bash` _does_ build.
      bash' = pkgsMusl.bash;
      pkgsEnv = [ bash' ] ++ (builtins.attrValues pkgs);
      pkgExprs = insertTopo "bash" (builtins.attrNames pkgs);
    in self.mkShell ({
      inherit pkgsEnv pkgExprs;
      interpreter = lib.getExe bash';
      postConfigure = ''
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
    } // (removeAttrs attrs [ "bash" "pkgs" ])
  );

  # `mkShell` specialization for `nix-shell -i ysh` (oil) scripts.
  mkYsh = { pkgs ? {}, ...}@attrs:
    let
      pkgsEnv = [ oils-for-unix ] ++ (builtins.attrValues pkgs);
      pkgExprs = insertTopo "oils-for-unix" (builtins.attrNames pkgs);
    in self.mkShell ({
      inherit pkgsEnv pkgExprs;
      interpreter = lib.getExe' oils-for-unix "ysh";
      postConfigure = ''
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
    } // (removeAttrs attrs [ "oils-for-unix" "pkgs" ])
  );

  # `mkShell` specialization for `nix-shell -i zsh` scripts.
  mkZsh = { pkgs ? {}, ...}@attrs:
    let
      pkgsEnv = [ zsh ] ++ (builtins.attrValues pkgs);
      pkgExprs = insertTopo "zsh" (builtins.attrNames pkgs);
    in self.mkShell ({
      inherit pkgsEnv pkgExprs;
      interpreter = lib.getExe zsh;
      postConfigure = ''
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
    } // (removeAttrs attrs [ "pkgs" "zsh" ])
  );

  # `mkShell` specialization for invocations of `nix-shell -i python3 -p python3 ...`
  mkPython3 = { pkgs ? {}, ... }@attrs:
    let
      pkgsEnv = builtins.attrValues pkgs;
      pkgExprs = insertTopo "python3" (builtins.attrNames pkgs);
    in self.mkShell ({
      inherit pkgsEnv pkgExprs;
      interpreter = lib.getExe python3;
      interpreterName = "python3";
      # the logic for dealing with PYTHONPATH (which governs `import` search path)
      # comes from <repo:nixos/nixpkgs:pkgs/development/interpreters/python/wrap.sh>
      # and <repo:nixos/nixpkgs:pkgs/development/interpreters/python/wrap-python.nix>
      postConfigure = ''
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
    } // (removeAttrs attrs [ "pkgs" "python3" ])
  );
})
