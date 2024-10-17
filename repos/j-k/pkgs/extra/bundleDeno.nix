{
  lib,
  stdenvNoCC,
  deno,
  fetchDenoTarball,
}:

{
  name ? "${args.pname}-${args.version}",
  # SRI hash
  denoHash ? "",
  # Legacy hash
  denoSha256 ? "",
  # Name for the vendored dependencies tarball
  denoDepsName ? name,

  src ? null,
  srcs ? null,
  unpackPhase ? null,
  denoPatches ? [ ],
  patches ? [ ],
  sourceRoot ? null,
  logLevel ? "",
  buildInputs ? [ ],
  nativeBuildInputs ? [ ],
  denoUpdateHook ? "",
  denoDepsHook ? "",
  buildType ? "release",
  meta ? { },
  lockfileLocation ? "lock.json",
  denoVendorDir ? null,
  entrypoint,
  permissionsFlags ? [ ],
  outname ? (builtins.concatStringsSep "" (lib.flatten (builtins.split "(.*)\.ts$" entrypoint))),
  ...
}@args:

let
  denoDeps = fetchDenoTarball ({
    inherit
      src
      srcs
      sourceRoot
      unpackPhase
      lockfileLocation
      denoVendorDir
      entrypoint
      ;
    name = denoDepsName;
    hash = denoHash;
    patches = denoPatches;
    sha256 = denoSha256;
  });
in
stdenvNoCC.mkDerivation (
  args
  // {
    inherit denoDeps;

    nativeBuildInputs = nativeBuildInputs ++ [ deno ];

    postUnpack =
      ''
        unpackFile "${denoDeps}"
        export DENO_DIR="/build/$(stripHash "${denoDeps}")"
        export DENO_LOCK="$DENO_DIR/lockfile.json"
      ''
      + (args.postUnpack or "");

    configurePhase =
      args.configurePhase or ''
        runHook preConfigure
        runHook postConfigure
      '';

    buildPhase =
      args.buildPhase or ''
        runHook preBuild
        deno bundle --lock "$DENO_LOCK" "${entrypoint}" "${outname}.js"
        runHook postBuild
      '';

    installPhase =
      args.installPhase or ''
        runHook preInstall

        mkdir -p "$out"/{bin,"lib/${outname}"}
        mv "${outname}.js" "$out/lib/${outname}/"
        deno install --root "$out" --lock "$DENO_LOCK" $permissionsFlags "$out/lib/${outname}/${outname}.js"
        substituteInPlace "$out/bin/${outname}" --replace 'exec deno ' 'exec ${deno}/bin/deno '
        rm "$out/bin/${outname}.lock.json"

        runHook postInstall
      '';

    strictDeps = true;

    passthru = {
      inherit denoDeps;
    } // (args.passthru or { });

    meta = {
      # default to Deno's platforms
      platforms = deno.meta.platforms;
    } // meta;
  }
)
