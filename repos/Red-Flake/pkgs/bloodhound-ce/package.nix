{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  buildGoModule,
  yarn-berry_3,
  fixup-yarn-lock,
  typescript,
  nodejs,
  nodePackages,
  fetchurl,
  pkg-config,
  pkgs,
  hash, # from default.nix
}:
let
  #### User-adjustable parameters ####
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
  sharphoundUrl = "https://github.com/SpecterOps/SharpHound/releases/download/${sharphoundVersion}/SharpHound_${sharphoundVersion}_windows_x86.zip";
  azurehoundUrl = "https://github.com/SpecterOps/AzureHound/releases/download/${azurehoundVersion}/AzureHound_${azurehoundVersion}_linux_amd64.zip";
  sharphound = fetchurl {
    url = sharphoundUrl;
    sha256 = "sha256-bfdEJD+lwkQUBh6okW53RIbOrw+M71y8cB18Cpjxxzw="; # Update from nix-prefetch-url --unpack
  };
  azurehound = fetchurl {
    url = azurehoundUrl;
    sha256 = "sha256-oLWZsHxod2mAmilDpnfucaX9wwBZg8sdXDKGYDg8bZ8="; # Update from nix-prefetch-url --unpack
  };

  # UI build: stdenv.mkDerivation with Yarn Berry v3 hooks (matches upstream yarn.lock __metadata version: 6)
  ui = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "bloodhound-ui";
    inherit version;

    src = src; # Full monorepo for workspace resolution (bh-shared-ui, @bloodhound/types for Sigma graph types)

    # https://nixos.org/manual/nixpkgs/unstable/#javascript-fetchYarnBerryDeps
    # https://nixos.org/manual/nixpkgs/unstable/#javascript-yarnBerry-missing-hashes
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
      missingHashes = ./missing-hashes.json;

      # After generating missing-hashes.json, generate the final hash:
      # run: `nix run nixpkgs#yarn-berry_3.yarn-berry-fetcher prefetch yarn.lock missing-hashes.json`
      # use the same yarn.lock file from the upstream bloodhound repo as before
      # the copy the resulting hash here:
      hash = "sha256-Mt2Z8HTFwl4W2H4xsvrOcD5Kxr8SvKEUo07+hU1No5E=";
    };

    nativeBuildInputs = [
      nodejs
      yarn-berry_3
      yarn-berry_3.yarnBerryConfigHook # Installs deps from offlineCache to node_modules (hoists workspace:*)
      fixup-yarn-lock
      typescript
    ];

    # Native toolchain for tree-sitter bindings (YAML/JSON grammars in UI for SharpHound JSON preview pre-ingest)
    buildInputs = [
      pkgs.python3
      pkgs.gcc
      pkgs.pkg-config
    ];

    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

    strictDeps = true;

    dontConfigure = true;

    buildPhase = ''
      # this line removes a bug where value of $HOME is set to a non-writable /homeless-shelter dir
      export HOME=$(pwd)

      runHook preBuild

      # Focus on UI workspace + transitives (prunes unrelated cmd/go tooling; ~150MB vs full 500MB monorepo)
      yarn workspaces focus --production bloodhound-ui  # Hoists @bloodhound/types for type-safe Cypher risk calcs (e.g., GenericAll edges for delegation exploits)

      cd cmd/ui

      # Vite bundles dist/ (hashed JS/CSS ~2MB; Sigma 2.4 renders weighted paths like ResourceBasedConstrainedDelegation → DCSync RCE)
      yarn build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/dist
      cp -r cmd/ui/dist/* $out/dist/  # Assets for Go embed: index.html + main.[hash].js (tamper-proof for air-gapped drops)

      runHook postInstall
    '';

    doCheck = false; # Skip Cypress E2E (peer noise like @testing-library/dom irrelevant for static bundle)

    meta = with lib; {
      description = "BloodHound UI static assets—React/Vite/Sigma for AD path viz (shortestPath to DA via UnconstrainedKerb)";
      platforms = platforms.linux;
    };
  });
in
buildGoModule rec {
  pname = "bloodhound-ce";
  inherit version src;
  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC="; # From failed build

  goPackagePath = "github.com/specterops/bloodhound"; # Lowercase per go.mod

  nativeBuildInputs = [ nodePackages.nodejs ];

  buildInputs = [ ui ];

  env.CGO_ENABLED = 0;

  ldFlags = lib.concatStringsSep " " [
    "-X github.com/specterops/bloodhound/cmd/api/src/version.majorVersion=${lib.elemAt (lib.splitString "." version) 0}"
    "-X github.com/specterops/bloodhound/cmd/api/src/version.minorVersion=${lib.elemAt (lib.splitString "." version) 1}"
  ];

  # Embedding UI for API static serve (/assets/ loads SPA for Cypher queries
  preBuild = ''
    mkdir -p cmd/api/src/api/static/assets
    cp -r ${ui}/dist/* cmd/api/src/api/static/assets/
  '';

  # files for collectors: Sharphound / AzureHound
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
    cp ${src}/dockerfiles/configs/bloodhound.config.json $out/etc/bloodhound.config.json  # Patch neo4j_uri for SOCKS5 tunnel to evade EDR
  '';

  doCheck = false;

  meta = with lib; {
    description = "BloodHound is a monolithic web application composed of an embedded React frontend with Sigma.js and a Go based REST API backend. It is deployed with a Postgresql application database and a Neo4j graph database, and is fed by the SharpHound and AzureHound data collectors.";
    homepage = "https://github.com/SpecterOps/BloodHound";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
