#!/usr/bin/env bash
source shellvaculib.bash || exit 1

svl_exact_args $# 0

# nixosConfigurations.* where sops is used
configs=(
  prophecy
  fw
  liam
  triple-dezert
)

declare -i exitCode=0

for configName in "${configs[@]}"; do
  nixPath="nixosConfigurations.\"${configName}\".config.sops.secrets"
  secretsInfo="$(nix eval ".#.$nixPath" --json)"
  declare -a secretsNames
  jqKeysOutput="$(jq '.|keys[]' --raw-output0 <<<"$secretsInfo")"
  mapfile -d '' secretsNames <<<"$jqKeysOutput"
  for name in "${secretsNames[@]}"; do
    thisSecretNixPath="${nixPath}.\"${name}\""
    jqPath=".\"${name}\""
    thisSecretInfo="$(jq "$jqPath" <<<"$secretsInfo")"
    format="$(jq '.format' -r <<<"$thisSecretInfo")"
    sopsFile="$(jq '.sopsFile' -r <<<"$thisSecretInfo")"
    case "$format" in
    yaml | json | binary)
      # we know how to deal with this
      :
      ;;
    *)
      svl_throw "dunno what to do with format $format for $thisSecretNixPath"
      ;;
    esac
    declare key
    if [[ $format == binary ]]; then
      key=""
    else
      key="$(jq '.key' -r <<<"$thisSecretInfo")"
    fi
    sopsCmd=(
      nix run .#sops --
      decrypt
      --input-type "$format"
    )
    # make sure we can decrypt the file at all
    if ! "${sopsCmd[@]}" -- "$sopsFile" >/dev/null; then
      svl_err "${thisSecretNixPath}: could not decrypt $sopsFile"
      exitCode=1
      continue
    fi
    if [[ $format != binary ]]; then
      # now try to read the specific key we're interested in
      if ! "${sopsCmd[@]}" --extract "[\"$key\"]" -- "$sopsFile" >/dev/null; then
        svl_err "${thisSecretNixPath}: sops file $sopsFile does not contain key $key"
        exitCode=1
        continue
      fi
    fi
  done
done

exit "$exitCode"
