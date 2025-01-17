# Adapted from https://github.com/NixOS/nixpkgs/blob/9abb87b552b7f55ac8916b6fc9e5cb486656a2f3/pkgs/by-name/mi/misskey/package.nix

{
  lib,
  stdenv,
  fetchFromGitLab,
  makeWrapper,
  nodejs,
  pnpm,
  python3,
  xcbuild,
  bash,
  ffmpeg-headless,
  jemalloc,
  writeShellScript,
  callPackage,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sharkey";
  version = "2024.11.2";

  src = fetchFromGitLab {
    domain = "activitypub.software";
    owner = "TransFem-org";
    repo = "Sharkey";
    rev = "refs/tags/${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-ejrp6PBbpA5DIa8O1Ib7jZ3xsDrMkVEN4BMduJnjzBk=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpm.configHook
    python3
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ xcbuild.xcrun ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-7/N4ktYGOU+KQtOG32oJm/FEpR7shm0wlDWOThPVsgM=";
  };

  buildPhase = ''
    runHook preBuild

    # https://github.com/NixOS/nixpkgs/pull/296697/files#r1617546739
    (
      cd node_modules/.pnpm/node_modules/v-code-diff
      pnpm run postinstall
    )

    # https://github.com/NixOS/nixpkgs/pull/296697/files#r1617595593
    export npm_config_nodedir=${nodejs}
    (
      cd node_modules/.pnpm/node_modules/re2
      pnpm run rebuild
    )
    (
      cd node_modules/.pnpm/node_modules/sharp
      pnpm run install
    )

    pnpm build

    runHook postBuild
  '';

  installPhase =
    let
      checkEnvVarScript = writeShellScript "misskey-check-env-var" ''
        if [[ -z $MISSKEY_CONFIG_YML ]]; then
          echo "MISSKEY_CONFIG_YML must be set to the location of the Misskey config file."
          exit 1
        fi
      '';
    in
    ''
      runHook preInstall

      mkdir -p $out/data
      cp -r . $out/data

      # Set up symlink for use at runtime
      # TODO: Find a better solution for this (potentially patch Misskey to make this configurable?)
      # Line that would need to be patched: https://github.com/misskey-dev/misskey/blob/9849aab40283cbde2184e74d4795aec8ef8ccba3/packages/backend/src/core/InternalStorageService.ts#L18
      # Otherwise, maybe somehow bindmount a writable directory into <package>/data/files.
      ln -s /var/lib/misskey $out/data/files

      makeWrapper ${pnpm}/bin/pnpm $out/bin/misskey \
        --run "${checkEnvVarScript} || exit" \
        --chdir $out/data \
        --add-flags run \
        --set-default NODE_ENV production \
        --prefix PATH : ${
          lib.makeBinPath [
            bash
            nodejs
            pnpm
          ]
        } \
        --prefix LD_LIBRARY_PATH : ${
          lib.makeLibraryPath [
            ffmpeg-headless
            jemalloc
            stdenv.cc.cc
          ]
        }

      runHook postInstall
    '';

  passthru = {
    inherit (finalAttrs) pnpmDeps;
    tests.sharkey = callPackage ./nixos-test.nix { sharkey = finalAttrs.finalPackage; };
    updateScript = gitUpdater { };
  };

  meta = {
    mainProgram = "sharkey";
    description = "Sharkish microblogging platform";
    homepage = "https://activitypub.software/TransFem-org/Sharkey";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
