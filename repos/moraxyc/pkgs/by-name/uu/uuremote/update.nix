{
  writeShellApplication,
  curl,
  pcre2,
  common-updater-scripts,
}:
writeShellApplication {
  name = "uuremote-update-script";

  runtimeInputs = [
    curl
    pcre2
    common-updater-scripts
  ];

  text = ''
    latest_url="$(
      curl \
        --fail \
        --silent \
        --show-error \
        --location \
        --head \
        --output /dev/null \
        --write-out '%{url_effective}' \
        "https://api.nrd.nie.163.com/api/v1/release/dl/4?channel=gwqd"
    )"

    latest_version="$(
      printf '%s\n' "$latest_url" \
        | pcre2grep -io1 'uuyc[._-]v?(\d+(?:\.\d+)+)\.pkg'
    )"

    update-source-version \
      "''${UPDATE_NIX_ATTR_PATH:-uuremote}" \
      "$latest_version"
  '';
}
