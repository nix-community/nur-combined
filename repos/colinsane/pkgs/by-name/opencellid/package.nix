{
  common-updater-scripts,
  coreutils,
  fetchurl,
  lib,
  stdenv,
  writeShellApplication,
# database downloads are limited per API key, so please consider supplying your own API key if using this package
  apiKey ? "pk.758ba60a9bf5fc060451153c3e2542dc",
}:

stdenv.mkDerivation rec {
  pname = "opencellid";
  version = "0-unstable-2025-01-02";

  src = fetchurl {
    # this is a live url. updated... weekly? the server seems to silently ignore unrecognized query parameters,
    # so i append a version tag such that bumping it forces nix to re-fetch the data.
    # the API key should allow for at least 2 downloads per day (maybe more?)
    # TODO: repackage this such that hashes can be stable (mirror the data in a versioned repo, and point to that here?)
    url = "https://opencellid.org/ocid/downloads?token=${apiKey}&type=full&file=cell_towers.csv.gz&_stamp=${version}";
    hash = "sha256-Zh3AjmXzYs1E7fvpR53ULkuVg42tvYSxB+SIhKmabPE=";
  };

  unpackPhase = ''
    gunzip "$src" --stdout > cell_towers.csv
  '';

  installPhase = ''
    runHook preInstall

    cp cell_towers.csv $out

    runHook postInstall
  '';

  passthru.updateScript = writeShellApplication {
    name = "opencellid-update-script";
    runtimeInputs = [ common-updater-scripts coreutils ];
    text = ''
      # UPDATE_NIX_ATTR_PATH is supplied by the caller
      version=0-unstable-$(date +%Y-%m-%d)
      update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" \
        --ignore-same-version \
        --print-changes
    '';
  };

  meta = with lib; {
    description = "100M-ish csv database of known celltower positions";
    homepage = "https://opencellid.org";
    maintainers = with maintainers; [ colinsane ];
  };
}
