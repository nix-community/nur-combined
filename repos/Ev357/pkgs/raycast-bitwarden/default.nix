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
    rev = "9c95e439effe2625f88a051b520bfdfcf3ae2ae2";
    sha256 = "sha256-bZLKe5xZc2RxEsF24zcAVMVkWct4nzFaIXkUkq1nlwA=";
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

  npmDepsHash = "sha256-wqaOwv41xafzGwZjrleEJYXmEA9X8jdB0RbSR9Ml8zw=";

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
