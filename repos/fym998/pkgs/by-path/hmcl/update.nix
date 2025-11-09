{
  writeShellApplication,
  nix,
  nix-update,
  curl,
  common-updater-scripts,
  jq,
}:

writeShellApplication {
  name = "update-hmcl";
  runtimeInputs = [
    curl
    jq
    nix
    common-updater-scripts
    nix-update
  ];

  text = ''
    # get old info
    oldVersion=$(nix-instantiate --eval --strict -A "hmcl.version" | jq -e -r)

    get_latest_release() {
        curl -s "https://hmcl.huangyuhui.net/api/update_link?channel=stable&download_link=true" | jq -r .version
    }

    version=$(get_latest_release)
    version="''${version#v-}"

    if [[ "$oldVersion" == "$version" ]]; then
        echo "Already up to date!"
        exit 0
    fi

    nix-update hmcl --version="$version"
  '';
}
