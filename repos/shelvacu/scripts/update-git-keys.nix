{
  config,
  writers,
  curl,
  lib,
  vaculib,
  vacuRoot,
  ...
}:
writers.writeBashBin "update-git-keys" ''
  set -xev
  if [[ "x''${1:-}" = "x" ]]; then
    echo "1 arg required: domain" >2
    exit 1
  fi
  declare domain api_key url_base
  domain="$1"
  api_key="$(${lib.getExe config.vacu.wrappedSops} --extract '["'$domain'"]' -d ${vaculib.path /${vacuRoot}/secrets/misc/git-keys.json})"
  if [[ $domain = github.com ]]; then
    url_base="https://api.github.com"
  elif [[ $domain = gitlab.com ]]; then
    url_base="https://$domain/api/v4"
  elif [[ $domain = sr.ht ]]; then
    url_base="https://meta.sr.ht/api"
  else
    url_base="https://$domain/api/v1"
  fi

  declare url_keys
  if [[ $domain = sr.ht ]]; then
    url_keys="$url_base/user/ssh-keys"
  else
    url_keys="$url_base/user/keys"
  fi

  declare authorization_name
  if [[ $domain = "git.uninsane.org" ]] || [[ $domain = "sr.ht" ]] || [[ $domain = git.for.miras.pet ]]; then
    authorization_name="token"
  else
    authorization_name="Bearer"
  fi

  declare -a curl_common
  curl_common=(
    ${lib.getExe curl}
    --fail
    --header "Authorization: $authorization_name $api_key"
    --header "Content-Type: application/json"
  )
  if [[ $domain = "github.com" ]]; then
    curl_common+=(
      --header "Accept: application/vnd.github+json"
      --header "X-GitHub-Api-Version: 2022-11-28"
    )
  fi
  echo GET "$url_keys"
  declare resp
  resp="$("''${curl_common[@]}" "$url_keys")"
  declare -i num_keys i
  num_keys="$(printf '%s' "$resp" | jq '.|length')"
  i=0
  while (( i < num_keys )); do
    url="$(printf '%s' "$resp" | jq .[$i].url -r)"
    if [[ $url == null ]]; then
      key_id="$(printf '%s' "$resp" | jq .[$i].id -r)"
      url="$url_keys/$key_id"
    fi
    echo DELETE "$url"
    "''${curl_common[@]}" "$url" -X DELETE
    i=$((i + 1))
  done

  declare -a new_keys=(${
    lib.escapeShellArgs (
      lib.mapAttrsToList (
        label: sshKey:
        builtins.toJSON {
          key = sshKey;
          title = label;
        }
      ) config.vacu.ssh.authorizedKeys
    )
  })
  declare keydata
  for keydata in "''${new_keys[@]}"; do
    echo POST "$api_keys"
    "''${curl_common[@]}" "$url_keys" -X POST --data "$keydata"
  done
''
