{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchurl,
  hash,
  makeWrapper,
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

  # Keep upstream's version flags
  parts = lib.splitString "." version;
  major = lib.elemAt parts 0;
  minor = lib.elemAt parts 1;
  patch = lib.elemAt parts 2;

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
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ ];

  # Statically linked build (as upstream does)
  env.CGO_ENABLED = 0;

  # Keep upstream's version flags
  ldflags = [
    "-X=github.com/specterops/bloodhound/cmd/api/src/version.majorVersion=${major}"
    "-X=github.com/specterops/bloodhound/cmd/api/src/version.minorVersion=${minor}"
    "-X=github.com/specterops/bloodhound/cmd/api/src/version.patchVersion=${patch}"
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
      mkdir -p $out/bin $out/libexec/bloodhound $out/share/bloodhound $out/etc

      # Real server
      install -Dm755 $GOPATH/bin/bhapi $out/libexec/bloodhound/bloodhound-real

      # Ship collectors & UI
      cp -r collectors $out/share/bloodhound/
      cp -r ${uiDist} $out/share/bloodhound/assets

      # Example config
      install -Dm644 ${src}/dockerfiles/configs/bloodhound.config.json \
        $out/share/doc/bloodhound/bloodhound.config.json

      # Wrapper WITHOUT any dollar expansions seen by Nix
      cat > $out/bin/bloodhound <<'SH'
    #!/bin/sh
    set -e

    # Resolve prefix (…/nix/store/<drv>)
    self="$(readlink -f "$0")"
    prefix_dir="$(cd "$(dirname "$self")/.." && pwd)"
    real="$prefix_dir/libexec/bloodhound/bloodhound-real"

    # Allow reading possibly-unset vars without tripping -u
    set +u

    # Default collectors path if not set or empty
    if [ -z "$bhe_collectors_base_path:-" ]; then
      bhe_collectors_base_path="$prefix_dir/share/bloodhound/collectors"
    fi

    # Default work dir
    if [ -z "$bhe_work_dir:-" ]; then
      if [ -d /var/lib/bloodhound-ce ] && [ -w /var/lib/bloodhound-ce ]; then
        bhe_work_dir=/var/lib/bloodhound-ce/work
      else
        if [ -z "$XDG_STATE_HOME:-" ]; then
          if [ -n "$HOME:-" ]; then
            XDG_STATE_HOME="$HOME/.local/state"
          else
            XDG_STATE_HOME="/tmp/.local/state"
          fi
        fi
        bhe_work_dir="$XDG_STATE_HOME/bloodhound/work"
      fi
    fi

    # Back to strict mode
    set -u

    export bhe_collectors_base_path
    export bhe_work_dir

    exec -a "$0" "$real" "$@"
    SH
      chmod +x $out/bin/bloodhound
  '';

  doCheck = false;

  meta = with lib; {
    description = "BloodHound monolithic web application (Go REST API + React/Vite frontend)";
    homepage = "https://github.com/SpecterOps/BloodHound";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "bloodhound";
  };
}
