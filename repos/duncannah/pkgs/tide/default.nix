{
  lib,
  buildFishPlugin,
  fetchFromGitHub,
  writeScript,
}:

buildFishPlugin rec {
  pname = "tide";
  version = "7.1.2";

  src = fetchFromGitHub {
    owner = "plttn";
    repo = "tide";
    rev = "v${version}";
    hash = "sha256-R2oIGbDPF81NurJ5R2Jos6P5mxYTyb1n1cpI1AZ35H4=";
  };

  # buildFishPlugin moves only the .fish files, but Tide also has a tide configure function.
  postInstall = ''
    cp -R functions/tide $out/share/fish/vendor_functions.d/
  '';

  passthru.updateScript = writeScript "update-tide" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl jq common-updater-scripts
    set -euo pipefail
    repo="https://api.github.com/repos/plttn/tide/releases"
    version="$(curl --fail --silent --show-error --location "$repo" | jq --exit-status --raw-output '
      [.[] | select(.prerelease == false and (.tag_name | test("^v[0-9]+(\\.[0-9]+)+$")))]
      | .[0].tag_name | strings | sub("^v"; "") | select(length > 0)
    ')"
    update-source-version tide "$version"
  '';

  meta = {
    description = "Fork of the unmaintained Tide Fish prompt";
    homepage = "https://github.com/plttn/tide";
    license = lib.licenses.mit;
  };
}
