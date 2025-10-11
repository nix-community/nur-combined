{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchurl,
  hash,
}:

let
  # BloodHound version we package
  version = "8.2.0";
  rev = "v${version}";

  # Upstream Go source (no frontend build here)
  src = fetchFromGitHub {
    owner = "SpecterOps";
    repo = "BloodHound";
    inherit rev;
    sha256 = hash;
  };

  # Collector binaries (shipped alongside the server)
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

  # ─────────────────────────────────────────────────────────────────────────────
  # Vendored UI assets:
  #
  # - Build the UI outside Nix (e.g., `yarn && yarn build` in upstream repo),
  # - copy the produced cmd/ui/dist/* into this repo at ./ui/dist/,
  # - Nix will just embed those files; no Yarn/Node runs in the derivation.
  #
  # builtins.path makes the directory content-addressed & reproducible.
  # ─────────────────────────────────────────────────────────────────────────────
  uiDist = builtins.path {
    path = ./ui/dist; # contains assets/, index.html, etc.
    name = "bloodhound-ui-dist";
  };
in

buildGoModule {
  pname = "bloodhound-ce";
  inherit version src;

  goPackagePath = "github.com/specterops/bloodhound";

  # Set to the vendor hash for the Go module graph (Nix will prompt if it changes)
  vendorHash = "sha256-Lm6g0pxGVIuns6mUwnkbnBQQQp1V0TvEakX5fAo8qMo=";

  # No Node/Yarn: we don’t build frontend here.
  nativeBuildInputs = [ ];
  buildInputs = [ ];

  # Statically linked build (as upstream does)
  env.CGO_ENABLED = 0;

  # Keep upstream’s version flags
  ldFlags = lib.concatStringsSep " " [
    "-X github.com/specterops/bloodhound/cmd/api/src/version.majorVersion=${lib.elemAt (lib.splitString "." version) 0}"
    "-X github.com/specterops/bloodhound/cmd/api/src/version.minorVersion=${lib.elemAt (lib.splitString "." version) 1}"
  ];

  # Before building Go, stage the prebuilt UI under the API’s static dir
  preBuild = ''
    mkdir -p cmd/api/src/api/static/assets
    cp -r ${uiDist}/* cmd/api/src/api/static/assets/
  '';

  # Also ship collectors next to the final binary
  postBuild = ''
    mkdir -p collectors/{sharphound,azurehound}
    cp ${sharphound} collectors/sharphound/
    cp ${azurehound} collectors/azurehound/
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/bloodhound $out/etc

    # Install server
    cp $GOPATH/bin/bhapi $out/bin/bloodhound

    # Install collectors & UI assets for convenience
    cp -r collectors $out/share/bloodhound/
    cp -r ${uiDist} $out/share/bloodhound/assets

    # Default config
    cp ${src}/dockerfiles/configs/bloodhound.config.json \
       $out/etc/bloodhound.config.json
  '';

  doCheck = false;

  meta = with lib; {
    description = "BloodHound monolithic web application (Go REST API + React/Vite frontend)";
    homepage = "https://github.com/SpecterOps/BloodHound";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
}
