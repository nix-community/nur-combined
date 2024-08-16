{
  lib,
  stdenv,
  buildPackages,
  file,
  gnugrep,
  gnused,
  makeWrapper,
  runCommandLocal,
  runtimeShell,
  sanebox,
  symlinkJoin,
  writeShellScriptBin,
  writeTextFile,
  xorg,
}:
let
  fakeSaneSandboxed = writeShellScriptBin "sanebox" ''
    # behave like the real sanebox with SANEBOX_DISABLE=1,
    # but in a manner which avoids taking a dependency on the real sanebox.
    # the primary use for this is to allow a package's `check` phase to work even when sanebox isn't available.
    _origArgs=($@)

    # throw away all arguments until we find the path to the binary which is being sandboxed
    while [ "$#" -gt 0 ] && ! [[ "$1" =~ /\.sandboxed/ ]]; do
      shift
    done
    if [ "$#" -eq 0 ]; then
      >&2 echo "sanebox (mock): failed to parse args: ''${_origArgs[*]}"
      exit 1
    fi

    if [ -z "$SANEBOX_DISABLE" ]; then
      >&2 echo "sanebox (mock): not called with SANEBOX_DISABLE=1; unsure how to sandbox: ''${_origArgs[*]}"
      exit 1
    fi
    # assume that every argument after the binary name is an argument for the binary and not for the sandboxer.
    exec "$@"
  '';

  makeHookable = pkg: pkg.overrideAttrs (drv: lib.optionalAttrs (drv ? buildCommand && !lib.hasInfix "postFixup" drv.buildCommand) {
    buildCommand = drv.buildCommand + ''
      runHook postFixup
    '';
  });

  # take an existing package, which may have a `bin/` folder as well as `share/` etc,
  # and patch the `bin/` items in-place
  sandboxBinariesInPlace = sanebox': extraSandboxArgs: pkgName: pkg: pkg.overrideAttrs (unwrapped: {
    # disable the sandbox and inject a minimal fake sandboxer which understands that flag,
    # in order to support packages which invoke sandboxed apps in their check phase.
    # note that it's not just for packages which invoke their *own* binaries in check phase,
    # but also packages which invoke OTHER PACKAGES' sandboxed binaries.
    # hence, put the fake sandbox in nativeBuildInputs instead of nativeCheckInputs.
    env = (unwrapped.env or {}) // {
      SANEBOX_DISABLE = 1;
    };
    # TODO: handle multi-output packages; until then, squash lib into the main output, particularly for `libexec`.
    # (this line here only affects `inplace` style wrapping)
    outputs = lib.remove "lib" (unwrapped.outputs or [ "out" ]);
    nativeBuildInputs = [
      # the ordering here is specific: inject our deps BEFORE the unwrapped program's
      # so that the unwrapped's take precendence and we limit interference (e.g. makeWrapper impl)
      fakeSaneSandboxed
      gnugrep
      makeWrapper
    ] ++ (unwrapped.nativeBuildInputs or []);
    disallowedReferences = (unwrapped.disallowedReferences or []) ++ [
      # the fake sandbox gates itself behind SANEBOX_DISABLE, so if it did end up deployed
      # then it wouldn't permit anything not already permitted. but it would still be annoying.
      fakeSaneSandboxed
    ];

    postFixup = (unwrapped.postFixup or "") + ''
      assertExecutable() {
        :  # my programs refer to sanebox by name, not path, which triggers an over-eager assertion in nixpkgs (so, mask that)
      }
      # makeDocumentedCWrapper() {
      #   # this is identical to nixpkgs' implementation, only replace execv with execvp, the latter which looks for the executable on PATH.
      #   local src=$(makeCWrapper "$@")
      #   src="''${src/return execv(/return execvp(}"
      #   local docs=$(docstring "$@")
      #   printf '%s\n\n' "$src"
      #   printf '%s\n' "$docs"
      # }

      sandboxWrap() {
        local _dir="$1"
        local _name="$2"
        echo "sandboxWrap $_dir/$_name"

        # N.B.: unlike stock `wrapProgram`, we place the unwrapped binary in a subdirectory and *preserve its name*.
        # the upside of this is that for applications which read "$0" to decide what to do (e.g. busybox, git)
        # they work as expected without any special hacks.
        # though even so, the sandboxer still tries to preserve the $0 which it was invoked under
        mkdir -p "$_dir/.sandboxed"
        if [[ "$(readlink $_dir/$_name)" =~ ^\.\./ ]]; then
          # relative links which ascend a directory (into a non-bin/ directory)
          # won't point to the right place if we naively move them
          ln -s "../$(readlink $_dir/$_name)" "$_dir/.sandboxed/$_name"
          rm "$_dir/$_name"
        else
          mv "$_dir/$_name" "$_dir/.sandboxed/"
        fi
        makeShellWrapper ${sanebox'} "$_dir/$_name" --suffix PATH : /run/current-system/sw/libexec/sanebox \
          ${lib.escapeShellArgs (lib.flatten (builtins.map (f: [ "--add-flags" f ]) extraSandboxArgs))} \
          --add-flags "$_dir/.sandboxed/$_name"
        # `exec`ing a script with an interpreter will smash $0. instead, source it to preserve $0:
        # - <https://github.com/NixOS/nixpkgs/issues/150841#issuecomment-995589961>
        substituteInPlace "$_dir/$_name" \
          --replace-fail 'exec ' 'source '
      }

      derefWhileInSameOutput() {
        local output="$1"
        local item="$2"
        if [ -L "$item" ]; then
          local target=$(readlink "$item")
          if [[ "$target" =~ ^"$output"/ ]]; then
            # absolute link back into the same package
            item=$(derefWhileInSameOutput "$output" "$target")
          elif [[ "$target" =~ ^/nix/store/ ]]; then
            : # absolute link to another package: we're done
          else
            # relative link
            local parent=$(dirname "$item")
            target="$parent/$target"
            item=$(derefWhileInSameOutput "$output" "$target")
          fi
        fi
        # canonicalize the path, to avoid wrapping the same item twice under different names
        realpath --no-symlinks "$item"
      }
      findUnwrapped() {
        if [ -L "$1" ]; then
          echo "$1"
        else
          local dir_=$(dirname "$1")
          local file_=$(basename "$1")
          local sandboxed="$dir_/.sandboxed/$file_"
          local unwrapped="$dir_/.''${file_}-unwrapped"
          if grep -q "$sandboxed" "$1"; then
            echo "/dev/null"  #< already sandboxed
          elif grep -q "$unwrapped" "$1"; then
            echo $(findUnwrapped "$unwrapped")
          else
            echo "$1"
          fi
        fi
      }

      crawlAndWrap() {
        local output="$1"
        local _dir="$2"
        echo "crawlAndWrap $_dir"
        local items=($(ls -a "$_dir/"))
        for item in "''${items[@]}"; do
          if [ "$item" != . ] && [ "$item" != .. ]; then
            local target="$_dir/$item"
            if [ -d "$target" ]; then
              crawlAndWrap "$output" "$target"
            elif [ -x "$target" ] && [[ "$item" != .* ]]; then
              # in the case of symlinks, deref until we find the real file, or the symlink points outside the package
              target=$(derefWhileInSameOutput "$output" "$target")
              target=$(findUnwrapped "$target")
              if [ "$target" != /dev/null ]; then
                local parent=$(dirname "$target")
                local bin=$(basename "$target")
                sandboxWrap "$parent" "$bin"
              fi
            fi
            # ignore all non-binaries or "hidden" binaries (to avoid double-wrapping)
          fi
        done
      }

      for output in $outputs; do
        local outdir=''${!output}
        echo "scanning output '$output' at $outdir for binaries to sandbox"
        if [ -e "$outdir/bin" ]; then
          crawlAndWrap "$outdir" "$outdir/bin"
        fi
        if [ -e "$outdir/libexec" ]; then
          crawlAndWrap "$outdir" "$outdir/libexec"
        fi
      done
    '';
  });

  # there are certain `meta` fields we care to preserve from the original package (priority),
  # and others we *can't* preserve (outputsToInstall).
  extractMeta = pkg: let
    meta = pkg.meta or {};
  in
    (lib.optionalAttrs (meta ? priority) { inherit (meta) priority; })
    // (lib.optionalAttrs (meta ? mainProgram) { inherit (meta) mainProgram; })
  ;

  # helper used for `wrapperType == "wrappedDerivation"` which simply symlinks all a package's binaries into a new derivation
  symlinkDirs = suffix: symlinkRoots: pkgName: package: (runCommandLocal "${pkgName}-${suffix}" {
    env.symlinkRoots = lib.concatStringsSep " " symlinkRoots;
    nativeBuildInputs = [ gnused ];
  } ''
    set -e
    symlinkPath() {
      if [ -e "$out/$1" ]; then
        :  # already linked. may happen when e.g. the package has bin/foo, and sbin -> bin.
      elif [ -L "${package}/$1" ]; then
        local target=$(readlink "${package}/$1")
        if [[ "$target" =~ ^${package}/ ]]; then
          # absolute link back into the same package
          echo "handling $1: descending into absolute symlink to same package: $target"
          target=$(echo "$target" | sed 's:${package}/::')
          ln -s "$out/$target" "$out/$1"
          # create/link the backing path
          # N.B.: if some leading component of the backing path is also a symlink... this might not work as expected.
          local parent=$(dirname "$out/$target")
          mkdir -p "$parent"
          symlinkPath "$target"
        elif [[ "$target" =~ ^/nix/store/ ]]; then
          # absolute link to another package
          echo "handling $1: symlinking absolute store path: $target"
          ln -s "$target" "$out/$1"
        else
          # relative link
          echo "handling $1: descending into relative symlink: $target"
          ln -s "$target" "$out/$1"
          local parent=$(dirname "$1")
          local derefParent=$(dirname "$out/$parent/$target")
          $(set -x && mkdir -p "$derefParent")
          symlinkPath "$parent/$target"
        fi
      elif [ -d "${package}/$1" ]; then
        echo "handling $1: descending into directory"
        mkdir -p "$out/$1"
        items=($(ls -a "${package}/$1"))
        for item in "''${items[@]}"; do
          if [ "$item" != . ] && [ "$item" != .. ] && [[ "$item" != .* ]]; then
            symlinkPath "$1/$item"
          fi
        done
      elif [ -e "${package}/$1" ]; then
        echo "handling $1: symlinking ordinary file"
        ln -s "${package}/$1" "$out/$1"
      fi
    }
    mkdir -p "$out"
    _symlinkRoots=($symlinkRoots)
    for root in "''${_symlinkRoots[@]}"; do
      echo "crawling top-level directory for symlinking: $root"
      symlinkPath "$root"
    done
    # allow downstream wrapping to hook this (and thereby actually wrap binaries, etc)
    runHook postInstall
    runHook postFixup
  '').overrideAttrs (_: {
    # specifically, preserve meta.priority
    meta = extractMeta package;
  });

  symlinkBinaries = symlinkDirs "bin-only" [ "bin" "sbin" "libexec" ];

  # helper used for `wrapperType == "wrappedDerivation"` which ensures that any copied/symlinked share/ files (like .desktop) files
  # don't point to the unwrapped binaries.
  # other important files it preserves:
  # - share/applications
  # - share/dbus-1  (frequently a source of leaked references!)
  # - share/icons
  # - share/man
  # - share/mime
  # - {etc,lib,share}/systemd
  fixHardcodedRefs = unsandboxed: sandboxedBin: unsandboxedNonBin: unsandboxedNonBin.overrideAttrs (prevAttrs: {
    postInstall = (prevAttrs.postInstall or "") + ''
      trySubstitute() {
        local _outPath="$1"
        local _pattern="$2"
        local _from=$(printf "$_pattern" "${unsandboxed}")
        local _to=$(printf "$_pattern" "${sandboxedBin}")
        printf "applying known substitutions to %s\n" "$_outPath"
        # for closure efficiency, we only want to rewrite stuff which actually needs changing,
        # and allow unchanged stuff to remain as symlinks.
        # `substitute` can't rewrite symlinks, so instead do the substitution to a temp output
        # with `--replace-fail` and only recreate the output symlink as a file if the substitution succeeds (i.e. if it matched).
        if substitute "$_outPath" ./substituteResult --replace-fail "$_from" "$_to"; then
          mv ./substituteResult "$_outPath"
        fi
      }

      # remove any files which exist in sandoxedBin (makes it possible to sandbox /opt-style packages)
      removeUnwanted() {
        local file_=$(basename "$1")
        if [ -f "$out/$1" ] || [ -L "$out/$1" ]; then
          if [ -e "${sandboxedBin}/$1" ]; then
            rm "$out/$1"
          fi
        elif [ -d "$out/$1" ]; then
          local files=($(ls -a "$out/$1"))
          for item in "''${files[@]}"; do
            if [ "$item" != . ] && [ "$item" != .. ]; then
              removeUnwanted "$1/$item"
            fi
          done
        fi
      }
      removeUnwanted ""

      # fixup a few files i understand well enough
      for d in \
        $out/etc/xdg/autostart/*.desktop \
        $out/share/applications/*.desktop \
        $out/share/dbus-1/{services,system-services}/*.service \
        $out/{etc,lib,share}/systemd/{system,user}/*.service \
      ; do
        # Exec: dbus and desktop files
        # ExecStart,ExecReload: systemd service files
        for key in Exec ExecStart ExecReload; do
          for binLoc in bin libexec sbin; do
            trySubstitute "$d" "$key=%s/$binLoc/"
          done
        done
      done
    '';
    passthru = (prevAttrs.passthru or {}) // {
      # check that sandboxedNonBin references only sandboxed binaries, and never the original unsandboxed binaries.
      # do this by dereferencing all sandboxedNonBin symlinks, and making `unsandboxed` a disallowedReference.
      checkSandboxed = let
        sandboxedNonBin = fixHardcodedRefs unsandboxed sandboxedBin unsandboxedNonBin;
      in runCommandLocal "${sandboxedNonBin.name}-check-sandboxed"
        { disallowedReferences = [ unsandboxed ]; }
        # dereference every symlink, ensuring that whatever data is behind it does not reference non-sandboxed binaries.
        # the dereference *can* fail, in case it's a relative symlink that refers to a part of the non-binaries we don't patch.
        # in such case, this could lead to weird brokenness (e.g. no icons/images), so failing is reasonable.
        # N.B.: this `checkSandboxed` protects against accidentally referencing unsandboxed binaries from data files (.deskop, .service, etc).
        # there's an *additional* `checkSandboxed` further below which invokes every executable in the final package to make sure the binaries are truly sandboxed.
        ''
          cp -R --dereference "${sandboxedNonBin}" "$out"  # IF YOUR BUILD FAILS HERE, TRY SANDBOXING WITH "inplace"
        ''
      ;
    };
  });

  # symlink the non-binary files from the unsandboxed package,
  # patch them to use the sandboxed binaries,
  # and add some passthru metadata to enforce no lingering references to the unsandboxed binaries.
  sandboxNonBinaries = pkgName: unsandboxed: sandboxedBin: let
    sandboxedWithoutFixedRefs = symlinkDirs "non-bin" [ "etc" "share" ] pkgName unsandboxed;
  in fixHardcodedRefs unsandboxed sandboxedBin sandboxedWithoutFixedRefs;

  # take the nearly-final sandboxed package, with binaries and all else, and
  # populate passthru attributes the caller expects, like `checkSandboxed`.
  fixupMetaAndPassthru = pkgName: pkg: extraPassthru: pkg.overrideAttrs (finalAttrs: prevAttrs: let
    nonBin = (prevAttrs.passthru or {}).sandboxedNonBin or {};
  in {
    meta = (prevAttrs.meta or {}) // {
      # take precedence over non-sandboxed versions of the same binary.
      priority = ((prevAttrs.meta or {}).priority or 0) - 1;
    };
    passthru = (prevAttrs.passthru or {}) // extraPassthru // {
      checkSandboxed = runCommandLocal "${pkgName}-check-sandboxed" {
        nativeBuildInputs = [ file gnugrep sanebox ];
        buildInputs = builtins.map (out: finalAttrs.finalPackage."${out}") (finalAttrs.outputs or [ "out" ]);
      } ''
        set -e
        # invoke each binary in a way only the sandbox wrapper will recognize,
        # ensuring that every binary has in fact been wrapped.
        _numExec=0
        _checkExecutable() {
          local dir="$1"
          local binname="$2"
          echo "checking if $dir/$binname is sandboxed"
          # XXX: call by full path because some binaries (e.g. util-linux) would otherwise
          # be shadowed by things the nix builder implicitly puts on PATH.
          # additionally, call via qemu and manually specify the interpreter *if the file has one*.
          # if the file doesn't have an interpreter, assume it's directly invokable by qemu (hence, the intentional lack of quotes around `interpreter`)
          set -x
          local realbin="$(realpath $dir/$binname)"
          local interpreter=$(file "$realbin" | grep --only-matching "a /nix/.* script" | cut -d" " -f2 || echo "")
          ${stdenv.hostPlatform.emulator buildPackages} $interpreter "$dir/$binname" --sanebox-net-dev all --sanebox-dns default --sanebox-net-gateway default --sanebox-replace-cli echo "printing for test" \
            | grep "printing for test"
          _numExec=$(( $_numExec + 1 ))
        }
        _checkDir() {
          local dir="$1"
          for b in $(ls "$dir"); do
            if [ -d "$dir/$b" ]; then
              if [ "$b" != .sandboxed ]; then
                _checkDir "$dir/$b"
              fi
            elif [ -x "$dir/$b" ]; then
              _checkExecutable "$dir" "$b"
            else
              test -n "$CHECK_DIR_NON_BIN"
            fi
          done
        }

        for outDir in $buildInputs; do
          echo "starting crawl from package output: $outDir"
          # *everything* in the bin dir should be a wrapped executable
          if [ -e "$outDir/bin" ]; then
            echo "checking toplevel dir at $outDir/bin"
            _checkDir "$outDir/bin"
          fi

          # the libexec dir is 90% wrapped executables, but sometimes also .so/.la objects.
          # note that this directory isn't flat
          if [ -e "$outDir/libexec" ]; then
            echo "checking toplevel dir at $outDir/libexec"
            CHECK_DIR_NON_BIN=1 _checkDir "$outDir/libexec"
          fi
        done

        echo "successfully tested $_numExec binaries"
        test "$_numExec" -ne 0
        mkdir "$out"
        # forward prevAttrs checkSandboxed, to guarantee correctness for the /share directory (`sandboxNonBinaries`).
        ln -s ${nonBin.checkSandboxed or "/dev/null"} "$out/sandboxed-non-binaries"
      '';
    };
  });

  make-sandboxed = { pkgName, package, wrapperType, embedSandboxer ? false, extraSandboxerArgs ? [], passthru ? {} }@args:
  let
    unsandboxed = package;
    sanebox' = if embedSandboxer then
      # optionally hard-code the sandboxer. this forces rebuilds, but allows deep iteration w/o deploys.
      lib.getExe sanebox
    else
      #v prefer to load by bin name to reduce rebuilds
      sanebox.meta.mainProgram
    ;

    # two ways i could wrap a package in a sandbox:
    # 1. package.overrideAttrs, with `postFixup`.
    # 2. pkgs.symlinkJoin, creating an entirely new package which calls into the inner binaries.
    #
    # here we switch between the options.
    # regardless of which one is chosen here, all other options are exposed via `passthru`.
    sandboxedBy = {
      inplace = sandboxBinariesInPlace
        sanebox'
        extraSandboxerArgs
        pkgName
        (makeHookable unsandboxed);

      wrappedDerivation = let
        sandboxedBin = sandboxBinariesInPlace
          sanebox'
          extraSandboxerArgs
          pkgName
          (symlinkBinaries pkgName unsandboxed);
        sandboxedNonBin = sandboxNonBinaries pkgName unsandboxed sandboxedBin;
      in symlinkJoin {
        name = "${pkgName}-sandboxed-all";
        paths = [ sandboxedBin sandboxedNonBin ];
        passthru = { inherit sandboxedBin sandboxedNonBin unsandboxed; };
        # specifically, for priority
        meta = extractMeta sandboxedBin;
      };
    };
    packageWrapped = sandboxedBy."${wrapperType}";
  in
    fixupMetaAndPassthru pkgName packageWrapped (passthru // {
      # allow the user to build this package, but sandboxed in a different manner.
      # e.g. `<pkg>.sandboxedBy.inplace`.
      # e.g. `<pkg>.sandboxedBy.wrappedDerivation.sandboxedNonBin`
      inherit sandboxedBy;
    })
  ;
in make-sandboxed
