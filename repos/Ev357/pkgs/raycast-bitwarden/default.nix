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
    rev = "5e98ea3fce2d4c487a59dfc2f5e3455a7d18564c";
    sha256 = "sha256-HK7UCPnLlNQP1YqjqcofMNvVIigOpo1DfzxNX1I90gQ=";
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

  npmDepsHash = "sha256-yf77qDBg5hX6eW6yeglGaiyx6UzEhsrpwBtDccS7/H0=";

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
