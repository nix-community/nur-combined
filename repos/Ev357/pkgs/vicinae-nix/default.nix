{
  lib,
  buildNpmPackage,
  fetchgit,
  writeScript,
}:
buildNpmPackage rec {
  pname = "nix";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/vicinaehq/extensions";
    rev = "5882e1bbdfcf64279cbd1ed86a50aabed6f716d3";
    sha256 = "sha256-OPxgKOoUBw9GVshdSF27QJFFaR8fVLGqDljIj8mZHow=";
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

      REV="$(curl -s https://api.github.com/repos/vicinaehq/extensions/commits?per_page=1 | jq -r '.[0].sha')"
      update-source-version raycast-${pname} "${version}" --ignore-same-version --rev="$REV"
      update-source-version raycast-${pname} "${version}" --ignore-same-version --source-key=npmDeps
    '';

  npmDepsHash = "sha256-TEyCCDjAtRYX2uH2TpLfe4/hTzyfMiyDhzVdyQXhEus=";

  installPhase =
    # bash
    ''
      runHook preInstall

      mkdir -p $out
      cp -r /build/.local/share/vicinae/extensions/${pname}/* $out/

      runHook postInstall
    '';

  meta = {
    description = "Search and browse Nix packages, options, flakes, and Home-Manager options";
    homepage = "https://www.vicinae.com/extensions/knoopx/nix";
    license = lib.licenses.mit;
  };
}
