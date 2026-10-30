# Wraps buildGoModule, building the dependencies in a separate derivation
# (`goCache`) and restoring its build cache, so that source changes only
# rebuild the main module's packages.
#
# The dependency derivation only uses the vendor directory, so it doesn't change
# with the source or version. Go's build cache is content-addressed, entries are
# only reused when the compiler, flags and sources match.
#
# With `modules` (a gomod2nix.toml), `goModules` is built from its modules
# instead, so `vendorHash` isn't needed and is ignored. See ./vendor.nix.
#
# With `vendorHash = null` (no dependencies, or a vendor directory in the
# source) there's nothing to build separately, so `goCache` is null and this is
# a plain buildGoModule.
#
# Go names binaries after their package's directory (or module path), so when
# `meta.mainProgram` is set and the package installs a single binary, it's
# renamed to match.
#
# On Linux, binaries are built as position-independent executables
# (`-buildmode=pie`) for ASLR when cgo is enabled. On static platforms they're
# linked as static PIE binaries by the external linker. With CGO_ENABLED=0 go's
# own linker is used, which can't build static PIE binaries, so they're left
# static. `pie = false` disables it.
{
  buildGoModule,
  callPackage,
  lib,
  stdenv,
  zstd,
}:

let
  importGoModules = callPackage ./vendor.nix { };

  # attributes that are specific to the real source or output. Unlike
  # mkRustPackage, go.mod is generated from vendor/modules.txt, so the source
  # isn't needed at all.
  depsExcludedArgs = [
    "src"
    "srcs"
    "sourceRoot"
    "goCache"
    "goCacheArgs"
    "modules"
    "overrideModAttrs"
    "modPostBuild"
    "modConfigurePhase"
    "deleteVendor"
    "subPackages"
    "excludedPackages"
    "ldflags"
    "buildTestBinaries"
    "patches"
    "preUnpack"
    "unpackPhase"
    "postUnpack"
    "prePatch"
    "patchPhase"
    "postPatch"
    "preConfigure"
    "configurePhase"
    "postConfigure"
    "preBuild"
    "buildPhase"
    "postBuild"
    "doCheck"
    "checkFlags"
    "preCheck"
    "checkPhase"
    "postCheck"
    "preInstall"
    "installPhase"
    "postInstall"
    "doInstallCheck"
    "preInstallCheck"
    "installCheckPhase"
    "postInstallCheck"
    "nativeInstallCheckInputs"
    "installCheckInputs"
    "outputs"
    "separateDebugInfo"
    "preFixup"
    "fixupPhase"
    "postFixup"
    "passthru"
    "meta"
    "name"
    "pname"
    "version"
  ];

  # architectures go supports -buildmode=pie on for linux
  pieArchs = [
    "386"
    "amd64"
    "arm"
    "arm64"
    "loong64"
    "ppc64le"
    "riscv64"
    "s390x"
  ];

  # GOFLAGS can't be passed to buildGoModule, so the build mode is added in the
  # shell. CGO_ENABLED is checked there so overriding it is respected: without
  # cgo go can't use an external linker, and its own can't link PIE everywhere.
  setBuildMode = ''
    if [ -n "''${pie-}" ] && [ "''${CGO_ENABLED-}" != 0 ]; then
      export GOFLAGS="$GOFLAGS -buildmode=pie"
      ${lib.optionalString stdenv.hostPlatform.isStatic ''
        # go's linker would need a dynamic loader for PIE binaries, and with the
        # static stdenv's -static gcc uses the startup files for non-PIE ones
        ldflags+=(-linkmode=external)
        NIX_CFLAGS_LINK=" ''${NIX_CFLAGS_LINK-} "
        export NIX_CFLAGS_LINK="''${NIX_CFLAGS_LINK// -static / -static-pie }"
      ''}
    fi
  '';

  stripHash =
    name:
    if builtins.match "[0-9a-z]{32}-.*" name != null then builtins.substring 33 (-1) name else name;

  # path of a directory relative to the unpacked source, inside `src`
  srcPath =
    {
      src,
      sourceRoot ? null,
      ...
    }:
    dir:
    lib.concatStringsSep "/" (
      [ "${src}" ]
      ++ lib.filter (part: part != "" && part != ".") (
        lib.optionals (sourceRoot != null) (lib.drop 1 (lib.splitString "/" sourceRoot))
        ++ lib.splitString "/" dir
      )
    );
