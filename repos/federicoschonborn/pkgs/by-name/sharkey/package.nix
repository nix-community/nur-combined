# Adapted from https://github.com/NixOS/nixpkgs/blob/9abb87b552b7f55ac8916b6fc9e5cb486656a2f3/pkgs/by-name/mi/misskey/package.nix

{
  stdenv,
  lib,
  # nixosTests,
  fetchFromGitLab,
  # fetchpatch
  nodejs_22,
  pnpm_9,
  makeWrapper,
  python3,
  bash,
  jemalloc,
  ffmpeg-headless,
  writeShellScript,
  xcbuild,
  callPackage,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sharkey";
  version = "2025.2.3";

  src = fetchFromGitLab {
    domain = "activitypub.software";
    owner = "TransFem-org";
    repo = "Sharkey";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-VBfkJuoQzQ93sUmJNnr1JUjA2GQNgOIuX+j8nAz3bb4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    nodejs_22
    pnpm_9.configHook
    makeWrapper
    python3
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ xcbuild.xcrun ];

  # https://nixos.org/manual/nixpkgs/unstable/#javascript-pnpm
  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-ALstAaN8dr5qSnc/ly0hv+oaeKrYFQ3GhObYXOv4E6I=";
  };

  buildPhase = ''
    runHook preBuild

    # https://github.com/NixOS/nixpkgs/pull/296697/files#r1617546739
    (
      cd node_modules/.pnpm/node_modules/v-code-diff
      pnpm run postinstall
    )

    # https://github.com/NixOS/nixpkgs/pull/296697/files#r1617595593
    export npm_config_nodedir=${nodejs_22}
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

      makeWrapper ${pnpm_9}/bin/pnpm $out/bin/misskey \
        --run "${checkEnvVarScript} || exit" \
        --chdir $out/data \
        --add-flags run \
        --set-default NODE_ENV production \
        --prefix PATH : ${
          lib.makeBinPath [
            nodejs_22
            pnpm_9
            bash
          ]
        } \
        --prefix LD_LIBRARY_PATH : ${
          lib.makeLibraryPath [
            jemalloc
            ffmpeg-headless
            stdenv.cc.cc
          ]
        }

      runHook postInstall
    '';

  strictDeps = true;

  passthru = {
    inherit (finalAttrs) pnpmDeps;
    tests.sharkey = callPackage ./nixos-test.nix { sharkey = finalAttrs.finalPackage; };

    # nix-update is having a hard time calling the API
    updateScript = ./update.sh;
  };

  meta = {
    mainProgram = "sharkey";
    description = "Sharkish microblogging platform";
    homepage = "https://activitypub.software/TransFem-org/Sharkey";
    changelog = "https://activitypub.software/TransFem-org/Sharkey/-/releases/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
