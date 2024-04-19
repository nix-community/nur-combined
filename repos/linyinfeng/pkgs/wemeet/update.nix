{
  writeShellApplication,
  python3,
  curl,
  jq,
  urlencode,
  moreutils,
}:

writeShellApplication {
  name = "update-wemeet";
  runtimeInputs = [
    python3
    curl
    jq
    urlencode
    moreutils
  ];
  text = ''
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

    pushd pkgs/wemeet

    # query.json is taken from https://meeting.tencent.com/download using browser debugger
    query_param=$(jq --raw-output @uri ./query.json)
    nonce_param=$(python3 <<EOF
    import secrets
    import string
    print('''.join(secrets.choice(string.ascii_letters) for i in range(16)))
    EOF
    )
    query_url="https://meeting.tencent.com/web-service/query-download-info?q=$query_param&nonce=$nonce_param"
    echo "query url: $query_url"

    echo "curl"
    curl --verbose "$query_url" | jq '.' >raw_source.json

    if [[ -n "$commit_message_file" ]]; then
      if [[ -f "$commit_message_file" ]]; then
        rm "$commit_message_file"
      fi
    fi
    hash_type="sha512"
    for platform in x86_64 aarch64 loongarch64; do
      system="$platform-linux"

      version_old=$(jq --arg system "$system" --raw-output '."\($system)".version' source.json)

      if [ "$platform" = "x86_64" ]; then
        regex="^linux$"
      elif [ "$platform" = "aarch64" ]; then
        regex="^linux_arm64$"
      elif [ "$platform" = "loongarch64" ]; then
        regex="^linux_deb_loongarch64$"
      fi

      info=$(jq '."info-list" [] | select(.platform | match("'"$regex"'"))' raw_source.json)
      version=$(jq '.version' <<<"$info" --raw-output)
      if [ "$version" = "$version_old" ]; then
        echo "wemeet ($system): version does not change, skip."
        continue
      fi
      url=$(jq '.url' <<<"$info" --raw-output)
      hash=$(nix --experimental-features nix-command \
        store prefetch-file --json --hash-type "$hash_type" \
        "$(jq '.url' --raw-output <<<"$info")" |\
        jq '.hash' --raw-output)

      echo "platform: $platform"
      echo "info: $info"
      echo "url: $url"
      echo "version: $version"
      echo "hash: $hash"

      jq \
        --arg system "$platform-linux" \
        --arg version "$version" \
        --arg url "$url" \
        --argjson info "$info" \
        --arg hash_type "$hash_type" \
        --arg hash "$hash" \
        '."\($system)" = { version: $version, url: $url, ($hash_type): $hash,  info: $info }' \
        source.json | sponge source.json

      if [[ -n "$commit_message_file" ]]; then
        if [ "$version_old" = "null" ]; then
          echo "wemeet ($system): init at $version" >>"$commit_message_file"
        else
          echo "wemeet ($system): $version_old -> $version" >>"$commit_message_file"
        fi
      fi
    done

    popd
  '';
}
