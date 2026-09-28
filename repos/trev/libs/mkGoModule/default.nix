# Wraps buildGoModule, building the dependencies in a separate derivation
# (`goCache`) and restoring its build cache, so that source changes only
# rebuild the main module's packages.
#
# The dependency derivation only uses the vendor directory, so it doesn't change
# with the source or version. Go's build cache is content-addressed, entries are
# only reused when the compiler, flags and sources match.
{
  buildGoModule,
  lib,
  zstd,
}:

let
  # attributes that are specific to the real source or output. Unlike
  # mkRustPackage, go.mod is generated from vendor/modules.txt, so the source
  # isn't needed at all.
  depsExcludedArgs = [
    "src"
    "srcs"
    "sourceRoot"
    "goCache"
    "goCacheArgs"
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

  stripHash =
    name:
    if builtins.match "[0-9a-z]{32}-.*" name != null then builtins.substring 33 (-1) name else name;
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
      vendorHash,
      sourceRoot ? null,
      modRoot ? "./",
      nativeBuildInputs ? [ ],
      overrideModAttrs ? (finalAttrs: previousAttrs: { }),
      # extra arguments for the dependency derivation
      goCacheArgs ? { },
      ...
    }@args:

    assert lib.assertMsg (
      !(args.proxyVendor or false)
    ) "mkGoModule: proxyVendor is not supported, the dependencies are read from vendor/modules.txt";
    assert lib.assertMsg (vendorHash != null) "mkGoModule: vendorHash can't be null";

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
              # excluded by build constraints
              mapfile -t packages < <(
                go list -e "''${flags[@]}" -f '{{if not .Error}}{{.ImportPath}}{{end}}' \
                  $(grep -v '^#' vendor/modules.txt)
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
          }
        )).overrideAttrs
          (
            {
              # use the main derivation's vendor directory, so its source isn't needed
              inherit (finalAttrs) goModules;

              # the cache can contain store paths, e.g. of go when built without -trimpath
              disallowedReferences = [ ];
            }
            // goCacheArgs
          );
    in
    {
      goCache = args.goCache or goCache;

      # without the version, which would change the output path of the dependency
      # derivation on every version bump
      overrideModAttrs = lib.composeExtensions (_: _: {
        name = "${pname}-go-modules";
      }) (lib.toExtension overrideModAttrs);

      nativeBuildInputs = nativeBuildInputs ++ [ zstd ];

      postConfigure = ''
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

      passthru = {
        inherit goCache;
      }
      // args.passthru or { };
    };
}
