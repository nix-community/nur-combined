obsidianManifestCheckHook() {
  if ! diff <(jq --sort-keys . "$out/manifest.json") <(jq .manifest "$NIX_ATTRS_JSON_FILE"); then
    echo "ERROR: The vendored manifest.json file is out of date"
    exit 1
  fi

  if ! [[ $(jq -r .version "$out/manifest.json") == "$version" ]]; then
    echo "ERROR: The version in the manifest.json file does not match '$version'"
    exit 1
  fi
}

preInstallCheckHooks+=(obsidianManifestCheckHook)
