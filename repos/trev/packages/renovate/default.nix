{
  fetchFromGitHub,
  fetchPnpmDeps,
  lib,
  makeWrapper,
  nix-update-script,
  nixosTests,
  nodejs,
  pnpm,
  pnpmConfigHook,
  python3,
  stdenv,
  testers,
  xcbuild,
  yq-go,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "renovate";
  version = "42.80.1";

  src = fetchFromGitHub {
    owner = "renovatebot";
    repo = "renovate";
    tag = finalAttrs.version;
    hash = "sha256-YsZLXoTCfp8wZTCRsqij2SN/KewEuZ7v7RBh8PhO6xQ=";
  };

  patches = [
    ./37899.diff
  ];

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail "0.0.0-semantic-release" "${finalAttrs.version}"
  '';

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpm
    pnpmConfigHook
    python3
    yq-go
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin xcbuild;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-qE6c2lodopm1XHabijwcgehDgghEHRb9QGFcY8hvrFg=";
  };

  env.COREPACK_ENABLE_STRICT = 0;

  buildPhase = ''
    runHook preBuild

    # relax nodejs version
    yq '.engines.node = "${nodejs.version}"' -i package.json

    pnpm build
    pnpm install --offline --prod --ignore-scripts
  ''
  # The optional dependency re2 is not built by pnpm and needs to be built manually.
  # If re2 is not built, you will get an annoying warning when you run renovate.
  + ''
    pushd node_modules/.pnpm/re2*/node_modules/re2

    mkdir -p $HOME/.node-gyp/${nodejs.version}
    echo 9 > $HOME/.node-gyp/${nodejs.version}/installVersion
    ln -sfv ${nodejs}/include $HOME/.node-gyp/${nodejs.version}
    export npm_config_nodedir=${nodejs}
    npm run rebuild

    popd

    runHook postBuild
  '';

  # TODO: replace with `pnpm deploy`
  # now it fails to build with ERR_PNPM_NO_OFFLINE_META
  # see https://github.com/pnpm/pnpm/issues/5315
  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/node_modules/renovate}
    cp -r dist node_modules package.json renovate-schema.json $out/lib/node_modules/renovate

    makeWrapper "${lib.getExe nodejs}" "$out/bin/renovate" \
      --add-flags "$out/lib/node_modules/renovate/dist/renovate.js"
    makeWrapper "${lib.getExe nodejs}" "$out/bin/renovate-config-validator" \
      --add-flags "$out/lib/node_modules/renovate/dist/config-validator.js"

    runHook postInstall
  '';

  passthru = {
    tests = {
      version = testers.testVersion { package = finalAttrs.finalPackage; };
      vm-test = nixosTests.renovate;
    };
    updateScript = ''
      wget https://patch-diff.githubusercontent.com/raw/renovatebot/renovate/pull/37899.diff -O ./packages/renovate/37899.diff
      ${lib.concatStringsSep " " (nix-update-script {
        extraArgs = [
          "--commit"
          "${finalAttrs.pname}"
        ];
      })}
    '';
  };

  meta = {
    description = "Cross-platform dependency automation, with patches for nix";
    homepage = "https://github.com/renovatebot/renovate";
    changelog = "https://github.com/renovatebot/renovate/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "renovate";
    platforms = nodejs.meta.platforms;
  };
})
