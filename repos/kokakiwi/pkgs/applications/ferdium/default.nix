{ lib
, stdenv
, stdenvNoCC

, fetchFromGitHub

, makeWrapper
, wrapGAppsHook

, cacert
, electron
, gitMinimal
, jq
, moreutils
, nodePackages
}: let
  fixupPackageJson = {
    pnpmPatch = builtins.toJSON {
      pnpm.supportedArchitectures = {
        os = [ "linux" ];
        cpu = [ "x64" "arm64" ];
      };
      engines = {
        node = nodePackages.nodejs.version;
        pnpm = nodePackages.pnpm.version;
        electron = electron.version;
      };
    };

    patch = ''
      mv package.json package.json.orig
      jq --raw-output ". * $pnpmPatch" package.json.orig > package.json
    '';
  };

  mkPnpmDeps = {
    pname,
    hash,
    ...
  } @ args: stdenvNoCC.mkDerivation ({
    pname = "${pname}-pnpm-deps";

    nativeBuildInputs = [
      cacert
      jq
      moreutils
      nodePackages.pnpm
    ];

    dontBuild = true;
    dontFixup = true;

    inherit (fixupPackageJson) pnpmPatch;
    postPatch = fixupPackageJson.patch;

    installPhase = ''
      export HOME=$(mktemp -d)

      pnpm config set store-dir $out
      pnpm install --frozen-lockfile --ignore-script

      rm -rf $out/v3/tmp
      for f in $(find $out -name "*.json"); do
        sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
        jq --sort-keys . $f | sponge $f
      done
    '';

    outputHashMode = "recursive";
    outputHash = hash;
  } // builtins.removeAttrs args [ "pname" "hash" ]);
in stdenv.mkDerivation (final: {
  pname = "ferdium";
  version = "6.7.3";

  src = fetchFromGitHub {
    owner = "ferdium";
    repo = "ferdium-app";
    rev = "v${final.version}";
    hash = "sha256-0EUYddv1Mang2aGKzOQpqSvVyHs5kbU/wboNOps91gc=";
  };

  recipes = stdenv.mkDerivation (recipesFinal: {
    pname = "${final.pname}-recipes";
    inherit (final) version;

    src = fetchFromGitHub {
      owner = "ferdium";
      repo = "ferdium-recipes";
      rev = "7ab6497fbd7bc64c3f2b17b587d273c9bbd155c8";
      hash = "sha256-QHTXYfCzP7psomXfD+0A0WZitSb/za/y7bnkijM2CyY=";
    };

    pnpmDeps = mkPnpmDeps {
      inherit (recipesFinal) pname version src;
      hash = "sha256-atEfRhrfJ+aWFgJMetcJzw0JwTdJJBFkS/GEplEuNAM=";
    };

    inherit (fixupPackageJson) pnpmPatch;
    postPatch = fixupPackageJson.patch;

    nativeBuildInputs = [
      jq
      nodePackages.pnpm
      nodePackages.nodejs
      gitMinimal
    ];

    preBuild = ''
      export HOME=$(mktemp -d)
      export STORE_PATH=$(mktemp -d)

      cp -Tr "$pnpmDeps" "$STORE_PATH"
      chmod -R +w "$STORE_PATH"

      pnpm config set store-dir "$STORE_PATH"
      pnpm install --offline --frozen-lockfile --ignore-script
      patchShebangs node_modules/{*,.*}
    '';

    postBuild = ''
      pnpm run package
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -T all.json $out/all.json
      cp -Tr archives $out/archives

      runHook postInstall
    '';
  });

  pnpmDeps = mkPnpmDeps {
    inherit (final) pname version src;
    hash = "sha256-TYcuQHDLcZkYvocVOO8X965ntcjgvyDc4L6N+miArIw=";
  };

  nativeBuildInputs = [
    nodePackages.pnpm
    nodePackages.nodejs
    makeWrapper
    jq
    wrapGAppsHook
  ];

  dontPatchShebangs = true;
  dontPatchELF = true;

  inherit (fixupPackageJson) pnpmPatch;
  postPatch = ''
    cat > src/electron/ipc-api/dnd.ts <<"EOF"
    import { ipcMain } from 'electron';
    export default async () => {
      ipcMain.handle('get-dnd', async () => {
        return false;
      });
    };
    EOF
  '' + fixupPackageJson.patch;

  preBuild = ''
    export HOME=$(mktemp -d)
    export STORE_PATH=$(mktemp -d)

    cp -Tr "$pnpmDeps" "$STORE_PATH"
    chmod -R +w "$STORE_PATH"

    pnpm config set store-dir "$STORE_PATH"
    pnpm install --offline --frozen-lockfile --ignore-script
    patchShebangs node_modules/{*,.*}

    cp -Tr "$recipes" recipes
  '';

  postBuild = ''
    pnpm manage-translations
    node esbuild.mjs

    cp -Tr node_modules build/node_modules
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share

    cp -Tr build $out/share/ferdium
    cp -Tr node_modules $out/share/ferdium/node_modules

    makeWrapper ${electron}/bin/electron $out/bin/ferdium \
      --set ELECTRON_IS_DEV 0 \
      --add-flags $out/share/ferdium

    runHook postInstall
  '';

  meta = {
    description = "All your services in one place built by the community";
    homepage = "https://ferdium.org/";
    license = lib.licenses.asl20;
    platforms = electron.meta.platforms;
    mainProgram = "ferdium";
  };
})
