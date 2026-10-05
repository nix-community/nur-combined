{
  lib,
  buildNpmPackage,
  fetchgit,
  writeScript,
}:
buildNpmPackage rec {
  pname = "jisho";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/raycast/extensions";
    rev = "2a329b9368078f672dd4ef6324a16d676ed04437";
    sha256 = "sha256-fY3GoLuUgG+OZb2mnpOB8S+sEw9CptyQSubgSO/LdKU=";
    sparseCheckout = ["/extensions/${pname}"];
    rootDir = "/extensions/${pname}";
  };

  postPatch =
    # bash
    ''
      cp ${./package.json} package.json
      cp ${./package-lock.json} package-lock.json
    '';

  patches = [./type.patch];

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

  npmDepsHash = "sha256-RFfMJ3qN2wy4ycHgJeljcZXE5MRvgMXOCJQ+FqjTcyY=";

  preBuild =
    # bash
    ''
      mkdir -p $TMPDIR/bin

      echo '#!/bin/sh' > $TMPDIR/bin/xdg-open
      echo 'exit 0' >> $TMPDIR/bin/xdg-open

      chmod +x $TMPDIR/bin/xdg-open
      export PATH="$TMPDIR/bin:$PATH"
    '';

  installPhase =
    # bash
    ''
      runHook preInstall

      mkdir -p $out
      cp -r /build/.config/raycast/extensions/${pname}/* $out/

      runHook postInstall
    '';

  meta = {
    description = "Search Jisho.org";
    homepage = "https://www.raycast.com/dmacdermott/jisho";
    license = lib.licenses.mit;
  };
}
