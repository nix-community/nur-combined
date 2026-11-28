{
  lib,
  stdenv,
  buildNpmPackage,
  importNpmLock,
  callPackage,
  autoPatchelfHook,
  esbuild,
  nodejs,
  piBundleHook,

  sources,
  source ? sources.pi-fff,
}:

let
  libExt = stdenv.hostPlatform.extensions.sharedLibrary;
in
buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  sourceRoot = "${finalAttrs.src.name}/packages";

  npmDeps =
    let
      rootPkg = {
        name = "pi-fff-deps";
        version = source.version;
        dependencies = {
          inherit (source.npmDeps.packageLock.packages."fff-node".dependencies) ffi-rs;
        };
      };
    in
    importNpmLock {
      package = rootPkg;
      packageLock = source.npmDeps.packageLock // {
        packages = {
          "" = rootPkg;
        }
        // lib.filterAttrs (
          name: _: name == "node_modules/ffi-rs" || lib.hasPrefix "node_modules/@yuuang/ffi-rs-" name
        ) source.npmDeps.packageLock.packages;
      };
    };
  npmConfigHook = importNpmLock.npmConfigHook;

  # Pi loads this extension directly; keep Node out of the runtime closure.
  dontPatchShebangs = true;

  nativeBuildInputs = [
    esbuild
    piBundleHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  postPatch = ''
    substituteInPlace fff-node/src/binary.ts \
      --replace-fail 'export function findBinary(): string | null {' \
        'export function findBinary(): string | null { return process.env.FFF_C_LIB || "${finalAttrs.passthru.native}/lib/libfff_c${libExt}";'
  '';

  npmFlags = [ "--ignore-scripts" ];
  dontNpmPrune = true;

  buildPhase = ''
    runHook preBuild

    esbuild fff-node/src/index.ts \
      --bundle \
      --platform=node \
      --format=esm \
      --external:ffi-rs \
      --outfile=fff-node/dist/index.js

    runHook postBuild
  '';

  piBundleKeepNodeModules = true;
  piBundleEsbuildFlags = [
    "--external:@ff-labs/fff-bun"
    "--external:ffi-rs"
  ];
  piBundleCleanPaths = [
    "node_modules/@ff-labs"
  ];

  installPhase = ''
    runHook preInstall

    pkg=$out/lib/${finalAttrs.pname}
    mkdir -p "$pkg/node_modules/@ff-labs" "$pkg/node_modules/@yuuang"
    cp -r pi-fff/{package.json,pi-fff.schema.json,src} "$pkg/"
    cp ../LICENSE "$pkg/"
    cp -r fff-node "$pkg/node_modules/@ff-labs/fff-node"
    cp -r node_modules/ffi-rs "$pkg/node_modules/"
    for dir in node_modules/@yuuang/ffi-rs-*; do
      if [ -d "$dir" ]; then
        case "$dir" in
          ${if stdenv.hostPlatform.isMusl then "*-gnu" else "*-musl"}) ;;
          *) cp -r "$dir" "$pkg/node_modules/@yuuang/" ;;
        esac
      fi
    done

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    pushd $out/lib/${finalAttrs.pname}
    node --input-type=module -e "
      import { open, close } from 'ffi-rs';
      open({ library: 'fff_c', path: '${finalAttrs.passthru.native}/lib/libfff_c${libExt}' });
      close('fff_c');
    "
    popd

    runHook postInstallCheck
  '';

  disallowedReferences = [ nodejs ];

  passthru.native = callPackage ./native.nix {
    inherit source;
    meta = finalAttrs.meta;
  };

  meta = {
    description = "FFF-powered fuzzy file and content search extension for the Pi coding agent";
    homepage = "https://github.com/dmtrKovalenko/fff/tree/main/packages/pi-fff";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = with lib.platforms; linux ++ darwin;
  };
})
