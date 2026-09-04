{
  buildPackages,
  buildNpmPackage,
  cacert,
  curl,
  fetchNpmDeps,
  jq,
  lib,
  openssl,
  moreutils,
}:
lib.extendMkDerivation {
  constructDrv = buildNpmPackage;

  extendDrvArgs =
    finalAttrs:
    {
      npmDepsHash ? lib.fakeHash,
      npmDepsFetcherVersion ? 2,
      postInstall ? "",
      ...
    }:
    let
      npmDeps = fetchNpmDeps {
        inherit (finalAttrs) src;
        nativeBuildInputs = [
          cacert  # else `nix-update-script` fails to update the npmDepsHash
          curl
          moreutils
          openssl
          jq
        ];
        prePatch = finalAttrs.prePatch or "";
        patches = finalAttrs.patches or [];
        # the pi-monorepo shrinkwrap doesn't specify integrity hashes for its @earendil-works/* dependencies;
        # probably because they're all built together, so they can't specify those without circularity.
        # the effect is that any package which places `pi-coding-assistant` into `peerDependencies`
        # gets additional unhashed peerDependencies, which `fetchNpmDeps` complains about.
        #
        # locate all missing `integrity` fields and pre-populate them. it seems to me that these
        # integrity fields are redundant with `fetchNpmDeps` own `hash` value anyway.
        postPatch = ''
          echo '{}' > extra-integrities.json
          while IFS=$'\t' read -r package_name resolved; do
            [[ -n $package_name ]] || continue

            printf 'calculating integrity for %s\n' "$package_name" >&2
            integrity=$(
              curl --fail --location --silent --show-error --retry 3 "$resolved" \
                | openssl dgst -sha512 -binary \
                | base64 --wrap=0
            )
            integrity="sha512-$integrity"

            jq --arg name "$package_name" --arg integrity "$integrity" \
              '.packages[$name].integrity = $integrity' \
              "extra-integrities.json" | sponge extra-integrities.json
          done < <(
            jq -r '
              .packages
              | to_entries[]
              | select((.value.integrity? | not) and (.value.resolved? // "" | startswith("http")))
              | [.key, .value.resolved]
              | @tsv
            ' "package-lock.json"
          )
          jq --slurp '.[0] * .[1]' package-lock.json extra-integrities.json \
            | sponge package-lock.json
          ${finalAttrs.postPatch or ""}
        '';
        preFixup = ''
          cp extra-integrities.json $out/extra-integrities.json
        '';
        sourceRoot = finalAttrs.sourceRoot or null;
        hash = npmDepsHash;
        fetcherVersion = npmDepsFetcherVersion;
      };
    in
    {
      inherit npmDeps;
      patchPhase = ''
        runHook prePatch
        ${lib.getExe buildPackages.jq} --slurp '.[0] * .[1]' package-lock.json "$npmDeps/extra-integrities.json" \
          | ${lib.getExe' buildPackages.moreutils "sponge"} package-lock.json
        runHook postPatch
      '';

      # N.B.: postInstall, not installPhase so that npmInstallHook runs
      postInstall = ''
        packageName=$(${lib.getExe buildPackages.jq} --raw-output '.name' package.json)
        packagePath="$out/lib/node_modules/$packageName"

        # pi needs package.json to be at the root and does not handle symlinks correctly.
        # meanwhile, $out/bin/* wraps $out/lib/node_modules/$packageName/... so we have to keep those paths valid.
        # solution: lift $out/lib/node_modules/$packageName up to the root and replace the old path with a symlink to the new path.
        # N.B.: shopt -s dotglob so that we get the dotfiles too.
        (
          shopt -s dotglob
          mv "$packagePath"/* "$out/"
        )
        rmdir "$packagePath"
        ln -s $out "$packagePath"
        ${postInstall}
      '';
    };
  }
