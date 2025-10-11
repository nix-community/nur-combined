{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  buildGoModule,
  yarn-berry_3,
  jq,
  nodejs,
  makeWrapper,
  fixup-yarn-lock,
  pkgs,
  fetchurl,
  stdenv,
  hash,
}:

let
  version = "8.2.0";
  rev = "v${version}";

  src = fetchFromGitHub {
    owner = "SpecterOps";
    repo = "BloodHound";
    inherit rev;
    sha256 = hash;
  };

  # Collector binaries
  sharphoundVersion = "v2.7.2";
  azurehoundVersion = "v2.7.1";

  sharphound = fetchurl {
    url = "https://github.com/SpecterOps/SharpHound/releases/download/${sharphoundVersion}/SharpHound_${sharphoundVersion}_windows_x86.zip";
    sha256 = "sha256-bfdEJD+lwkQUBh6okW53RIbOrw+M71y8cB18Cpjxxzw=";
  };

  azurehound = fetchurl {
    url = "https://github.com/SpecterOps/AzureHound/releases/download/${azurehoundVersion}/AzureHound_${azurehoundVersion}_linux_amd64.zip";
    sha256 = "sha256-oLWZsHxod2mAmilDpnfucaX9wwBZg8sdXDKGYDg8bZ8=";
  };

  # BloodHound UI: Yarn Berry v3 derivation
  ui = stdenv.mkDerivation (finalAttrs: {
    pname = "bloodhound-ui";
    version = version;
    src = "${src}";

    missingHashes = ./missing-hashes.json;

    # https://nixos.org/manual/nixpkgs/unstable/#javascript-fetchYarnBerryDeps
    # https://nixos.org/manual/nixpkgs/unstable/#javascript-yarnBerry-missing-hashes
    #
    # generate yarn.lock in upstream BloodHound repo:
    # first we need to replace rollup with @rollup/wasm-node in package.json to avoid build errors
    # sed -i.bak -E 's#"rollup": *".*"#"rollup": "npm:@rollup/wasm-node@4.52.4"#' package.json`
    # then run `yarn install` in the top-level dir of the BloodHound repo to re-generate the yarn.lock file

    # copy the yarn.lock from the upstream BloodHound repo next to this package.nix file
    # then replace all occurences of git@github.com with https://github.com in the yarn.lock file to avoid ssh usage since nix builds have no ssh
    # => run: `sed -i.bak 's|git@github.com:\(.*\)\.git|https://github.com/\1.git|g' yarn.lock`
    offlineCache = yarn-berry_3.fetchYarnBerryDeps {
      yarnLock = ./yarn.lock;

      ###
      # Prefetch with yarn-berry-fetcher;
      # run `nix run nixpkgs#yarn-berry_3.yarn-berry-fetcher missing-hashes yarn.lock` in the top-level dir of the BloodHound repo
      # copy the entire JSON output into a file called `missing-hashes.json` next to the yarn.lock file in the BloodHound repo
      # then copy the missing-hashes.json file next to this package.nix file
      ###
      inherit (finalAttrs) src missingHashes postPatch;

      # After generating missing-hashes.json, generate the final hash:
      # run: `nix run nixpkgs#yarn-berry_3.yarn-berry-fetcher prefetch yarn.lock missing-hashes.json`
      # use the same yarn.lock file from the upstream bloodhound repo as before
      # then copy the resulting hash here:
      hash = "sha256-kczhcMig0CHRQOunFX6AR+CxACij9zg2d07OXT7xfbE=";
    };

    nativeBuildInputs = [
      makeWrapper
      yarn-berry_3.yarnBerryConfigHook
      yarn-berry_3
      jq
      #fixup-yarn-lock
      # typescript, rollup, etc. if needed
    ];

    # ensure the folder $TMPDIR/.yarn exists before yarn install
    patchPhase = ''
      mkdir -p $TMPDIR/.yarn
    '';

    env = {
      ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

      # Disable scripts for now, so that yarnBerryConfigHook does not try to build anything
      # before we can patchShebangs additional paths (see buildPhase).
      # https://github.com/NixOS/nixpkgs/blob/3cd051861c41df675cee20153bfd7befee120a98/pkgs/by-name/ya/yarn-berry/fetcher/yarn-berry-config-hook.sh#L83
      YARN_ENABLE_SCRIPTS = 0;
    };

    postPatch = ''
      # Don't automatically build everything
      sed -i '/postinstall/d' package.json
    '';

    # replace rollup with @rollup/wasm-node to avoid build errors
    configurePhase = ''
      # Yarn wants to write telemetry and cache to $HOME. Point it somewhere writable.
      export HOME=$TMPDIR
      export YARN_ENABLE_TELEMETRY=0

      cd $src/cmd/ui

      # Tell Yarn to use a writable location for its cache / PnP store
      export YARN_CACHE_FOLDER=$TMPDIR/.yarn
      export YARN_ENABLE_INLINE_BUILDS=0

      # Now install with the offline cache
      yarn install --immutable
    '';

    buildPhase = ''
      runHook preBuild

      unset YARN_ENABLE_SCRIPTS

      for node_modules in packages/*/node_modules; do
        patchShebangs $node_modules
      done

      yarn config set enableInlineBuilds true

      cd $src/cmd/ui
      yarn build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/dist
      cp -r cmd/ui/dist/* $out/dist/
      runHook postInstall
    '';

    doCheck = false;

    meta = with lib; {
      description = "BloodHound UI static assets—React/Vite/Sigma for AD path viz";
      platforms = platforms.linux;
    };
  });
in

buildGoModule rec {
  pname = "bloodhound-ce";
  inherit version src;
  goPackagePath = "github.com/specterops/bloodhound";
  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC=";

  nativeBuildInputs = [ nodejs ];

  buildInputs = [ ui ];

  env.CGO_ENABLED = 0;

  ldFlags = lib.concatStringsSep " " [
    "-X github.com/specterops/bloodhound/cmd/api/src/version.majorVersion=${lib.elemAt (lib.splitString "." version) 0}"
    "-X github.com/specterops/bloodhound/cmd/api/src/version.minorVersion=${lib.elemAt (lib.splitString "." version) 1}"
  ];

  preBuild = ''
    mkdir -p cmd/api/src/api/static/assets
    cp -r ${ui}/dist/* cmd/api/src/api/static/assets/
  '';

  postBuild = ''
    mkdir -p collectors/{sharphound,azurehound}
    cp ${sharphound} collectors/sharphound/
    cp ${azurehound} collectors/azurehound/
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/bloodhound $out/etc
    cp $GOPATH/bin/bhapi $out/bin/bloodhound
    cp -r collectors $out/share/bloodhound/
    cp -r ${ui}/dist $out/share/bloodhound/assets
    cp ${src}/dockerfiles/configs/bloodhound.config.json $out/etc/bloodhound.config.json
  '';

  doCheck = false;

  meta = with lib; {
    description = "BloodHound monolithic web application (Go REST API + React/Vite frontend)";
    homepage = "https://github.com/SpecterOps/BloodHound";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
}
