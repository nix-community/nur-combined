{
  lib,
  buildNpmPackage,
  fetchgit,
  writeScript,
}:
buildNpmPackage rec {
  pname = "bitwarden";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/vicinaehq/extensions";
    rev = "0e3953058fb787d2a96e5ac0cec462440c07cd07";
    sha256 = "sha256-UXHOAQkZygiF0ktRLqw6Xj0FaA/ZY4QfXm9m4bX9wuc=";
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
      update-source-version vicinae-${pname} "${version}" --ignore-same-version --rev="$REV"
      update-source-version vicinae-${pname} "${version}" --ignore-same-version --source-key=npmDeps
    '';

  npmDepsHash = "sha256-08AigyP59EeO5lKymNp/ANzsczs9RkRY4kFOS8CKq24=";

  installPhase =
    # bash
    ''
      runHook preInstall

      mkdir -p $out
      cp -r /build/.local/share/vicinae/extensions/${pname}/* $out/

      runHook postInstall
    '';

  meta = {
    description = "Search, copy and paste credentials from your Bitwarden vault using the rbw CLI";
    homepage = "https://www.vicinae.com/extensions/bl4zee1g/bitwarden";
    license = lib.licenses.mit;
  };
}
