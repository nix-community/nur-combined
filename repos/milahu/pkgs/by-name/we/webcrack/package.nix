{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  nodejs,
  python3,
  node-gyp,
  # callPackage,
}:

/*
let
  prebuildify = callPackage ./prebuildify { };
in
*/

stdenv.mkDerivation (finalAttrs: {
  pname = "webcrack";
  version = "2.16.0";

  /*
  passthru = {
    inherit prebuildify;
  };
  */

  src = fetchFromGitHub {
    owner = "j4k0xb";
    repo = "webcrack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IalU/wio1cNCr6K7Pa1neHVpnO2md4Ey6YmtReE3r+8=";
  };

  buildInputs = [
    # for patchShebangs of webcrack/dist/cli.js
    nodejs
  ];

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    python3
    node-gyp
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-l2thuPuhasRDMHnftVV/onSxK2qRwbwR51xgVzAxv4w=";
  };

  # this would be necessary to run "npm run prebuild"
  # but then it still tries to fetch node headers...
  /*
      # FIXME Error: Cannot find module 'prebuildify/bin.js'
      # transitive devDependencies are not stored in pnpm-lock.yaml
      # packages/webcrack/package.json -> isolated-vm -> prebuildify
      # todo: prebuildify should be in dependencies, not in devDependencies
      ln -s ${prebuildify}/lib/node_modules/prebuildify node_modules/prebuildify

      # FIXME gyp http fetch GET https://nodejs.org/dist/v22.22.0/node-v22.22.0-headers.tar.gz attempt 1 failed with EAI_AGAIN
      # scripts/run-prebuild.js fails in offline build

      # https://github.com/laverdet/isolated-vm/blob/f9f46c49d04db87ffade8033e8de61cba1109ab4/
      # isolated-vm/scripts/run-prebuild.js pins nodejs 22.22.0 and nodejs 24.14.0
      # but we only have nodejs 24.14.1
      sed -i -E ":a;N;\$!ba;
        s/(,[[:space:]]*'--target'[[:space:]]*,[[:space:]]*'[^']*')+/,'--target','${nodejs.version}'/g" \
        scripts/run-prebuild.js

      npm run prebuild
  */

  buildPhase = ''
    runHook preBuild

    echo building isolated-vm
    # fix:
    # Error: No native build was found for platform=linux arch=x64 runtime=node abi=141 uv=1 libc=glibc node=25.9.0
    # loaded from: node_modules/.pnpm/isolated-vm@6.1.2/node_modules/isolated-vm
    for d in node_modules/.pnpm/isolated-vm@*; do
      pushd $d/node_modules/isolated-vm
      # scripts/run-prebuild.js would pass more arguments to node-gyp like
      # node-gyp rebuild --target=22.22.2 --devdir=/build/prebuildify/node --arch=x64 --release
      # but we need only:
      node-gyp rebuild
      # remove extra build files
      mv build/Release/isolated_vm.node .
      rm -rf build
      mkdir -p build/Release
      mv isolated_vm.node build/Release
      popd
    done

    echo building webcrack
    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # prune node_modules from 488MB to 282MB
    # no. Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'commander' imported from webcrack/dist/cli.js
    # https://github.com/pnpm/pnpm/issues/8307
    # pnpm prune removes all dependencies
    # CI=true pnpm prune --prod --no-optional
    shopt -s nullglob
    for dir in $(
      awk "
        /^packages:/ { p=1; next }
        p && /^[[:space:]]*(#|$)/ { next }
        p && /^[^[:space:]-]/ { exit }
        p && /^[[:space:]]*-/ {
          gsub(/^[[:space:]]*-[[:space:]]*[\"']?|[\"']?$/, \"\")
          print
        }
      " pnpm-workspace.yaml
    ); do
      [ -d "$dir" ] || continue
      pushd "$dir"
      echo "pruning $dir/node_modules"
      CI=true pnpm prune --prod --no-optional
      popd
    done

    # Clean up broken symlinks left behind by `pnpm prune`
    # https://github.com/pnpm/pnpm/issues/3645
    find node_modules -xtype l -delete

    mkdir -p $out/lib/node_modules

    # no, this would produce dangling symlinks
    # cp -r packages/webcrack $out/lib/node_modules/webcrack

    # copy the whole pnpm workspace
    # maybe users also need result/lib/node_modules/webcrack/apps/*
    cp -r . $out/lib/node_modules/webcrack

    mkdir $out/bin
    ln -sr $out/lib/node_modules/webcrack/packages/webcrack/dist/cli.js $out/bin/webcrack

    runHook postInstall
  '';

  meta = {
    description = "Deobfuscate obfuscator.io, unminify and unpack bundled javascript";
    homepage = "https://github.com/j4k0xb/webcrack";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "webcrack";
    platforms = lib.platforms.all;
  };
})
