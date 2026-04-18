{
  lib,
  buildNpmPackage,
  fetchgit,
  writeScript,
  ...
}:
buildNpmPackage rec {
  pname = "bitwarden";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/raycast/extensions";
    rev = "05f80223a5cad6e11c71878bf1888e5d44b36c7a";
    sha256 = "sha256-s4yFFTl0qDfDNW+2EZmNd6XZlDrHX3th1leyjPYPZXE=";
    sparseCheckout = [
      "/extensions/${pname}"
    ];
    rootDir = "/extensions/${pname}";
  };

  passthru.updateScript =
    writeScript "update-${pname}"
    # bash
    ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq common-updater-scripts

      set -eu -o pipefail

      REV="$(curl -s https://api.github.com/repos/raycast/extensions/commits?per_page=1 | jq -r '.[0].sha')"
      update-source-version raycast-${pname} "${version}" --ignore-same-version --rev="$REV"
      update-source-version raycast-${pname} "${version}" --ignore-same-version --source-key=npmDeps
    '';

  npmDepsHash = "sha256-wvi/IzNCWdcU96Bn7B2YOUihx/IHC4sCJAElmvNK3Qc=";

  installPhase =
    # bash
    ''
      runHook preInstall

      mkdir -p $out
      cp -r /build/.config/raycast/extensions/${pname}/* $out/

      runHook postInstall
    '';

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  meta = {
    description = "Access your Bitwarden vault directly from Raycast";
    homepage = "https://www.raycast.com/jomifepe/bitwarden";
    license = lib.licenses.mit;
  };
}
