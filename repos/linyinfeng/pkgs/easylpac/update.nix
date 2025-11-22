{
  writeShellApplication,
  nix-update,
  curl,
}:

writeShellApplication {
  name = "update-easylpac";
  runtimeInputs = [
    nix-update
    curl
  ];
  text = ''
    args=("$@")

    while [[ $# -gt 0 ]]; do
      case $1 in
        --write-commit-message)
          commit_message_file="$2"
          shift 2
          ;;
        *)
          echo "unknown option $1" 1>&2
          exit 1
          ;;
      esac
    done

    nix-update easylpac "''${args[@]}"
    pushd pkgs/easylpac
    # TODO 404 Not Found
    # curl --location --output eum-registry.json https://euicc-manual.osmocom.org/docs/pki/eum/manifest-v2.json
    curl --location --output ci-registry.json  https://euicc-manual.osmocom.org/docs/pki/ci/manifest.json
    if [[ -n "$commit_message_file" ]]; then
      if ! git diff --exit-code --no-patch -- eum-registry.json; then
        echo "easylpac: update eum-registry.json" >> "$commit_message_file"
      fi
      if ! git diff --exit-code --no-patch -- ci-registry.json; then
        echo "easylpac: update ci-registry.json" >> "$commit_message_file"
      fi
    fi
    popd
  '';
}