in

lib.extendMkDerivation {
  constructDrv = buildGoModule;

  excludeDrvArgNames = [
    "goCacheArgs"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      src,
      vendorHash ? throw "mkGoModule: either vendorHash or modules is required",
      # path to a gomod2nix.toml, to fetch the dependencies without vendorHash
      modules ? null,
      sourceRoot ? null,
      modRoot ? "./",
      nativeBuildInputs ? [ ],
      overrideModAttrs ? (finalAttrs: previousAttrs: { }),
      # extra arguments for the dependency derivation
      goCacheArgs ? { },
      # position-independent executables, only used with cgo
      pie ? stdenv.hostPlatform.isLinux && lib.elem stdenv.hostPlatform.go.GOARCH pieArchs,
      ...
    }@args:

    assert lib.assertMsg (
      !(args.proxyVendor or false)
    ) "mkGoModule: proxyVendor is not supported, the dependencies are read from vendor/modules.txt";

    let
      pname = args.pname or (lib.getName args.name);

      # directory the source is unpacked to. Without -trimpath (which the check
      # phase removes) build cache entries depend on the absolute path of the
      # vendor directory, so the dependency derivation uses the same one.
      srcDir =
        if sourceRoot != null then
          sourceRoot
        else
          stripHash (baseNameOf (builtins.unsafeDiscardStringContext "${src}"));

      goCache =
        if modules == null && vendorHash == null then
          null
        else
          (buildGoModule (
            removeAttrs args depsExcludedArgs
            // {
              # without the version, which would change the output path
              name = "${pname}-go-deps";

              src = null;
              dontUnpack = true;

              nativeBuildInputs = nativeBuildInputs ++ [ zstd ];

              preConfigure = ''
                mkdir -p "$NIX_BUILD_TOP"/${lib.escapeShellArg srcDir}/"$modRoot"
                cd "$NIX_BUILD_TOP"/${lib.escapeShellArg srcDir}
              '';

              # go.mod has to be consistent with vendor/modules.txt, which lists the
              # explicit requirements, replacements and go versions
              postConfigure = ''
                ${setBuildMode}
                awk '
                  BEGIN { print "module nix-go-deps\n\ngo ${lib.versions.majorMinor finalAttrs.passthru.go.version}\n" }
                  /^# / {
                    sub(/^# /, "")
                    mod = $0
                    split($0, parts, " => ")
                    replace = index($0, " => ") ? parts[2] : ""
                    split(parts[1], left, " ")
                    path = left[1]; version = left[2]
                    if (replace != "") print "replace " parts[1] " => " replace
                    next
                  }
                  /^## explicit/ && version != "" { print "require " path " " version }
                ' vendor/modules.txt > go.mod
              '';

              buildPhase = ''
                runHook preBuild

                flags=(''${tags:+-tags=$(concatStringsSep "," tags)} -p "$NIX_BUILD_CORES")

                # vendor/modules.txt lists every vendored package, including ones
                # excluded by build constraints. With gomod2nix.toml it lists every
                # package of the modules, which may import modules that aren't
                # vendored, go doesn't build anything when one of them is passed.
                # gomod2nix.toml generated with --with-deps lists the imported ones.
                mapfile -t packages < <(
                  go list -e "''${flags[@]}" -f '{{if not (or .Error .DepsErrors)}}{{.ImportPath}}{{end}}' \
                    ''${cachePackages:-$(grep -v '^#' vendor/modules.txt)}
                )
                echo "Building ''${#packages[@]} dependency packages"

                # packages that aren't used by the main module may need missing inputs,
                # those are left to the real build
                go build "''${flags[@]}" "''${packages[@]}" \
                  || echo "Some dependency packages failed to build, they'll be built in the main derivation"

                if [ -n "$buildTestDeps" ]; then
                  echo "Building dependency packages without -trimpath for the check phase"
                  GOFLAGS="''${GOFLAGS//-trimpath/}" go build "''${flags[@]}" "''${packages[@]}" testing testing/internal/testdeps \
                    || echo "Some dependency packages failed to build, they'll be built in the main derivation"
                fi

                runHook postBuild
              '';

              cachePackages = lib.optionals (modules != null) (lib.importTOML modules).cachePackages or [ ];

              buildTestDeps = finalAttrs.doCheck;
              doCheck = false;

              installPhase = ''
                runHook preInstall

                mkdir -p $out
                echo "$PWD" > $out/dir
                tar --create --owner=0 --group=0 --numeric-owner -C "$GOCACHE" . \
                  | zstd -T$NIX_BUILD_CORES -o $out/cache.tar.zst

                runHook postInstall
              '';

              dontFixup = true;

              # buildGoModule defaults to go's platforms, which don't include
              # e.g. windows, so use the main derivation's
              meta = lib.intersectAttrs {
                platforms = null;
                badPlatforms = null;
              } finalAttrs.meta;
            }
          )).overrideAttrs
            (
              {
                # use the main derivation's vendor directory, so its source isn't needed
                inherit (finalAttrs) goModules vendorHash;

                # the build mode changes how packages are compiled
                inherit (finalAttrs) pie;

                # the cache can contain store paths, e.g. of go when built without -trimpath
                disallowedReferences = [ ];
              }
              // goCacheArgs
            );
    in
    {
      goCache = args.goCache or goCache;

      inherit pie;

      # buildGoModule only copies `goModules` with a vendorHash, the derivation it
      # would use is replaced (see transformDrv)
      vendorHash = if modules != null then "" else vendorHash;

      # without the version, which would change the output path of the dependency
      # derivation on every version bump
      overrideModAttrs = lib.composeExtensions (_: _: {
        name = "${pname}-go-modules";
      }) (lib.toExtension overrideModAttrs);

      nativeBuildInputs = nativeBuildInputs ++ [ zstd ];

      postConfigure = ''
        ${setBuildMode}
        if [ -n "''${goCache-}" ]; then
          echo "Restoring go build cache from $goCache"
          mkdir -p "$GOCACHE"
          # with fresh modification times, go deletes entries unused for 5 days
          zstd -d "$goCache/cache.tar.zst" --stdout | tar --extract --touch -C "$GOCACHE"
          if [ "$(cat "$goCache/dir")" != "$PWD" ]; then
            echo "Build directory differs from $(cat "$goCache/dir"), dependencies of tests will be rebuilt"
          fi
        fi
      ''
      + args.postConfigure or "";

      # before the package's own postInstall, so it sees the final name
      postInstall =
        lib.optionalString (finalAttrs.meta.mainProgram or null != null) ''
          (
            shopt -s nullglob
            mainProgram=${lib.escapeShellArg finalAttrs.meta.mainProgram}${stdenv.hostPlatform.extensions.executable}
            binaries=("$out"/bin/*)
            if [ ! -e "$out/bin/$mainProgram" ]; then
              if [ "''${#binaries[@]}" -eq 1 ]; then
                echo "Renaming $(basename "''${binaries[0]}") to $mainProgram"
                mv "''${binaries[0]}" "$out/bin/$mainProgram"
              else
                echo "Not renaming binaries to $mainProgram, $out/bin has ''${#binaries[@]} entries"
              fi
            fi
          )
        ''
        + args.postInstall or "";

      passthru = {
        inherit goCache;
      }
      // args.passthru or { };
    };

  # buildGoModule always defines `goModules`, so it's replaced afterwards
  transformDrv =
    drv:
    drv.overrideAttrs (
      finalAttrs: previousAttrs: {
        goModules =
          if finalAttrs.modules or null != null then
            importGoModules {
              pname = finalAttrs.pname or (lib.getName finalAttrs.name);
              inherit (finalAttrs) modules;
              inherit (finalAttrs.passthru) go;
              modDir = srcPath finalAttrs finalAttrs.modRoot;
            }
          else
            previousAttrs.goModules;
      }
    );
}
