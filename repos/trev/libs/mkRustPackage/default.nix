# Wraps rustPlatform.buildRustPackage, building the dependencies in a separate
# derivation (`cargoArtifacts`) from a stubbed copy of the workspace, so that
# source changes only rebuild the workspace crates.
#
# Dependencies are vendored with importCargoLock from Cargo.lock (read from
# `src`, or `cargoLock.lockFile`/`cargoLock.lockFileContents`), so `cargoHash`
# isn't needed and is ignored. Both derivations use the vendor directory from
# the store, as cargo fingerprints registry crates by their path.
{
  lib,
  runCommandLocal,
  rustPlatform,
  zstd,
}:

let
  mkDummySrc = import ./dummySrc.nix { inherit lib runCommandLocal; };

  # attributes that are specific to the real source or output. The check phase is
  # kept, so the dependencies of custom check commands (e.g. cargo clippy) are
  # built too. It runs against the stubs, so it can't rely on other source files,
  # override it with `cargoArtifactsArgs.checkPhase` if it does.
  depsExcludedArgs = [
    "src"
    "srcs"
    "cargoArtifacts"
    "cargoArtifactsArgs"
    "cargoHash"
    "cargoLock"
    "cargoDeps"
    "cargoDepsName"
    "cargoDepsHook"
    "cargoPatches"
    "depsExtraArgs"
    "patches"
    "preUnpack"
    "unpackPhase"
    "postUnpack"
    "prePatch"
    "patchPhase"
    "postPatch"
    "preConfigure"
    "postConfigure"
    "preBuild"
    "buildPhase"
    "postBuild"
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

  # relative to the source root, a symlink to the vendor directory
  cargoVendorDir = ".nix-cargo-vendor";

  # importCargoLock's config points to a relative directory, replace it with the
  # vendor directory's real path, which cargoSetupHook substitutes for @vendor@
  mkVendor =
    cargoLock:
    let
      vendor = rustPlatform.importCargoLock cargoLock;
    in
    runCommandLocal "cargo-vendor-dir" { } ''
      mkdir -p $out/.cargo
      ln -s ${vendor}/* $out/
      substitute ${vendor}/.cargo/config.toml $out/.cargo/config.toml \
        --replace-fail 'directory = "cargo-vendor-dir"' 'directory = "@vendor@"'
    '';

  linkVendor = vendor: ''
    ln -s ${vendor} "$sourceRoot/''${cargoRoot:+$cargoRoot/}${cargoVendorDir}"
  '';

  stripHash =
    name:
    if builtins.match "[0-9a-z]{32}-.*" name != null then builtins.substring 33 (-1) name else name;
in

lib.extendMkDerivation {
  constructDrv = rustPlatform.buildRustPackage;

  excludeDrvArgNames = [
    "cargoArtifactsArgs"
    "cargoHash"
    "cargoLock"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      src,
      sourceRoot ? null,
      cargoRoot ? null,
      nativeBuildInputs ? [ ],
      cargoLock ? { },
      # extra arguments for the dependency derivation
      cargoArtifactsArgs ? { },
      ...
    }@args:

    assert lib.assertMsg (
      !(args ? cargoVendorDir || args ? cargoDeps)
    ) "mkRustPackage: cargoVendorDir and cargoDeps are not supported, use cargoLock instead";

    let
      srcName = stripHash (baseNameOf (builtins.unsafeDiscardStringContext "${src}"));

      # path of the workspace relative to `src`
      cargoDir = lib.concatStringsSep "/" (
        lib.filter (s: s != "") [
          (lib.concatStringsSep "/" (lib.drop 1 (lib.splitString "/" (toString sourceRoot))))
          (toString cargoRoot)
        ]
      );

      lockFileContents =
        cargoLock.lockFileContents or (builtins.unsafeDiscardStringContext (
          builtins.readFile (
            cargoLock.lockFile or "${src}${lib.optionalString (cargoDir != "") "/${cargoDir}"}/Cargo.lock"
          )
        ));

      dummySrc = mkDummySrc {
        inherit src cargoDir lockFileContents;
        name = srcName;
      };

      # vendored from the normalized lockfile, so it doesn't change with the version
      vendor = mkVendor (
        {
          allowBuiltinFetchGit = !(cargoLock ? outputHashes);
        }
        // removeAttrs cargoLock [
          "lockFile"
          "lockFileContents"
        ]
        // {
          inherit (dummySrc) lockFileContents;
        }
      );

      cargoArtifacts = rustPlatform.buildRustPackage (
        removeAttrs args depsExcludedArgs
        // {
          # without the version, which would change the output path
          name = "${args.pname or (lib.getName args.name)}-deps";

          src = dummySrc;

          inherit cargoVendorDir;
          cargoDepsHook = linkVendor vendor;

          nativeBuildInputs = nativeBuildInputs ++ [ zstd ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out
            tar --create --owner=0 --group=0 --numeric-owner target \
              | zstd -T$NIX_BUILD_CORES -o $out/target.tar.zst

            runHook postInstall
          '';

          dontFixup = true;
        }
        // cargoArtifactsArgs
      );
    in
    {
      cargoArtifacts = args.cargoArtifacts or cargoArtifacts;

      inherit cargoVendorDir;
      cargoDepsHook = linkVendor vendor + args.cargoDepsHook or "";

      nativeBuildInputs = nativeBuildInputs ++ [ zstd ];

      preBuild = ''
        if [ -n "''${cargoArtifacts-}" ]; then
          echo "Restoring cargo artifacts from $cargoArtifacts"
          zstd -d "$cargoArtifacts/target.tar.zst" --stdout | tar --extract
          # workspace crates were built from stubs, make the real sources newer
          find . -path ./target -prune -o -type f -exec touch {} +
        fi
      ''
      + args.preBuild or "";
    };
}
